#!/usr/bin/env bash
# Installation script for tree-sitter-datastar
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EDITOR="${1:-}"

show_usage() {
    echo "Usage: $0 <nvim|helix>"
    echo ""
    echo "Install tree-sitter-datastar for your editor:"
    echo "  nvim   - Install for Neovim"
    echo "  helix  - Install for Helix"
    exit 1
}

if [ -z "$EDITOR" ]; then
    show_usage
fi

case "$EDITOR" in
    nvim|neovim)
        EDITOR_NAME="Neovim"
        EDITOR_CMD="nvim"
        ;;
    helix|hx)
        EDITOR_NAME="Helix"
        EDITOR_CMD="hx"
        ;;
    *)
        echo -e "${RED}Error: Unknown editor '$EDITOR'${NC}"
        show_usage
        ;;
esac

echo "🌟 Installing tree-sitter-datastar for $EDITOR_NAME..."

# Check for C compiler
if ! command -v gcc &> /dev/null && ! command -v clang &> /dev/null; then
    echo -e "${RED}Error: gcc or clang compiler not found${NC}"
    echo "Please install a C compiler first"
    exit 1
fi

if command -v gcc &> /dev/null; then
    CC=gcc
else
    CC=clang
fi

# Check for editor
if ! command -v "$EDITOR_CMD" &> /dev/null; then
    echo -e "${RED}Error: $EDITOR_NAME not found${NC}"
    echo "Please install $EDITOR_NAME first"
    exit 1
fi

echo -e "${GREEN}✓${NC} Found grammar at: $SCRIPT_DIR"

# Install based on editor
if [ "$EDITOR" = "nvim" ] || [ "$EDITOR" = "neovim" ]; then
    PARSER_DIR="$HOME/.local/share/nvim/site/parser"
    QUERIES_DIR="$HOME/.local/share/nvim/site/queries/datastar"
    HTML_QUERIES_DIR="$HOME/.config/nvim/after/queries/html"
    HIGHLIGHTS_FILE="highlights.scm"
    INJECTION_FILE="injections-nvim.scm"

    echo "📁 Creating directories..."
    mkdir -p "$PARSER_DIR"
    mkdir -p "$QUERIES_DIR"
    mkdir -p "$HTML_QUERIES_DIR"

    echo "🔨 Compiling parser..."
    $CC -shared -fPIC -o "$PARSER_DIR/datastar.so" \
        "$SCRIPT_DIR/src/parser.c" "$SCRIPT_DIR/src/scanner.c" -I"$SCRIPT_DIR/src"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Parser compiled successfully"
    else
        echo -e "${RED}✗${NC} Failed to compile parser"
        exit 1
    fi

    echo "📝 Installing query files..."
    cp "$SCRIPT_DIR/queries/$HIGHLIGHTS_FILE" "$QUERIES_DIR/"
    cp "$SCRIPT_DIR/queries/indents.scm" "$QUERIES_DIR/"
    cp "$SCRIPT_DIR/queries/textobjects.scm" "$QUERIES_DIR/"
    echo -e "${GREEN}✓${NC} Query files installed"

    echo "🔗 Setting up HTML injections..."
    INJECTION_DEST="$HTML_QUERIES_DIR/injections.scm"

    if [ -f "$INJECTION_DEST" ] && grep -q "datastar" "$INJECTION_DEST"; then
        echo -e "${YELLOW}⚠${NC}  HTML injection queries already exist"
        echo "   File: $INJECTION_DEST"
        read -p "   Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "   Skipping injection setup"
            echo -e "${YELLOW}⚠${NC}  Make sure your injections.scm includes datastar!"
            SKIP_INJECTION=true
        fi
    fi

    if [ "$SKIP_INJECTION" != "true" ]; then
        cp "$SCRIPT_DIR/queries/$INJECTION_FILE" "$INJECTION_DEST"
        echo -e "${GREEN}✓${NC} HTML injection queries configured"
    fi

    echo ""
    echo "✨ Installation complete!"
    echo ""
    echo "📍 Files installed:"
    echo "   Parser:     $PARSER_DIR/datastar.so"
    echo "   Queries:    $QUERIES_DIR/ (highlights, indents, textobjects)"
    echo "   Injections: $INJECTION_DEST"
    echo ""
    echo "🚀 Next steps:"
    echo "   1. Register the parser in your init.vim/init.lua:"
    echo ""
    echo "      lua << EOF"
    echo "      local parser_config = require('nvim-treesitter.parsers').get_parser_configs()"
    echo "      parser_config.datastar = {"
    echo "        install_info = {"
    echo "          url = \"$SCRIPT_DIR\","
    echo "          files = {\"src/parser.c\", \"src/scanner.c\"},"
    echo "          branch = \"main\","
    echo "          generate_requires_npm = false,"
    echo "          requires_generate_from_grammar = false,"
    echo "        },"
    echo "      }"
    echo "      EOF"
    echo ""
    echo "   2. Recommended: Install 'query' parser for .scm file syntax highlighting:"
    echo "      Add 'query' to your ensure_installed list, or run: :TSInstall query"
    echo ""
    echo "   3. Restart Neovim"
    echo "   4. Open an HTML file with Datastar attributes"
    echo "   5. Run :Inspect to verify highlighting"

