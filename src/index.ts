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
    
    console.log('Server is now running and listening for MCP requests...');
  } catch (error) {
    console.error('Failed to start Tarot MCP Server:', error);
    process.exit(1);
  }
}

// Always run the main function when this file is executed
main().catch((error) => {
  console.error('Unhandled error:', error);
  process.exit(1);
}); 