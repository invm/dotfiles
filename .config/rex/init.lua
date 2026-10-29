local copy_mode_script = [[
vim.api.nvim_set_hl(0, "CopyModeTag", { bold = true, fg = "#1e1e2e", bg = "#f9e2af", ctermfg = 0, ctermbg = 11 })
vim.api.nvim_set_hl(0, "WinBar", { fg = "#cdd6f4", bg = "#313244", ctermfg = 15, ctermbg = 236 })
vim.o.winbar = "%#CopyModeTag# COPY MODE %#WinBar#  q quit · v select · y yank · C-k yank to EOL"
local f = io.open(vim.fn.argv(0), "rb")
local data = f:read("*a")
f:close()
local function render()
  local old = vim.api.nvim_get_current_buf()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_chan_send(vim.api.nvim_open_term(buf, {}), data)
  vim.api.nvim_buf_delete(old, { force = true })
  vim.defer_fn(function() vim.cmd("normal! G") end, 50)
end
render()
vim.api.nvim_create_autocmd("VimResized", { callback = render })
]]

rex.action{
  name  = "copy_mode",
  title = "Copy Mode (scrollback in nvim)",
  run   = function(ctx, args)
    local r, err = rex.block.call("com.superlogical.terminal", "format",
      { block_id = ctx.block_id, format = "vt", trim = true })
    if r == nil then error(err, 0) end
    local path = os.tmpname() .. ".vt"
    local f = assert(io.open(path, "w"))
    f:write(r.content or "")
    f:close()
    local script = os.tmpname() .. ".lua"
    f = assert(io.open(script, "w"))
    f:write(copy_mode_script)
    f:close()
    local _, err2 = rex.session.new_layer{
      bounds = { 0, 0, 1, 1 },
      focus = true,
      layout = rex.layout.block{
        flavor  = "com.superlogical.terminal.shell",
        options = {
          shell = "none",
          command = { "/opt/homebrew/bin/nvim", "--clean",
            "-c", "set clipboard=unnamedplus nonumber laststatus=0 noshowmode noruler shortmess+=F scrollback=100000",
            "-c", "nnoremap q :q!<CR>", "-c", "vnoremap y y:q!<CR>",
            "-c", "nnoremap <C-k> y$:q!<CR>",
            "-S", script, path },
        },
      },
    }
    if err2 ~= nil then error(err2, 0) end
  end,
}
rex.bind("ctrl+q>[", "copy_mode")

package.path = os.getenv("HOME") .. "/.local/share/nvim/lazy/vim-rex-navigator/rex/?.lua;" .. package.path
require("vim-rex-navigator").setup {
  focus_left = "ctrl+h", focus_down = "ctrl+j", focus_up = "ctrl+k", focus_right = "ctrl+l",
  move = false, resize = false, close = false,
}

local terminal = "com.superlogical.terminal"
local alt_screen = { [47] = true, [1047] = true, [1049] = true }

local function full_screen(block_id)
  local r = rex.block.call(terminal, "modes", { block_id = block_id })
  for _, m in ipairs(r and r.modes or {}) do
    if alt_screen[m.number] and m.set then return true end
  end
  return false
end

rex.action{
  name = "scroll_step",
  title = "Scroll Step",
  args = { direction = "string" },
  run = function(ctx, args)
    local up = args.direction == "up"
    if ctx.block_id and full_screen(ctx.block_id) then
      rex.block.call(terminal, "write", {
        block_id = ctx.block_id,
        data = up and "\27[5~" or "\27[6~",
      })
    else
      rex.client.queue(up and "client.prompt.previous" or "client.prompt.next")
    end
  end,
}

rex.mode("scroll", { exclusive = true })
rex.bind("ctrl+q>u", "client.mode.enter", { name = "scroll" })
for _, k in ipairs({ "k", "up" }) do rex.bind("scroll/" .. k, "scroll_step", { direction = "up" }) end
for _, k in ipairs({ "j", "down" }) do rex.bind("scroll/" .. k, "scroll_step", { direction = "down" }) end
rex.bind("scroll/q", "client.mode.exit")

local rex_cli = os.getenv("HOME") .. "/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"
local resize_exit
rex.action{
  name = "resize_repeat",
  title = "Resize Pane (repeatable)",
  args = { direction = "string", enter = "boolean?" },
  run = function(ctx, args)
    rex.invoke("vim_rex_resize", { direction = args.direction, amount = 2 })
    if args.enter then rex.client.queue("client.mode.enter", { name = "resize" }) end
    if resize_exit then resize_exit:kill() end
    resize_exit = rex.exec.start({ "/bin/sh", "-c", 'sleep 0.3 && exec "$0" do client.mode.exit', rex_cli })
  end,
}

rex.mode("resize")
for k, d in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+q>shift+" .. k, "resize_repeat", { direction = d, enter = true })
  rex.bind("resize/shift+" .. k, "resize_repeat", { direction = d })
end

for k, key in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("opt+" .. k, "pane.send_key", { key = key })
end
