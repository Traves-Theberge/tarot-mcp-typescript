# Tarot MCP TypeScript Server

A **TypeScript** implementation of a **Model Context Protocol (MCP)** server that provides tarot card reading functionality for AI assistants like Claude in Cursor.

## 🎯 Overview

This MCP server offers three powerful tools for tarot card interactions:

- **`draw_cards`** - Draw one or more tarot cards with optional seeded randomization
- **`get_full_deck`** - Get information about all 78 tarot cards in the deck  
- **`fetch_images`** - Retrieve base64-encoded images for specific tarot cards

Perfect for integrating tarot functionality into AI assistants, creative writing tools, or divination applications within Cursor IDE.

## 🏗️ Architecture

### Clean TypeScript Design

```
src/
├── core/                 # Domain models and business logic
│   ├── tarot-card.ts    # Card types, enums, and interfaces
│   ├── card-names.ts    # Card naming utilities
│   ├── deck-factory.ts  # Deck creation and management
│   └── index.ts         # Core module exports
├── server/              # MCP server implementation
│   ├── mcp-server.ts    # Main MCP server class
│   ├── deck-service.ts  # Deck management service
│   ├── mcp-tool-handler.ts # Tool request handlers
│   └── index.ts         # Server module exports
├── utils/               # Shared utilities
│   ├── random-number-generator.ts # RNG abstraction
│   ├── array-shuffle.ts # Fisher-Yates shuffling
│   ├── image-loader.ts  # Image processing utilities
│   ├── uri-parser.ts    # URI parsing and generation
│   └── index.ts         # Utilities module exports
└── index.ts             # Main entry point
```

### Key Features

- **78 Complete Tarot Cards** - All Major Arcana (0-21) and Minor Arcana (4 suits × 14 values)
- **Deterministic Testing** - Seeded RNG for reproducible results in tests
- **Production Ready** - System RNG for real-world usage
- **Type Safety** - Full TypeScript with strict type checking
- **Clean Architecture** - Separation of concerns with dependency injection
- **Comprehensive Testing** - 97+ test cases with >80% coverage
- **Modern Tooling** - ESLint, Prettier, Jest integration

## 🚀 Quick Start

### Installation

```bash
# Clone and install
git clone <repository-url>
cd tarot-mcp-typescript
npm install

# Build the project
npm run build

# Run tests
npm test

# Start the server
npm start
```

### 🎯 Cursor Integration

#### Step 1: Configure MCP in Cursor

Add to your Cursor MCP configuration file:

**Windows:** `%APPDATA%\Cursor\User\globalStorage\cursor.mcp\mcp.json`
**macOS:** `~/Library/Application Support/Cursor/User/globalStorage/cursor.mcp/mcp.json`
**Linux:** `~/.config/Cursor/User/globalStorage/cursor.mcp/mcp.json`

```json
{
  "mcpServers": {
    "tarot-mcp-typescript": {
      "command": "node",
      "args": ["C:/path/to/tarot-mcp-typescript/dist/src/index.js"],
      "env": {}
    }
  }
}
```

#### Step 2: Restart Cursor

After adding the configuration, restart Cursor for the MCP server to be loaded.

#### Step 3: Verify Connection

In Cursor's AI chat, you can verify the connection by asking:
```
"Can you draw a tarot card for me?"
```

The AI should be able to access the tarot tools and respond with card information.

## 🎮 Using in Cursor

### Example Interactions

Once configured, you can interact with the tarot server through Cursor's AI assistant:

#### Draw Random Cards
```
"Draw 3 tarot cards for a past, present, future reading"
"Give me a single card for guidance today"
"Draw 5 cards for a Celtic Cross spread"
```

#### Get Card Information
```
"Tell me about all the Major Arcana cards"
"What are the court cards in the suit of Cups?"
"Show me the full tarot deck"
```

#### Visual Card Reading
```
"Draw The Fool card and show me its image"
"I want to see the Queen of Pentacles card"
"Show me images for a 3-card spread"
```

### Development Workflow in Cursor

The MCP server is perfect for:

- **Creative Writing**: Generate tarot-inspired storylines and character development
- **Game Development**: Integrate tarot mechanics into games
- **Divination Apps**: Build tarot reading applications
- **Educational Tools**: Learn about tarot symbolism and meanings
- **API Development**: Use as a backend service for tarot functionality

### Cursor-Specific Features

- **Real-time Integration**: No need to switch between applications
- **Visual Feedback**: Display card images directly in the chat
- **Context Awareness**: AI can remember previous card draws in the conversation
- **Code Generation**: Generate tarot-related code with actual card data
- **Testing Support**: Use for generating test data in tarot applications

### 🔧 Troubleshooting Cursor Integration

#### Common Issues

**MCP Server Not Found**
- Ensure the path in `mcp.json` points to the compiled JavaScript file (`dist/src/index.js`)
- Verify the project has been built with `npm run build`
- Check that Node.js is in your system PATH

**Connection Refused**
- Make sure Cursor has been restarted after adding the MCP configuration
- Verify the `mcp.json` file is in the correct location for your OS
- Check that the file has valid JSON syntax

**Tools Not Available**
- Ask the AI explicitly: "What MCP tools do you have available?"
- Try: "Can you use the draw_cards tool?"
- Restart Cursor and try again

