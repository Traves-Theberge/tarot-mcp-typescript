/**
 * Main MCP server implementation for tarot functionality
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  ListPromptsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';

import { RandomNumberGenerator, SystemRandomNumberGenerator } from '../utils/index.js';
import { TarotDeckService } from './deck-service.js';
import { TarotMCPToolHandler } from './mcp-tool-handler.js';

/**
 * Server configuration
 */
interface ServerConfig {
  name?: string;
  version?: string;
  randomNumberGenerator?: RandomNumberGenerator;
}

/**
 * Main Tarot MCP Server class
 */
export class TarotMCPServer {
  private readonly server: Server;
  private readonly toolHandler: TarotMCPToolHandler;

  constructor(config: ServerConfig = {}) {
    const {
      name = 'Tarot MCP Server',
      version = '1.0.0',
      randomNumberGenerator = new SystemRandomNumberGenerator(),
    } = config;

    // Initialize services
    const deckService = new TarotDeckService(randomNumberGenerator);
    this.toolHandler = new TarotMCPToolHandler(deckService);

    // Initialize MCP server
    this.server = new Server(
      { name, version },
      {
        capabilities: {
          tools: {},
          prompts: {},
        },
      }
    );

    this.setupHandlers();
  }

  /**
   * Set up MCP request handlers
   */
  private setupHandlers(): void {
    // Handle tool listing
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: this.toolHandler.getAvailableTools(),
    }));

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async request => {
      const { name, arguments: args } = request.params;
      return await this.toolHandler.handleToolCall(name, args);
    });

    // Handle prompt listing (empty list, matching Swift implementation)
    this.server.setRequestHandler(ListPromptsRequestSchema, async () => ({
      prompts: [],
    }));
  }

  /**
   * Start the server with stdio transport
   */
  async run(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);

    // Set up graceful shutdown handlers
    this.setupShutdownHandlers();
  }

  /**
   * Set up graceful shutdown handlers
   */
  private setupShutdownHandlers(): void {
    const shutdown = async (): Promise<void> => {
      try {
        await this.server.close();
        process.exit(0);
      } catch (error) {
        console.error('Error during shutdown:', error);
        process.exit(1);
      }
    };

    process.on('SIGINT', shutdown);
    process.on('SIGTERM', shutdown);
  }

  /**
   * Close the server
   */
  async close(): Promise<void> {
    await this.server.close();
  }
} 