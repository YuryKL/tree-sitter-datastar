#!/usr/bin/env bash
# Installation script for tree-sitter-datastar
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EDITOR="${1:-}"
TEMPLATES="${2:-html}"

show_usage() {
    echo "Usage: $0 <nvim|helix> [templates]"
    echo ""
    echo "Install tree-sitter-datastar for your editor:"
    echo "  nvim   - Install for Neovim"
    echo "  helix  - Install for Helix"
    echo ""
    echo "Optional template languages (comma-separated):"
    echo "  html       - HTML (default)"
    echo "  templ      - Go templates"
    echo "  heex       - Phoenix/Elixir templates"
    echo "  blade      - Laravel/PHP templates"
    echo ""
    echo "Examples:"
    echo "  $0 nvim                    # HTML only"
    echo "  $0 nvim html,templ,heex    # HTML + Templ + HEEx"
    echo "  $0 nvim blade              # Blade only"
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

    echo "🔗 Setting up template language injections..."

    # Parse template languages
    IFS=',' read -ra TEMPLATE_ARRAY <<< "$TEMPLATES"

    for template in "${TEMPLATE_ARRAY[@]}"; do
        template=$(echo "$template" | tr '[:upper:]' '[:lower:]' | xargs)

        case "$template" in
            html)
                TEMPLATE_DIR="$HTML_QUERIES_DIR"
                INJECTION_SRC="injections-nvim.scm"
                ;;
            templ)
                TEMPLATE_DIR="$HOME/.config/nvim/after/queries/templ"
                INJECTION_SRC="injections-nvim.scm"
                ;;
            heex)
                TEMPLATE_DIR="$HOME/.config/nvim/after/queries/heex"
                INJECTION_SRC="injections-nvim.scm"
                ;;
            blade)
                TEMPLATE_DIR="$HOME/.config/nvim/after/queries/blade"
                INJECTION_SRC="injections-nvim.scm"
                ;;
            *)
                echo -e "${YELLOW}⚠${NC}  Unknown template language: $template (skipping)"
                continue
                ;;
        esac

        mkdir -p "$TEMPLATE_DIR"
        INJECTION_DEST="$TEMPLATE_DIR/injections.scm"

        # Create injection file with appropriate header
        if [ "$template" = "blade" ]; then
            echo "; inherits: html" > "$INJECTION_DEST"
        else
            echo "; extends" > "$INJECTION_DEST"
        fi
        echo "" >> "$INJECTION_DEST"

        # Append the injection queries (skip first line if it's a header)
        tail -n +2 "$SCRIPT_DIR/queries/$INJECTION_SRC" | grep -v "^; extends$" >> "$INJECTION_DEST"

        echo -e "${GREEN}✓${NC} Configured $template injections: $TEMPLATE_DIR/injections.scm"
    done

    echo ""
    echo "✨ Installation complete!"
    echo ""
    echo "📍 Files installed:"
    echo "   Parser:     $PARSER_DIR/datastar.so"
    echo "   Queries:    $QUERIES_DIR/ (highlights, indents, textobjects)"
    echo "   Templates:  $(echo ${TEMPLATE_ARRAY[@]} | tr ' ' ', ')"
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

    echo "🔗 Setting up template language injections..."

    # Parse template languages (Helix only supports HTML currently)
    IFS=',' read -ra TEMPLATE_ARRAY <<< "$TEMPLATES"

    for template in "${TEMPLATE_ARRAY[@]}"; do
        template=$(echo "$template" | tr '[:upper:]' '[:lower:]' | xargs)

        case "$template" in
            html)
                TEMPLATE_DIR="$HTML_QUERIES_DIR"
                INJECTION_SRC="injections-helix.scm"
                ;;
            *)
                echo -e "${YELLOW}⚠${NC}  Helix only supports 'html' template (skipping: $template)"
                continue
                ;;
        esac

        cp "$SCRIPT_DIR/queries/$INJECTION_SRC" "$TEMPLATE_DIR/injections.scm"
        echo -e "${GREEN}✓${NC} Configured $template injections: $TEMPLATE_DIR/injections.scm"
    done

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
