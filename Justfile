# Justfile for Swift Tarot MCP

# Default recipe - show available commands
default:
    @just --list

# Build the project (debug by default, pass "release" for release build, pass "no-lint" to skip linting)
build *args:
    #!/usr/bin/env bash
    mode="debug"
    skip_lint=false
    
    for arg in {{args}}; do
        case $arg in
            "release")
                mode="release"
                ;;
            "debug")
                mode="debug"
                ;;
            "no-lint")
                skip_lint=true
                ;;
            *)
                echo "Error: unknown argument '$arg'. Use 'debug', 'release', or 'no-lint'"
                exit 1
                ;;
        esac
    done
    
    # Run lint first unless skipped
    if [ "$skip_lint" = false ]; then
        just lint --quiet || echo "Warning: SwiftLint found issues"
    fi
    
    if [ "$mode" = "release" ]; then
        swift build -c release
    else
        swift build
    fi

# Run tests (pass --verbose for verbose output)
test *args="":
    swift test {{args}}

# Clean build artifacts
clean:
    swift package clean

# Install the release binary to /usr/local/bin
install: (build "release")
    #!/usr/bin/env bash
    set -euo pipefail
    BINARY_PATH=".build/release/swift-tarot-MCP"
    INSTALL_PATH="/usr/local/bin/swift-tarot-MCP"
    
    if [ ! -f "$BINARY_PATH" ]; then
        echo "Error: Release binary not found at $BINARY_PATH"
        exit 1
    fi
    
    echo "Installing swift-tarot-MCP to $INSTALL_PATH"
    
    # Check if we need sudo
    if [ -w "/usr/local/bin" ]; then
        cp "$BINARY_PATH" "$INSTALL_PATH"
    else
        sudo cp "$BINARY_PATH" "$INSTALL_PATH"
    fi
    
    echo "Installation complete! You can now run 'swift-tarot-MCP' from anywhere."

# Uninstall the binary from /usr/local/bin
uninstall:
    #!/usr/bin/env bash
    set -euo pipefail
    INSTALL_PATH="/usr/local/bin/swift-tarot-MCP"
    
    if [ ! -f "$INSTALL_PATH" ]; then
        echo "swift-tarot-MCP is not installed at $INSTALL_PATH"
        exit 1
    fi
    
    echo "Removing swift-tarot-MCP from $INSTALL_PATH"
    
    # Check if we need sudo
    if [ -w "/usr/local/bin" ]; then
        rm "$INSTALL_PATH"
    else
        sudo rm "$INSTALL_PATH"
    fi
    
    echo "Uninstallation complete!"

# Build and run the project (debug by default, pass "release" for release, pass "no-lint" to skip linting)
run *args: (build args)
    #!/usr/bin/env bash
    mode="debug"
    
    for arg in {{args}}; do
        case $arg in
            "release")
                mode="release"
                ;;
            "debug")
                mode="debug"
                ;;
            "no-lint")
                # This arg is handled by build, skip it here
                ;;
            *)
                echo "Error: unknown argument '$arg'. Use 'debug', 'release', or 'no-lint'"
                exit 1
                ;;
        esac
    done
    
    if [ "$mode" = "release" ]; then
        .build/release/swift-tarot-MCP
    else
        .build/debug/swift-tarot-MCP
    fi

# Format the code (if you have swift-format installed)
format:
    @if command -v swift-format >/dev/null 2>&1; then \
        swift-format --in-place --recursive Sources Tests; \
        echo "Code formatted successfully"; \
    else \
        echo "swift-format not found. Install with: brew install swift-format"; \
    fi

# Lint the code using SwiftLint plugin (pass --fix to auto-fix violations)
lint *args="":
    swift package plugin --allow-writing-to-package-directory swiftlint {{args}}

# Run all checks (test, format, lint)
check: test format lint

# Show package info
info:
    swift package describe --type json | jq '.'

# Generate Xcode project
xcode:
    swift package generate-xcodeproj