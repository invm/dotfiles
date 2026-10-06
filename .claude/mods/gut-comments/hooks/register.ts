import type { Register, EngineInterface } from 'claude-code'
import { candidates, drop, judgePrompt, parseKeep } from './strip'

const gut = async ($: EngineInterface, path: string, src: string): Promise<{ out: string; removed: number }> => {
  const cands = candidates(path, src)
  if (!cands.length) return { out: src, removed: 0 }
  const r = await $.model.complete({
    model: 'haiku',
    prompt: judgePrompt(src, cands),
    maxTokens: 200,
    effort: 'low',
    timeoutMs: 10_000,
  })
  const keep = r.isAnswered ? parseKeep(r.text) : new Set<number>()
  if (!r.isAnswered) $.ui.toast(`gut-comments: judge failed (${r.reason}), stripping blind`)
  const kill = new Set(cands.filter(i => !keep.has(i)))
  return { out: drop(src, kill), removed: kill.size }
}

export const register: Register = on => {
  on('tool.call', { tool: 'Write' }, async ($, e, next) => {
    const { out, removed } = await gut($, e.file_path, e.content)
    if (removed) $.ui.toast(`gut-comments: ${removed} gutted`)
    return next(removed ? { ...e, content: out } : e)
  }).catch(($, e, next) => next(e))

  on('tool.call', { tool: 'Edit' }, async ($, e, next) => {
    const { out, removed } = await gut($, e.file_path, e.new_string)
    if (!removed || out === e.old_string) return next(e)
    $.ui.toast(`gut-comments: ${removed} gutted`)
    return next({ ...e, new_string: out })
  }).catch(($, e, next) => next(e))
}
