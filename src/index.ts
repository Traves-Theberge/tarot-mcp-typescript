#!/usr/bin/env node

/**
 * Tarot MCP TypeScript Server
 * 
 * A Model Context Protocol (MCP) server that provides tarot card reading functionality.
 * This server offers three main tools:
 * - draw_cards: Draw one or more tarot cards
 * - get_full_deck: Get information about all 78 tarot cards
 * - fetch_images: Get base64-encoded images for tarot cards
 */

import { TarotMCPServer } from './server/index.js';

async function main(): Promise<void> {
  try {
    console.log('Starting Tarot MCP Server...');
    
    const server = new TarotMCPServer();
    
    console.log('Server created, starting run...');
    await server.run();
  } catch (error) {
    console.error('Failed to start Tarot MCP Server:', error);
    process.exit(1);
  }
}

// Only run if this file is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((error) => {
    console.error('Unhandled error:', error);
    process.exit(1);
  });
} 