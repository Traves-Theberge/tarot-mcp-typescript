# Tarot MCP TypeScript Server

A **TypeScript** implementation of a **Model Context Protocol (MCP)** server that provides tarot card reading functionality for AI assistants like Claude in Cursor.

## 🎯 Overview

This MCP server offers three powerful tools for tarot card interactions:

- **`draw_cards`** - Draw one or more tarot cards with optional seeded randomization
- **`get_full_deck`** - Get information about all 78 tarot cards in the deck  
- **`fetch_images`** - Retrieve base64-encoded images for specific tarot cards

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

### Cursor Integration

Add to your Cursor MCP configuration (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "tarot-mcp-typescript": {
      "command": "node",
      "args": ["C:/path/to/tarot-mcp-typescript/dist/src/index.js"]
    }
  }
}
```

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