#### Debug Mode

To debug MCP connection issues, you can run the server manually:

```bash
# Run the server directly to see any errors
node dist/src/index.js

# Check if the build is working
npm run build && npm start
```

#### Configuration Examples

**Development Setup (with source watching):**
```json
{
  "mcpServers": {
    "tarot-mcp-dev": {
      "command": "npm",
      "args": ["run", "dev"],
      "cwd": "C:/path/to/tarot-mcp-typescript"
    }
  }
}
```

**Production Setup:**
```json
{
  "mcpServers": {
    "tarot-mcp": {
      "command": "node",
      "args": ["dist/src/index.js"],
      "cwd": "C:/path/to/tarot-mcp-typescript",
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
```

### 💡 Pro Tips for Cursor

1. **Bookmark Common Requests**: Save frequently used tarot prompts as Cursor snippets
2. **Use Context**: Reference previous card draws in follow-up questions
3. **Combine with Code**: Ask for tarot-themed code examples or implementations
4. **Image Integration**: Request card images for visual tarot readings
5. **Batch Operations**: Draw multiple cards at once for complex spreads

## 🎴 Tarot Card Structure

### Major Arcana (22 cards)
```typescript
enum MajorArcana {
  Fool = 0, Magician = 1, HighPriestess = 2, Empress = 3,
  Emperor = 4, Hierophant = 5, Lovers = 6, Chariot = 7,
  Strength = 8, Hermit = 9, WheelOfFortune = 10, Justice = 11,
  HangedMan = 12, Death = 13, Temperance = 14, Devil = 15,
  Tower = 16, Star = 17, Moon = 18, Sun = 19,
  Judgement = 20, World = 21
}
```

### Minor Arcana (56 cards)
```typescript
enum Suit { Wands = 'wands', Pentacles = 'pentacles', Swords = 'swords', Cups = 'cups' }
enum CardValue { Ace = 'ace', Two = '2', ..., King = 'king' }
```

## 🛠️ Available Scripts

```bash
npm run build         # Compile TypeScript to JavaScript
npm run build:watch   # Watch mode compilation
npm run start         # Start the MCP server
npm run dev           # Development mode with tsx
npm run test          # Run all tests
npm run test:watch    # Watch mode testing
npm run test:coverage # Generate coverage report
npm run lint          # Run ESLint
npm run lint:fix      # Fix ESLint issues
npm run format        # Format code with Prettier
npm run typecheck     # Type checking without emit
npm run clean         # Clean build artifacts
```

## 🧪 Testing

Comprehensive test suite with 97+ tests covering:

- **Core Domain Logic** - Card creation, deck validation, naming
- **Server Functionality** - MCP protocol compliance, tool handlers
- **Utility Functions** - RNG, shuffling, URI parsing, image loading
- **Error Handling** - Invalid inputs, edge cases, error responses
- **Snapshot Testing** - API response format validation

```bash
# Run tests with coverage
npm run test:coverage

# Watch mode for development
npm run test:watch
```

## 🎯 MCP Tools

### 1. `draw_cards`
Draw random tarot cards from the deck.

**Parameters:**
- `count` (number, 1-78): Number of cards to draw

**Example:**
```typescript
// Draw 3 cards
{ "name": "draw_cards", "arguments": { "count": 3 } }
```

### 2. `get_full_deck`
Get information about all 78 cards in the tarot deck.

**Parameters:** None

**Returns:** Array of all tarot cards with names and URIs

### 3. `fetch_images`
Get base64-encoded images for specific tarot cards.

**Parameters:**
- `uris` (string[]): Array of tarot card URIs

**Example:**
```typescript
{
  "name": "fetch_images",
  "arguments": {
    "uris": ["tarot://card/major/0", "tarot://card/minor/cups/ace"]
  }
}
```

## 🎨 URI Format

Tarot cards use a standardized URI format:

- **Major Arcana:** `tarot://card/major/{number}` (0-21)
- **Minor Arcana:** `tarot://card/minor/{suit}/{value}`

**Examples:**
- `tarot://card/major/0` - The Fool
- `tarot://card/minor/cups/ace` - Ace of Cups
- `tarot://card/minor/swords/king` - King of Swords

## 🖼️ Images

All 78 tarot card images are included in `assets/images/`:

- **Major Arcana:** `major_arcana_{name}.png`
- **Minor Arcana:** `minor_arcana_{suit}_{value}.png`

Images are loaded as base64-encoded data URLs for easy integration.

## 🔧 Development

### Code Quality
- **TypeScript** with strict type checking
- **ESLint** with TypeScript-specific rules
- **Prettier** for consistent formatting
- **Jest** for testing with TypeScript support

### Architecture Principles
- **Clean Architecture** - Domain, application, and infrastructure layers
- **Dependency Injection** - Testable and flexible design
- **Immutable Data** - Readonly interfaces and functional patterns
- **Error Handling** - Proper error types and MCP error responses

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🔗 Related

- [Model Context Protocol](https://modelcontextprotocol.io/) - Official MCP documentation
- [Cursor Editor](https://cursor.sh/) - AI-powered code editor with MCP support
- [Original Swift Implementation](https://github.com/user/swift-tarot-mcp) - Swift version of this server

---

**Built with ❤️ and TypeScript for the AI-powered development community.** 