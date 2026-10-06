const SLASH = /\.(ts|tsx|js|jsx|mjs|cjs|mts|cts|rs|go|java|kt|swift|c|h|cpp|cs|scala)$/
const HASH = /\.(py|sh|zsh|bash|rb|yml|yaml|toml)$/
const KEEP = /(eslint|biome-ignore|prettier-ignore|@ts-|TODO|FIXME|HACK|XXX|ponytail:|\/\/\/ <reference|noqa|type:|pyright|fmt:|nolint|shellcheck|SPDX|Copyright|License)/i

export const candidates = (path: string, src: string): number[] => {
  const prefix = SLASH.test(path) ? '//' : HASH.test(path) ? '#' : null
  if (!prefix) return []
  const out: number[] = []
  let inBlock = false
  for (const [i, line] of src.split('\n').entries()) {
    const t = line.trim()
    if (inBlock) {
      out.push(i)
      if (t.includes('*/')) inBlock = false
      continue
    }
    if (i === 0 && t.startsWith('#!')) continue
    if (KEEP.test(t)) continue
    if (t.startsWith(prefix) && !t.startsWith('/**')) { out.push(i); continue }
    if (prefix === '//' && t.startsWith('/*') && !t.startsWith('/**')) {
      out.push(i)
      inBlock = !t.includes('*/')
    }
  }
  return out
}

export const drop = (src: string, lines: Set<number>): string =>
  src.split('\n').filter((_, i) => !lines.has(i)).join('\n')

export const judgePrompt = (src: string, cands: number[]): string => {
  const lines = src.split('\n')
  const numbered = lines.map((l, i) => `${cands.includes(i) ? '>' : ' '}${i}: ${l}`).join('\n')
  return `Code below. Lines marked ">" are comments. Decide which to KEEP.
KEEP only a comment that states something the code cannot express: a non-obvious invariant, a workaround with a reason or issue link, a gotcha, a why.
DELETE comments that narrate what the code does, restate the next line, explain obvious logic, or justify a change to a reviewer.
Also KEEP any marked line that is actually inside a string or template literal, not a real comment.
Reply with ONLY a JSON array of line numbers to KEEP, e.g. [3,7]. Empty array if none.

${numbered}`
}

export const parseKeep = (text: string): Set<number> => {
  const m = text.match(/\[[\d,\s]*\]/)
  if (!m) return new Set()
  return new Set(JSON.parse(m[0]) as number[])
}
