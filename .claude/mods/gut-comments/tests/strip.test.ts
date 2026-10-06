import { test, expect } from 'claude-code/testing'
import { candidates, drop, parseKeep } from '../hooks/strip'

const src = `// fetch the user
const u = await get() // trailing stays
/* loop over items */
/*
 multi
*/
/** jsdoc stays */
// eslint-disable-next-line foo
// ponytail: global lock
// Chrome 118 drops the event if dispatched sync, see #412
const url = "https://x"
`

test('candidates: narrating lines, not markers/jsdoc/trailing', async () => {
  expect(candidates('a.ts', src)).toEqual([0, 2, 3, 4, 5, 9])
})

test('python: shebang and noqa kept', async () => {
  expect(candidates('a.py', `#!/usr/bin/env python\n# get user\nx = 1  # noqa\n`)).toEqual([1])
})

test('unknown ext untouched', async () => {
  expect(candidates('a.md', '# heading')).toEqual([])
})

test('parseKeep tolerates prose around array', async () => {
  expect([...parseKeep('Keep: [9]')]).toEqual([9])
  expect([...parseKeep('none')]).toEqual([])
})

test('haiku verdict applied: keeps judged line, guts rest', async ($, on) => {
  let seen = ''
  on('model.complete', (_, e) => {
    expect(e.model).toBe('haiku')
    return { value: { isAnswered: true, text: "[9]", usage: { input_tokens: 0, output_tokens: 0 } } }
  })
  on('tool.call', { tool: 'Write' }, (_, e) => { seen = e.content; return { deny: 'captured' } })
  await $.tool.call({ tool: 'Write', file_path: '/tmp/x.ts', content: src })
  expect(seen).toBe(drop(src, new Set([0, 2, 3, 4, 5])))
  expect(seen).toContain('Chrome 118')
})

test('judge failure strips blind', async ($, on) => {
  let seen = ''
  on("model.complete", () => ({ value: { isAnswered: false, reason: "empty-reply", usage: { input_tokens: 0, output_tokens: 0 } } }))
  on('tool.call', { tool: 'Write' }, (_, e) => { seen = e.content; return { deny: 'captured' } })
  await $.tool.call({ tool: 'Write', file_path: '/tmp/x.ts', content: '// hi\nconst a = 1\n' })
  expect(seen).toBe('const a = 1\n')
})
