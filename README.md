# tree-sitter-datastar

A [Tree-sitter](https://tree-sitter.github.io) grammar for [Datastar](https://data-star.dev) expressions and attributes.

MIT License, do with it as you please.
Rocket is not supported yet

## Features

This grammar provides comprehensive parsing for:

### Datastar Attribute Names
- **Standard plugins**: `data-on:click`, `data-bind:value`, `data-show`, etc.
- **Pro plugins**: `data-animate`, `data-persist`, `data-view-transition`, etc.
- **Modifier syntax**: `data-on:click__debounce.500ms`, `data-signals:foo__ifmissing`, `data-on-raf__throttle.10ms`
- **Full AST structure**: Plugin names, keys, and modifiers are individually parsed for static analysis

### JavaScript-Compatible Expressions
- **Signal references**: `$user.name`, `$items[0]`, `$data?.user?.email`
- **Action calls**: `@get('/api/users')`, `@post('/data', {id: $userId})`
- Ternary operators, arrow functions, object/array literals
- **Complex expressions**: `$visible = $count > 5 ? 'show' : 'hide'`

### HTML Template Integration
- **Injection-based parsing**: Works within existing HTML parsers
- **Template language support**: Currently compatible with Templ, HEEX, and Blade
- **Dual injection**: Parses both attribute names and values separately
- **No file associations needed**: Works through Tree-sitter injection queries

## Supported Datastar Plugins

**Standard + Pro (31 total):**
`attr`, `bind`, `class`, `computed`, `effect`, `ignore`, `ignore-morph`, `indicator`, `init`, `json-signals`, `on`, `on-intersect`, `on-interval`, `on-signal-patch`, `on-signal-patch-filter`, `preserve-attr`, `ref`, `show`, `signals`, `style`, `text`, `animate`, `custom-validity`, `on-raf`, `on-resize`, `persist`, `query-string`, `replace-url`, `rocket`, `scroll-into-view`, `view-transition`

## Example

```html
<div data-signals='{"count": 0, "user": {"name": "John"}}'>
  <!-- Signal references -->
  <span data-text="$count"></span>
  <h1 data-text="$user.name"></h1>

  <!-- Event handlers with expressions -->
  <button data-on:click="$count++">Increment</button>
  <button data-on:click__debounce.500ms="@post('/api')">Debounced</button>

  <!-- Plugin with modifier (no key) -->
  <div data-on-raf__throttle.10ms="$x = $y + 1"></div>

  <!-- Signal modifiers -->
  <div data-signals:my-signal__case.kebab="1"></div>
  <div data-signals:foo__ifmissing="42"></div>

  <!-- Conditional display -->
  <div data-show="$count > 5">Count is greater than 5!</div>

  <!-- Action calls with arguments -->
  <button data-on:click="@get('/api/data')">Fetch</button>
  <button data-on:click="@post('/api/save', {count: $count})">Save</button>

  <!-- Complex expressions -->
  <input data-on:input="$user.name = event.target.value" />
  <div data-class:active="$count % 2 === 0">Even count styling</div>
</div>
```

## Installation

### Neovim (Recommended)

#### Quick Install

```bash
git clone https://github.com/YuryKL/tree-sitter-datastar.git ~/.local/share/tree-sitter-datastar
cd ~/.local/share/tree-sitter-datastar
./install.sh nvim

```
You can also specify which injections to install, by default only HTML is installed
Supported options: html,templ,blade,heex
```bash
./install.sh nvim html,templ 
```
Then restart Neovim!

#### Manual Installation

**Prerequisites:**
- Neovim 0.9+ with tree-sitter support
- `gcc` or `clang` compiler

**Steps:**

1. **Clone this repository:**
```bash
git clone https://github.com/YuryKL/tree-sitter-datastar.git ~/.local/share/tree-sitter-datastar
cd ~/.local/share/tree-sitter-datastar
```

2. **Compile and install the parser:**
```bash
mkdir -p ~/.local/share/nvim/site/parser
gcc -shared -fPIC -o ~/.local/share/nvim/site/parser/datastar.so \
  src/parser.c src/scanner.c -I./src
```

3. **Install query files:**
```bash
mkdir -p ~/.local/share/nvim/site/queries/datastar
cp queries/highlights.scm ~/.local/share/nvim/site/queries/datastar/
cp queries/indents.scm ~/.local/share/nvim/site/queries/datastar/
cp queries/textobjects.scm ~/.local/share/nvim/site/queries/datastar/
```

4. **Configure HTML injections:**
```bash
mkdir -p ~/.config/nvim/after/queries/html
cp queries/injections-nvim.scm ~/.config/nvim/after/queries/html/injections.scm
```

5. **Register parser** in your nvim config (init.vim or init.lua):
```lua
local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
parser_config.datastar = {
  install_info = {
    url = "~/.local/share/tree-sitter-datastar",
    files = {"src/parser.c", "src/scanner.c"},
    branch = "main",
  },
}
```

6. **Recommended:** Install query parser for .scm syntax highlighting: `:TSInstall query`

7. **Restart Neovim** and open an HTML file with Datastar attributes!

#### Verification

Open any HTML file with Datastar and run `:Inspect` with your cursor on a datastar attribute. You should see:
- Attribute names parsed with `plugin_name`, `plugin_key`, `modifier` nodes
- Attribute values parsed with `signal_reference`, `action_call`, etc.

### Helix

✅ **Status**: Working - Syntax highlighting functional, but AST inspection limited compared to Neovim.

**Note**: Helix's inspection tools don't expose injected nodes the same way Neovim's `:Inspect` does. Highlighting works, but tree-sitter scope inspection will show less detail.

#### Quick Install

```bash
git clone https://github.com/YuryKL/tree-sitter-datastar.git ~/.local/share/tree-sitter-datastar
cd ~/.local/share/tree-sitter-datastar
./install.sh helix
```

Then follow the instructions to add the language configuration to `~/.config/helix/languages.toml`.

#### Manual Installation

1. **Build the parser:**
```bash
git clone https://github.com/YuryKL/tree-sitter-datastar.git ~/tree-sitter-datastar
cd ~/tree-sitter-datastar
mkdir -p ~/.config/helix/runtime/grammars
gcc -shared -fPIC -o ~/.config/helix/runtime/grammars/datastar.so \
  src/parser.c src/scanner.c -I./src
```

2. **Install queries:**
```bash
mkdir -p ~/.config/helix/runtime/queries/datastar
cp queries/highlights-helix.scm ~/.config/helix/runtime/queries/datastar/highlights.scm
cp queries/indents.scm ~/.config/helix/runtime/queries/datastar/
cp queries/textobjects.scm ~/.config/helix/runtime/queries/datastar/
```

3. **Configure HTML injections:**
```bash
cp queries/injections-helix.scm ~/.config/helix/runtime/queries/html/injections.scm
```

4. **Configure language in `~/.config/helix/languages.toml`:**
```toml
[[language]]
name = "datastar"
scope = "source.datastar"
file-types = []
roots = []
comment-token = "//"
indent = { tab-width = 2, unit = "  " }

[[grammar]]
name = "datastar"
source = { path = "/home/YOUR_USERNAME/tree-sitter-datastar" }
```

5. Restart Helix and run `hx --health datastar` to verify.

### VS Code / Other Editors

Emacs and VS Code can be configured similarly using 3rd party tree-sitter extensions. Contributions welcome!

## How It Works

This grammar is designed to be **injected** into HTML files, not used standalone:

1. **Attribute Value Injection**: When HTML contains `data-on:click="$count++"`, the value `$count++` is parsed as datastar expressions
2. **Attribute Name Injection**: The attribute name `data-on:click__debounce.500ms` is parsed to extract:
   - `plugin_name`: `on`
   - `plugin_key`: `click`
   - `modifier`: `debounce.500ms`
3. **External Scanner**: Uses a custom C scanner to properly tokenize `plugin_key` by stopping at the `__` delimiter
4. **Datastar Grammar**: Parses JavaScript-like expressions with Datastar-specific constructs:
   - **Signal references**: `$identifier` with property chains, optional chaining, computed access
   - **Action calls**: `@identifier(args)` with full argument parsing
   - **JavaScript expressions**: Binary/unary operators, ternary, arrows, objects, arrays, etc.

## Highlighting

The grammar uses these highlight groups:

### Neovim
- `@variable.builtin.datastar` - Signal references (`$count`, `$user.name`)
- `@function.builtin.datastar` - Action calls (`@get`, `@post`)
- `@tag.builtin` - Plugin names (`on`, `bind`, `text`)
- `@property` - Plugin keys and modifiers (`click`, `debounce.500ms`)
- `@tag.attribute` - The `data-` prefix
- Standard JS groups: `@operator`, `@string`, `@number`, `@keyword`, etc.

### Helix
- `@variable.builtin` - Signals
- `@function.builtin` - Actions
- `@tag.builtin` - Plugin names
- `@property` - Keys and modifiers
- Standard groups for JavaScript

### Customization

Add to your theme or config to customize colors:

**Neovim (lua):**
```lua
vim.api.nvim_set_hl(0, "@variable.builtin.datastar", { fg = "#89ddff", bold = true })
vim.api.nvim_set_hl(0, "@function.builtin.datastar", { fg = "#c792ea", bold = true })
```

**Helix (theme.toml):**
```toml
"variable.builtin" = { fg = "cyan", modifiers = ["bold"] }
"function.builtin" = { fg = "magenta", modifiers = ["bold"] }
```

## Development

### Building from Source

```bash
# Clone and enter directory
git clone https://github.com/YuryKL/tree-sitter-datastar.git
cd tree-sitter-datastar

# Generate parser
tree-sitter generate

# Test parsing
echo 'data-on:click__debounce.500ms' | tree-sitter parse /dev/stdin
```

### Project Structure

```
tree-sitter-datastar/
├── grammar.js              # Grammar definition
├── src/
│   ├── parser.c            # Generated parser (do not edit)
│   ├── scanner.c           # External scanner for plugin_key tokenization
│   └── tree_sitter/        # Tree-sitter headers
├── queries/
│   ├── highlights.scm          # Neovim syntax highlighting
│   ├── highlights-helix.scm    # Helix syntax highlighting
│   ├── injections-nvim.scm     # Neovim HTML injection queries
│   ├── injections-helix.scm    # Helix HTML injection queries
│   ├── indents.scm             # Indentation rules
│   └── textobjects.scm         # Text object queries
├── install.sh              # Quick install script (nvim or helix)
└── simple-test.html        # Minimal test file
```

## Troubleshooting

### Neovim: No highlighting

1. Verify parser is installed: `ls ~/.local/share/nvim/site/parser/datastar.so`
2. Check `:Inspect` output - should show datastar nodes
3. Ensure HTML injection queries are in `~/.config/nvim/after/queries/html/injections.scm`
4. Verify parser is registered in your nvim config (see manual installation step 5)
5. If seeing query errors: Install query parser with `:TSInstall query`
6. Try `:write | edit` to reload the file

### Helix: Limited AST inspection

**Known difference**: Helix doesn't expose injected tree-sitter nodes in its inspection UI like Neovim's `:Inspect` does. Syntax highlighting will work correctly, but scope inspection tools won't show the full parsed structure.

To verify it's working:
1. Check `hx --health datastar` shows `✓` for parser and queries
2. Open an HTML file with Datastar - signals/actions should be highlighted
3. If highlighting works, the parser is functioning correctly

### Compilation errors

Ensure you have a C compiler and include both source files:
```bash
gcc --version  # or clang --version
gcc -shared -fPIC -o parser.so src/parser.c src/scanner.c -I./src
```

## Contributing

Contributions welcome! Please test with real Datastar HTML files and document any breaking changes.

## License & Credits

MIT License - Created by [Yury Kleyman](https://github.com/YuryKL) for [Datastar](https://data-star.dev) by [@delaneyj](https://github.com/delaneyj)

[Report Issues](https://github.com/YuryKL/tree-sitter-datastar/issues)
