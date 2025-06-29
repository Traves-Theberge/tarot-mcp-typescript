# Swift Tarot MCP Server

A Model Context Protocol (MCP) server that provides tarot card reading functionality. This server allows AI assistants to draw tarot cards, perform multi-card readings, and access the complete tarot deck.

## Features

LLMs are notoriously bad at randomness, similar to humans. This MCP server provides more reliable random number generation for tarot readings.

- **Flexible Card Drawing**: Draw anywhere from 1 to 78 tarot cards in a single request
- **Full Deck Access**: View all 78 cards in the traditional tarot deck
- **Card Images**: Fetch base64-encoded images for tarot cards
- **Deterministic Testing**: Uses seeded random number generation for consistent testing
- **Comprehensive Validation**: Input validation with proper error handling

## Installation

### Prerequisites

- Swift 5.9 or later
- macOS 13.0 or later
- [Just](https://github.com/casey/just) command runner (optional but recommended)

### Install Just (Optional)

```bash
brew install just
```

### Build and Install

1. Clone the repository:
```bash
git clone <repository-url>
cd swift-tarot-MCP
```

2. Build and install the server:
```bash
just install
```

This will build the release version and install it to `/usr/local/bin/swift-tarot-MCP`.

Alternatively, you can build manually:
```bash
swift build -c release
sudo cp .build/release/swift-tarot-MCP /usr/local/bin/
```

## Claude Desktop Configuration

To use this MCP server with Claude Desktop, add the following to your Claude Desktop configuration file:

### macOS Configuration

Edit `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "tarot": {
      "command": "swift-tarot-MCP",
      "args": []
    }
  }
}
```

### After Configuration

1. Restart Claude Desktop
2. The tarot tools should now be available in your conversations
3. You can ask Claude to draw tarot cards, perform readings, or show the full deck

## Available Tools

### `draw_cards`
Draws one or more tarot cards for readings.

**Parameters:**
- `count` (optional): Number of cards to draw (1-78, default: 1)

**Example usage in Claude:**
> "Draw me a tarot card"
> "Draw me 5 tarot cards for a reading"

### `get_full_deck`
Returns all 78 cards in the tarot deck.

**Example usage in Claude:**
> "Show me the complete tarot deck"

### `fetch_images`
Fetches base64-encoded images for tarot card URIs.

**Parameters:**
- `uris`: Array of tarot card URIs to fetch images for

**Example usage in Claude:**
> "Show me the image for The Fool card"

## Development

### Available Commands

If you have Just installed, you can use these commands:

```bash
# Build the project (debug by default)
just build

# Build for release
just build release

# Run tests
just test

# Run tests with verbose output
just test --verbose

# Lint the code
just lint

# Auto-fix linting issues
just lint --fix

# Run the server locally
just run

# Clean build artifacts
just clean

# Install to system PATH
just install

# Remove from system PATH
just uninstall
```

### Manual Commands

Without Just, you can use these Swift commands:

```bash
# Build debug
swift build

# Build release
swift build -c release

# Run tests
swift test

# Run linting
swift package plugin --allow-writing-to-package-directory swiftlint
```

### Testing

The project includes comprehensive tests covering:

- Tarot card data structures and validation
- Deck composition and card drawing
- Server handler functionality
- MCP protocol compliance
- Deterministic behavior with seeded RNG

Run tests with:
```bash
just test
# or
swift test
```

## Architecture

The project is structured as:

- **TarotMCPCore**: Core library containing tarot card logic and MCP server implementation
- **TarotMCP**: Executable that runs the MCP server using stdio transport

### Key Components

- `TarotCard`: Enum representing major and minor arcana cards
- `TarotDeck`: Static methods for card drawing and deck management
- `TarotServer`: MCP server implementation
- `TarotServerHandler`: Handles MCP tool calls and routing

## Card Format

Cards are returned as JSON objects with card details:

```json
[
  {
    "name": "The Fool",
    "imageURI": "tarot://card/major/0"
  },
  {
    "name": "Two of Cups",
    "imageURI": "tarot://card/minor/cups/2"
  },
  {
    "name": "King of Swords",
    "imageURI": "tarot://card/minor/swords/14"
  }
]
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
