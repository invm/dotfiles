import { expect, test } from 'claude-code/testing'

const BLOCK = {
  plugin: 'copy-code',
  surface: 'terminal',
  component: 'CodeBlock',
} as const

test('copy button puts the block source on the clipboard', async ($, on) => {
  const copied: string[] = []
  on('ui.copy', (_, e) => {
    copied.push(e.text)

    return { value: { isCopied: true as const } }
  })

  const ui = await $.ui.mount({
    ...BLOCK,
    props: { language: 'sh', source: 'echo hi\n', isClosed: true },
  })
  await ui.press({ key: 'copy' })

  expect(copied).toEqual(['echo hi\n'])
  await ui.unmount()
})

test('streaming block gets no button', async $ => {
  const ui = await $.ui.mount({
    ...BLOCK,
    props: { language: 'sh', source: '', isClosed: false },
  })

  expect(await ui.find({ type: 'Button' })).toBeUndefined()
  await ui.unmount()
})
