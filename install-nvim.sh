#!/usr/bin/env bash
# Installation script for tree-sitter-datastar in Neovim
set -e

echo "🌟 Installing tree-sitter-datastar for Neovim..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for required tools
if ! command -v gcc &> /dev/null && ! command -v clang &> /dev/null; then
    echo -e "${RED}Error: gcc or clang compiler not found${NC}"
    echo "Please install a C compiler first"
    exit 1
fi

if ! command -v nvim &> /dev/null; then
    echo -e "${RED}Error: Neovim not found${NC}"
    echo "Please install Neovim first"
    exit 1
fi

# Get script directory (where the grammar is)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo -e "${GREEN}✓${NC} Found grammar at: $SCRIPT_DIR"

# Set up directories
PARSER_DIR="$HOME/.local/share/nvim/site/parser"
QUERIES_DIR="$HOME/.local/share/nvim/site/queries/datastar"
HTML_QUERIES_DIR="$HOME/.config/nvim/after/queries/html"

echo "📁 Creating directories..."
mkdir -p "$PARSER_DIR"
mkdir -p "$QUERIES_DIR"
mkdir -p "$HTML_QUERIES_DIR"

# Compile parser
echo "🔨 Compiling parser..."
if command -v gcc &> /dev/null; then
    CC=gcc
else
    CC=clang
fi

$CC -shared -fPIC -o "$PARSER_DIR/datastar.so" "$SCRIPT_DIR/src/parser.c" -I"$SCRIPT_DIR/src"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Parser compiled successfully"
else
    echo -e "${RED}✗${NC} Failed to compile parser"
    exit 1
fi

# Copy query files
echo "📝 Installing query files..."
cp "$SCRIPT_DIR/queries/highlights.scm" "$QUERIES_DIR/"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Highlights query installed"
else
    echo -e "${RED}✗${NC} Failed to copy highlights query"
    exit 1
fi

# Create HTML injection queries
echo "🔗 Setting up HTML injections..."
INJECTION_FILE="$HTML_QUERIES_DIR/injections.scm"

# Check if file exists and has datastar content
if [ -f "$INJECTION_FILE" ] && grep -q "datastar" "$INJECTION_FILE"; then
    echo -e "${YELLOW}⚠${NC}  HTML injection queries already exist"
    echo "   File: $INJECTION_FILE"
    read -p "   Overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "   Skipping injection setup"
        echo -e "${YELLOW}⚠${NC}  Make sure your injections.scm includes datastar injections!"
        SKIP_INJECTION=true
    fi
fi

if [ "$SKIP_INJECTION" != "true" ]; then
    cat > "$INJECTION_FILE" << 'EOF'
; extends

; Inject datastar into attribute VALUES for expressions
((attribute
  (attribute_name) @_attr
  (quoted_attribute_value
    (attribute_value) @injection.content))
  (#match? @_attr "^data-(on|text|bind|show|signals|computed|class|style|attr|effect|init|ref|indicator|on-intersect|on-interval|on-signal-patch|animate|custom-validity|on-raf|on-resize|persist|query-string|replace-url|rocket|scroll-into-view|view-transition|ignore|ignore-morph|preserve-attr|json-signals)")
  (#set! injection.language "datastar"))

; Inject datastar into attribute NAMES to parse data-plugin:modifier
((attribute_name) @injection.content
  (#match? @injection.content "^data-(on|text|bind|show|signals|computed|class|style|attr|effect|init|ref|indicator|on-intersect|on-interval|on-signal-patch|animate|custom-validity|on-raf|on-resize|persist|query-string|replace-url|rocket|scroll-into-view|view-transition|ignore|ignore-morph|preserve-attr|json-signals)")
  (#set! injection.language "datastar")
  (#set! injection.include-children))
EOF
    echo -e "${GREEN}✓${NC} HTML injection queries configured"
fi

# Summary
echo ""
echo "✨ Installation complete!"
echo ""
echo "📍 Files installed:"
echo "   Parser:     $PARSER_DIR/datastar.so"
echo "   Queries:    $QUERIES_DIR/highlights.scm"
echo "   Injections: $INJECTION_FILE"
echo ""
echo "🚀 Next steps:"
echo "   1. Restart Neovim"
echo "   2. Open an HTML file with Datastar attributes"
echo "   3. Run :Inspect to verify highlighting"
echo ""
echo "📖 For more info: https://github.com/YuryKL/tree-sitter-datastar"