elif [ "$EDITOR" = "helix" ] || [ "$EDITOR" = "hx" ]; then
    PARSER_DIR="$HOME/.config/helix/runtime/grammars"
    QUERIES_DIR="$HOME/.config/helix/runtime/queries/datastar"
    HTML_QUERIES_DIR="$HOME/.config/helix/runtime/queries/html"
    HIGHLIGHTS_FILE="highlights-helix.scm"
    INJECTION_FILE="injections-helix.scm"

    echo "📁 Creating directories..."
    mkdir -p "$PARSER_DIR"
    mkdir -p "$QUERIES_DIR"
    mkdir -p "$HTML_QUERIES_DIR"

    echo "🔨 Compiling parser..."
    $CC -shared -fPIC -o "$PARSER_DIR/datastar.so" \
        "$SCRIPT_DIR/src/parser.c" "$SCRIPT_DIR/src/scanner.c" -I"$SCRIPT_DIR/src"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Parser compiled successfully"
    else
        echo -e "${RED}✗${NC} Failed to compile parser"
        exit 1
    fi

    echo "📝 Installing query files..."
    cp "$SCRIPT_DIR/queries/$HIGHLIGHTS_FILE" "$QUERIES_DIR/highlights.scm"
    cp "$SCRIPT_DIR/queries/indents.scm" "$QUERIES_DIR/"
    cp "$SCRIPT_DIR/queries/textobjects.scm" "$QUERIES_DIR/"
    echo -e "${GREEN}✓${NC} Query files installed"

    echo "🔗 Setting up HTML injections..."
    INJECTION_DEST="$HTML_QUERIES_DIR/injections.scm"

    if [ -f "$INJECTION_DEST" ] && grep -q "datastar" "$INJECTION_DEST"; then
        echo -e "${YELLOW}⚠${NC}  HTML injection queries already exist"
        echo "   File: $INJECTION_DEST"
        read -p "   Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "   Skipping injection setup"
            echo -e "${YELLOW}⚠${NC}  Make sure your injections.scm includes datastar!"
            SKIP_INJECTION=true
        fi
    fi

    if [ "$SKIP_INJECTION" != "true" ]; then
        cp "$SCRIPT_DIR/queries/$INJECTION_FILE" "$INJECTION_DEST"
        echo -e "${GREEN}✓${NC} HTML injection queries configured"
    fi

    echo ""
    echo "⚙️  Language configuration required!"
    echo ""
    echo "Add to ~/.config/helix/languages.toml:"
    echo ""
    echo "[[language]]"
    echo "name = \"datastar\""
    echo "scope = \"source.datastar\""
    echo "file-types = []"
    echo "roots = []"
    echo "comment-token = \"//\""
    echo "indent = { tab-width = 2, unit = \"  \" }"
    echo ""
    echo "[[grammar]]"
    echo "name = \"datastar\""
    echo "source = { path = \"$SCRIPT_DIR\" }"
    echo ""
    echo "✨ Installation complete!"
    echo ""
    echo "📍 Files installed:"
    echo "   Parser:     $PARSER_DIR/datastar.so"
    echo "   Queries:    $QUERIES_DIR/"
    echo "   Injections: $INJECTION_DEST"
    echo ""
    echo "🚀 Next steps:"
    echo "   1. Add language config to languages.toml (see above)"
    echo "   2. Restart Helix"
    echo "   3. Run: hx --health datastar"
fi

echo ""
echo "📖 For more info: https://github.com/YuryKL/tree-sitter-datastar"
