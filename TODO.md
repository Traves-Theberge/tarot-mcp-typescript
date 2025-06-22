# TODO

## Pending Tasks

### Create snapshot tests for actual image data from resource calls
- **Priority**: Medium
- **Description**: Add snapshot tests to verify that the `readResource` method in `TarotServerHandler` correctly serves actual image data for tarot card resources
- **Location**: `Tests/TarotMCPTests/TarotServerResourcesTests.swift`
- **Details**: 
  - Test that calling `readResource` with a valid tarot URI (e.g., `tarot://card/major/0`) returns actual PNG image data
  - Use snapshot testing to verify the binary content is consistent
  - Test both major and minor arcana cards
  - Ensure the returned MIME type is correct (`image/png`)
- **Context**: Resource bundling is working and all current tests pass, but we need to verify the actual image serving functionality works end-to-end