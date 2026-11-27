import type { Register } from 'claude-code'

export const register: Register = on => {
  on('ui.render', { component: 'CodeBlock' }, async ($, e, next) => {
    if (!e.props.isClosed || e.props.source === '') {
      return next(e)
    }

    const { Box, Button, Text } = $.ui.resolve(e)
    const block = await next(e)

    return (
      <Box flexDirection="column">
        {block}
        <Box>
          <Button
            key="copy"
            label="copy"
            action="app:cycleDiffBase"
            onPress={press => $.ui.copy({ text: e.props.source, surface: press.surface })}
          />
          <Text dimColor> ctrl+x ctrl+y</Text>
        </Box>
      </Box>
    )
  })
}
