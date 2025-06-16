# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Swift MCP (Model Context Protocol) server that provides tarot card reading functionality. The server exposes tools for drawing tarot cards and retrieving the full deck through the MCP protocol.

## Key Commands

### Development
- `just test` - Run all tests
- `just build` - Build debug version (includes linting)
- `just build release` - Build release version
- `just build no-lint` - Build without running SwiftLint
- `just run` - Build and run debug version
- `just run release` - Build and run release version
- `just install` - Build release and install to `/usr/local/bin/swift-tarot-MCP`
- `just clean` - Clean build artifacts
- `just lint` - Run SwiftLint (pass --fix to auto-fix)
- `just format` - Format code with swift-format
- `just check` - Run all checks (test, format, lint)

### Testing MCP Integration
- Test locally: `just run`
- Check Claude integration via MCP client logs

## Common Issues & Solutions

### MCP Tool Schema Issues

**Critical**: MCP tool schemas MUST follow JSON Schema Draft 7 specification exactly.

**Incorrect** (causes server crashes or disabled tools):
```swift
inputSchema: .object([
  "count": .object([...])
])
```

**Correct** (requires `type` and `properties`):
```swift
inputSchema: .object([
  "type": .string("object"),
  "properties": .object([
    "count": .object([...])
  ])
])
```

**Symptoms of schema issues:**
- Server crashes during initialization
- Tools show as disabled in Claude UI
- `tools/list` requests fail

**Debugging steps:**
1. Check MCP client logs for schema validation errors
2. Verify all tool schemas have `type: "object"` at root level
3. Ensure properties are wrapped in `properties` object
4. Test with actual Claude client, not just local Swift tests

### Installation Issues

- Always rebuild and reinstall after schema changes: `just install`
- Installed binary at `/usr/local/bin/swift-tarot-MCP` may be outdated
- Local testing with `just run` may work while installed version fails

## Architecture Notes

- Uses Swift 6 with strict concurrency
- TarotServer and TarotServerHandler are actors for thread safety
- MCP Swift SDK v0.9.0
- Two main tools: `draw_cards` (1-78 cards) and `get_full_deck`