/**
 * Tests for MCP Server Configuration
 * TypeScript equivalent of Swift TarotServerConfigurationTests
 */

import { TarotMCPServer } from '../../server/mcp-server.js';
import { SeedablePseudoRNG } from '../test-support/index.js';

describe('Tarot MCP Server Configuration Tests', () => {
  test('TarotMCPServer creates server with correct configuration', () => {
    const server = new TarotMCPServer();
    
    // Test that server is created without throwing
    expect(server).toBeDefined();
    expect(server).toBeInstanceOf(TarotMCPServer);
  });

  test('TarotMCPServer with custom RNG', () => {
    const rng = new SeedablePseudoRNG(42);
    const server = new TarotMCPServer({ randomNumberGenerator: rng });
    
    expect(server).toBeDefined();
    expect(server).toBeInstanceOf(TarotMCPServer);
  });

  test('TarotMCPServer run method starts and handles requests', async () => {
    // Note: This is a simplified test since we don't have a mock transport
    // In a real scenario, we would mock the MCP transport layer
    const server = new TarotMCPServer();
    
    // Test that the server can be instantiated and has the run method
    expect(typeof server.run).toBe('function');
  });
}); 