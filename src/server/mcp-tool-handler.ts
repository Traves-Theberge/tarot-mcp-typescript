/**
 * MCP tool handler for tarot server operations
 */

import {
  Tool,
  CallToolResult,
  ImageContent,
} from '@modelcontextprotocol/sdk/types.js';

import { TarotCard, CardResponse, getCardName } from '../core/index.js';
import { generateCardURI, parseCardURI, loadCardImageAsBase64, ImageLoadError } from '../utils/index.js';
import { TarotDeckService } from './deck-service.js';

/**
 * Request types for MCP tools
 */
interface DrawCardsRequest {
  count?: number;
}

interface FetchImagesRequest {
  uris: string[];
}

/**
 * MCP tool handler for tarot functionality
 */
export class TarotMCPToolHandler {
  constructor(private readonly deckService: TarotDeckService) {}

  /**
   * Get list of available MCP tools
   */
  getAvailableTools(): Tool[] {
    return [
      {
        name: 'draw_cards',
        description: 'Draw one or more tarot cards',
        inputSchema: {
          type: 'object',
          properties: {
            count: {
              type: 'integer',
              description: 'Number of cards to draw (1-78)',
              minimum: 1,
              maximum: 78,
              default: 1,
            },
          },
        },
      },
      {
        name: 'get_full_deck',
        description: 'Get all 78 tarot cards in the deck',
        inputSchema: {
          type: 'object',
          properties: {},
        },
      },
      {
        name: 'fetch_images',
        description: 'Fetch base64-encoded images for the given tarot card URIs',
        inputSchema: {
          type: 'object',
          properties: {
            uris: {
              type: 'array',
              description: 'Array of tarot card URIs to fetch images for',
              items: {
                type: 'string',
                pattern: '^tarot://card/(major/\\d+|minor/(wands|pentacles|swords|cups)/\\d+)$',
              },
            },
          },
          required: ['uris'],
        },
      },
    ];
  }

  /**
   * Handle MCP tool calls
   */
  async handleToolCall(name: string, args?: unknown): Promise<CallToolResult> {
    try {
      switch (name) {
        case 'draw_cards':
          return this.handleDrawCards(args as DrawCardsRequest);
        case 'get_full_deck':
          return this.handleGetFullDeck();
        case 'fetch_images':
          return this.handleFetchImages(args as FetchImagesRequest);
        default:
          throw new Error(`Unknown tool: ${name}`);
      }
    } catch (error) {
      return {
        content: [
          {
            type: 'text',
            text: `Error: ${error instanceof Error ? error.message : String(error)}`,
          },
        ],
        isError: true,
      };
    }
  }

  /**
   * Handle draw_cards tool
   */
  private handleDrawCards(args?: DrawCardsRequest): CallToolResult {
    const count = args?.count ?? 1;
    const cards = this.deckService.drawCards(count);
    return this.createCardsResponse(cards);
  }

  /**
   * Handle get_full_deck tool
   */
  private handleGetFullDeck(): CallToolResult {
    const cards = this.deckService.getFullDeck();
    return this.createCardsResponse(cards);
  }

  /**
   * Handle fetch_images tool
   */
  private handleFetchImages(args: FetchImagesRequest): CallToolResult {
    if (!args?.uris || !Array.isArray(args.uris)) {
      throw new Error('uris parameter is required and must be an array');
    }

    const content: ImageContent[] = [];

    for (const uri of args.uris) {
      try {
        const card = parseCardURI(uri);
        if (!card) {
          throw new Error(`Invalid tarot card URI: ${uri}`);
        }

        const base64Data = loadCardImageAsBase64(card);
        content.push({
          type: 'image',
          data: base64Data,
          mimeType: 'image/png',
        });
      } catch (error) {
        if (error instanceof ImageLoadError) {
          throw error;
        }
        throw new Error(`Failed to load image for URI: ${uri}`);
      }
    }

    return { content };
  }

  /**
   * Create a response with card data in JSON format
   */
  private createCardsResponse(cards: readonly TarotCard[]): CallToolResult {
    const cardResponses: CardResponse[] = cards.map(card => ({
      name: getCardName(card),
      uri: generateCardURI(card),
    }));

    const jsonString = JSON.stringify(cardResponses, null, 2);

    return {
      content: [
        {
          type: 'text',
          text: jsonString,
        },
      ],
    };
  }
} 