/**
 * Tests for MCP Tool Handler functionality
 * TypeScript equivalent of Swift TarotServerHandlerTests
 */

import { TarotCardError } from '../../core/index.js';
import { TarotMCPToolHandler } from '../../server/mcp-tool-handler.js';
import { TarotDeckService } from '../../server/deck-service.js';
import { SeedablePseudoRNG } from '../test-support/index.js';

describe('MCP Tool Handler Tests', () => {
  describe('TarotToolRequest Error Handling', () => {
    test('init error description is good', async () => {
      const deckService = new TarotDeckService(new SeedablePseudoRNG(42));
      const handler = new TarotMCPToolHandler(deckService);
      
      const result = await handler.handleToolCall('draw_cards', { count: 0 });
      expect(result.isError).toBe(true);
      expect(result.content[0]?.type).toBe('text');
      if (result.content[0]?.type === 'text') {
        expect(result.content[0].text).toContain('Invalid card count: 0. Count must be between 1 and 78.');
      }
    });
  });

  describe('draw_cards tool', () => {
    test('returns valid response for single card', async () => {
      const deckService = new TarotDeckService(new SeedablePseudoRNG(42));
      const handler = new TarotMCPToolHandler(deckService);
      const result = await handler.handleToolCall('draw_cards', {});

      expect(result.content).toHaveLength(1);
      expect(result.content[0]?.type).toBe('text');
      
      if (result.content[0]?.type === 'text') {
        const jsonData = JSON.parse(result.content[0].text as string);
        expect(Array.isArray(jsonData)).toBe(true);
        expect(jsonData).toHaveLength(1);
        
        const card = jsonData[0];
        expect(typeof card.name).toBe('string');
        expect(typeof card.imageURI).toBe('string');
      }
    });

    test('produces deterministic results for single card', async () => {
      const deckService1 = new TarotDeckService(new SeedablePseudoRNG(54321));
      const deckService2 = new TarotDeckService(new SeedablePseudoRNG(54321));
      const handler1 = new TarotMCPToolHandler(deckService1);
      const handler2 = new TarotMCPToolHandler(deckService2);

      const result1 = await handler1.handleToolCall('draw_cards', {});
      const result2 = await handler2.handleToolCall('draw_cards', {});

      expect(result1.content).toHaveLength(1);
      expect(result2.content).toHaveLength(1);

      if (result1.content[0]?.type === 'text' && result2.content[0]?.type === 'text') {
        expect(result1.content[0].text).toBe(result2.content[0].text);
        
        // Snapshot test for deterministic output
        expect(result1.content[0].text).toMatchSnapshot();
      }
    });

    test('with default count', async () => {
      const deckService = new TarotDeckService(new SeedablePseudoRNG(98765));
      const handler = new TarotMCPToolHandler(deckService);
      const result = await handler.handleToolCall('draw_cards', {});

      expect(result.content).toHaveLength(1);
      
      if (result.content[0]?.type === 'text') {
        const jsonData = JSON.parse(result.content[0].text as string);
        expect(jsonData).toHaveLength(1);
        
        const card = jsonData[0];
        expect(card.name).toBe('Ten of Cups');
        expect(card.imageURI).toBe('tarot://card/minor/cups/10');
      }
    });

    test('with custom count', async () => {
      const deckService = new TarotDeckService(new SeedablePseudoRNG(11111));
      const handler = new TarotMCPToolHandler(deckService);
      const result = await handler.handleToolCall('draw_cards', { count: 7 });

      expect(result.content).toHaveLength(1);
      
      if (result.content[0]?.type === 'text') {
        const jsonData = JSON.parse(result.content[0].text as string);
        expect(jsonData).toHaveLength(7);

        // Verify each card has name and image
        for (const card of jsonData) {
          expect(typeof card.name).toBe('string');
          expect(typeof card.imageURI).toBe('string');
          expect(card.imageURI).toMatch(/^tarot:\/\/card\//);
        }
      }
    });

    test('returns errors for invalid counts', async () => {
      const deckService = new TarotDeckService(new SeedablePseudoRNG(22222));
      const handler = new TarotMCPToolHandler(deckService);

      // Test upper bound validation
      const result1 = await handler.handleToolCall('draw_cards', { count: 79 });
      expect(result1.isError).toBe(true);

      // Test lower bound validation
      const result2 = await handler.handleToolCall('draw_cards', { count: 0 });
      expect(result2.isError).toBe(true);

      // Test negative values
      const result3 = await handler.handleToolCall('draw_cards', { count: -5 });
      expect(result3.isError).toBe(true);
    });
  });

  describe('get_full_deck tool', () => {
    test('returns complete deck', async () => {
      const deckService = new TarotDeckService(new SeedablePseudoRNG(42));
      const handler = new TarotMCPToolHandler(deckService);
      const result = await handler.handleToolCall('get_full_deck', {});

      expect(result.content).toHaveLength(1);
      
      if (result.content[0]?.type === 'text') {
        const jsonData = JSON.parse(result.content[0].text as string);
        expect(jsonData).toHaveLength(78);

        // Check that specific cards are present
        const cardNames = jsonData.map((card: any) => card.name);
        expect(cardNames).toContain('The Fool');
        expect(cardNames).toContain('Ace of Wands');
        expect(cardNames).toContain('King of Cups');

        // Verify each card has name and image
        for (const card of jsonData) {
          expect(typeof card.name).toBe('string');
          expect(typeof card.imageURI).toBe('string');
          expect(card.imageURI).toMatch(/^tarot:\/\/card\//);
        }
      }
    });

    test('produces deterministic results', async () => {
      const deckService = new TarotDeckService(new SeedablePseudoRNG(33333));
      const handler = new TarotMCPToolHandler(deckService);
      const result = await handler.handleToolCall('get_full_deck', {});

      expect(result.content).toHaveLength(1);
      
      if (result.content[0]?.type === 'text') {
        // Snapshot test for deterministic output
        expect(result.content[0].text).toMatchSnapshot();
      }
    });
  });

  describe('fetch_images tool', () => {
    test.skip('returns images for valid URIs', async () => {
      // Skipped because image files are not available in test environment
      const deckService = new TarotDeckService(new SeedablePseudoRNG(42));
      const handler = new TarotMCPToolHandler(deckService);
      const uris = [
        'tarot://card/major/0',
        'tarot://card/minor/cups/1'
      ];
      
      const result = await handler.handleToolCall('fetch_images', { uris });

      expect(result.content).toHaveLength(2);
      
      for (const content of result.content) {
        expect(content.type).toBe('image');
        if (content.type === 'image') {
          expect(typeof content.data).toBe('string');
          expect(content.mimeType).toBe('image/png');
        }
      }
    });

    test('returns error for invalid URIs', async () => {
      const deckService = new TarotDeckService(new SeedablePseudoRNG(42));
      const handler = new TarotMCPToolHandler(deckService);
      const invalidUris = ['invalid://uri'];
      
      const result = await handler.handleToolCall('fetch_images', { uris: invalidUris });
      expect(result.isError).toBe(true);
    });
  });

  describe('Error Handling', () => {
    test('unknown tool returns error', async () => {
      const deckService = new TarotDeckService(new SeedablePseudoRNG(42));
      const handler = new TarotMCPToolHandler(deckService);

      const result = await handler.handleToolCall('unknown_tool', {});
      expect(result.isError).toBe(true);
    });

    test('error propagation works correctly', async () => {
      const deckService = new TarotDeckService(new SeedablePseudoRNG(42));
      const handler = new TarotMCPToolHandler(deckService);

      // Test that validation errors are properly propagated
      const result1 = await handler.handleToolCall('draw_cards', { count: 0 });
      expect(result1.isError).toBe(true);

      const result2 = await handler.handleToolCall('draw_cards', { count: 79 });
      expect(result2.isError).toBe(true);
    });
  });

  describe('Tool Configuration', () => {
    test('getAvailableTools returns correct tool list', () => {
      const deckService = new TarotDeckService(new SeedablePseudoRNG(42));
      const handler = new TarotMCPToolHandler(deckService);
      const tools = handler.getAvailableTools();

      expect(tools).toHaveLength(3);

      const toolNames = tools.map(tool => tool.name);
      expect(toolNames).toContain('draw_cards');
      expect(toolNames).toContain('get_full_deck');
      expect(toolNames).toContain('fetch_images');

      // Verify draw_cards has proper schema
      const drawCardsTool = tools.find(tool => tool.name === 'draw_cards');
      expect(drawCardsTool).toBeDefined();
      expect(drawCardsTool?.inputSchema).toBeDefined();
    });

    test('tools are configured correctly', () => {
      const deckService = new TarotDeckService(new SeedablePseudoRNG(42));
      const handler = new TarotMCPToolHandler(deckService);
      const tools = handler.getAvailableTools();
      
      expect(tools).toHaveLength(3);
      expect(tools.some(tool => tool.name === 'draw_cards')).toBe(true);
      expect(tools.some(tool => tool.name === 'get_full_deck')).toBe(true);
      expect(tools.some(tool => tool.name === 'fetch_images')).toBe(true);
    });

    test('handlers respond correctly', async () => {
      const deckService = new TarotDeckService(new SeedablePseudoRNG(12345));
      const handler = new TarotMCPToolHandler(deckService);

      // Test equivalent to ListTools
      const tools = handler.getAvailableTools();
      expect(tools).toHaveLength(3);

      // Test equivalent to CallTool - single card
      const singleCardResult = await handler.handleToolCall('draw_cards', {});
      expect(singleCardResult.content).toHaveLength(1);

      // Test equivalent to CallTool - multiple cards
      const multipleCardResult = await handler.handleToolCall('draw_cards', { count: 3 });
      expect(multipleCardResult.content).toHaveLength(1);

      // Test equivalent to CallTool - full deck
      const fullDeckResult = await handler.handleToolCall('get_full_deck', {});
      expect(fullDeckResult.content).toHaveLength(1);
    });

    test('handles invalid tool calls correctly', async () => {
      const deckService = new TarotDeckService(new SeedablePseudoRNG(42));
      const handler = new TarotMCPToolHandler(deckService);

      const result = await handler.handleToolCall('invalid_tool', {});
      expect(result.isError).toBe(true);
    });

    test('registration logic works correctly', async () => {
      const deckService = new TarotDeckService(new SeedablePseudoRNG(42));
      const handler = new TarotMCPToolHandler(deckService);

      // Test the registration logic that TarotMCPServer.run() uses
      const tools = handler.getAvailableTools();
      expect(tools).toHaveLength(3);

      // Test CallTool registration with various scenarios
      const drawSingleResult = await handler.handleToolCall('draw_cards', {});
      expect(drawSingleResult.content).toHaveLength(1);

      const drawMultipleResult = await handler.handleToolCall('draw_cards', { count: 5 });
      expect(drawMultipleResult.content).toHaveLength(1);
    });
  });
}); 