# tree-sitter-datastar

A [Tree-sitter](https://tree-sitter.github.io) grammar for [Datastar](https://data-star.dev) expressions and attributes.

## Features

This grammar provides comprehensive parsing for:

### 🏷️ Datastar Attribute Names
- **Standard plugins**: `data-on:click`, `data-bind:value`, `data-show`, etc.
- **Pro plugins**: `data-animate`, `data-persist`, `data-view-transition`, etc.
- **Syntax highlighting**: Plugin names, modifiers, and separators are individually highlighted

### 🧮 JavaScript-Compatible Expressions
- **Signal references**: `$user.name`, `$items[0]`, `$data?.user?.email`
- **Action calls**: `@get('/api/users')`, `@post('/data', {id: $userId})`
- **Full JavaScript syntax**: Ternary operators, arrow functions, object/array literals
- **Complex expressions**: `$visible = $count > 5 ? 'show' : 'hide'`

### 🎨 HTML Template Integration
- **Injection-based parsing**: Works within existing HTML parsers
- **Template language support**: Compatible with ERB, Jinja2, Handlebars, etc.
- **Attribute value parsing**: Automatically parses expressions inside datastar attributes
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
  <button data-on:click="$count = $count + 10">Add 10</button>

  <!-- Conditional display -->
  <div data-show="$count > 5">Count is greater than 5!</div>

  <!-- Action calls with arguments -->
  <button data-on:click="@get('/api/data')">Fetch</button>
  <button data-on:click="@post('/api/save', {count: $count})">Save</button>

  <!-- Complex expressions -->
  <input data-on:input="$user.name = event.target.value" />
  <div data-class:active="$count % 2 === 0">Even count styling</div>
  <div data-style:opacity="$count / 10">Fading div</div>
</div>
```

## Installation

### Neovim (Recommended)

#### Prerequisites
- Neovim 0.9+ with tree-sitter support
- A plugin manager (lazy.nvim, packer, etc.)
- `gcc` or `clang` compiler

#### Installation Steps

1. **Clone this repository:**
```bash
git clone https://github.com/YuryKL/tree-sitter-datastar.git ~/.local/share/tree-sitter-datastar
```

2. **Compile and install the parser:**
```bash
cd ~/.local/share/tree-sitter-datastar
mkdir -p ~/.local/share/nvim/site/parser
gcc -shared -fPIC -o ~/.local/share/nvim/site/parser/datastar.so src/parser.c -I./src
```

3. **Install query files:**
```bash
mkdir -p ~/.local/share/nvim/site/queries/datastar
cp queries/highlights.scm ~/.local/share/nvim/site/queries/datastar/
```

4. **Configure HTML injections:**

Create `~/.config/nvim/after/queries/html/injections.scm`:

```scheme
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
```

5. **Add to your Neovim config (optional):**

If using lazy.nvim, create `~/.config/nvim/lua/plugins/datastar.lua`:

```lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "html", "javascript" })
      return opts
    end,
  },
}
```

6. **Restart Neovim** and open an HTML file with Datastar attributes!

#### Verification

Open any HTML file with Datastar and run `:Inspect` with your cursor on a datastar attribute. You should see:
- Attribute names parsed as `datastar_attribute`
- Attribute values parsed with `signal_reference`, `action_call`, etc.

### Helix

⚠️ **Status**: Experimental - injections may not work reliably. Neovim is recommended.

1. **Build the parser:**
```bash
git clone https://github.com/YuryKL/tree-sitter-datastar.git ~/tree-sitter-datastar
cd ~/tree-sitter-datastar
mkdir -p ~/.config/helix/runtime/grammars
gcc -shared -fPIC -o ~/.config/helix/runtime/grammars/datastar.so src/parser.c -I./src
```

2. **Link queries:**
```bash
mkdir -p ~/.config/helix/runtime/queries
ln -s ~/tree-sitter-datastar/queries ~/.config/helix/runtime/queries/datastar
```

3. **Configure language in `~/.config/helix/languages.toml`:**
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

4. **Add HTML injection queries in `~/.config/helix/runtime/queries/html/injections.scm`:**
```scheme
; Standard HTML injections
((comment) @injection.content
 (#set! injection.language "comment"))

((script_element
  (raw_text) @injection.content)
 (#set! injection.language "javascript"))

((style_element
  (raw_text) @injection.content)
 (#set! injection.language "css"))

; Inject datastar into attribute VALUES
((attribute
  (attribute_name) @_attr_name
  (quoted_attribute_value
    (attribute_value) @injection.content))
  (#match? @_attr_name "^data-(on|text|bind|show|signals|computed|class|style|attr|effect|init|ref|indicator|on-intersect|on-interval|on-signal-patch)")
  (#set! injection.language "datastar"))

; Inject datastar into attribute NAMES
((attribute_name) @injection.content
  (#match? @injection.content "^data-(on|text|bind|show|signals|computed|class|style|attr|effect|init|ref|indicator|on-intersect|on-interval|on-signal-patch|animate|custom-validity|on-raf|on-resize|persist|query-string|replace-url|rocket|scroll-into-view|view-transition|ignore|ignore-morph|preserve-attr|json-signals)")
  (#set! injection.language "datastar"))
```

5. Restart Helix and run `hx --health datastar` to verify.

### VS Code / Other Editors

Emacs should be able to be configured in a similar fashion, same with vs-code using 3rd party tree-sitter extensions. Contributions welcome!

## How It Works

This grammar is designed to be **injected** into HTML files, not used standalone:

1. **Attribute Value Injection**: When HTML contains `data-on:click="$count++"`, the value `$count++` is parsed as datastar
2. **Attribute Name Injection**: The attribute name `data-on:click` is also parsed to highlight the plugin and modifier separately
3. **Datastar Grammar**: Parses JavaScript-like expressions with Datastar-specific constructs:
   - **Signal references**: `$identifier` with property chains, optional chaining, computed access
   - **Action calls**: `@identifier(args)` with full argument parsing
   - **JavaScript expressions**: Binary/unary operators, ternary, arrows, objects, arrays, etc.

## Highlighting

The grammar uses these highlight groups:

### Neovim
- `@variable.builtin.datastar` - Signal references (`$count`, `$user.name`)
- `@function.builtin.datastar` - Action calls (`@get`, `@post`)
- `@tag.builtin` - Plugin names (`on`, `bind`, `text`)
- `@property` - Modifiers/keys (`click`, `value`)
- `@tag.attribute` - The `data-` prefix
- Standard JS groups: `@operator`, `@string`, `@number`, `@keyword`, etc.

### Helix
- `@variable.builtin` - Signals
- `@function.builtin` - Actions
- `@tag.builtin` - Plugin names
- `@property` - Modifiers
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
npx tree-sitter generate

# Test parsing
npx tree-sitter parse test-datastar.html

# Test queries
npx tree-sitter query queries/highlights.scm test-datastar.html
```

### Running Tests

```bash
# Tree-sitter tests
npx tree-sitter test

# Or use npm
npm test
```

### Project Structure

```
tree-sitter-datastar/
├── grammar.js              # Grammar definition
├── src/
│   ├── parser.c            # Generated parser (do not edit)
│   └── tree_sitter/        # Tree-sitter headers
├── queries/
│   ├── highlights.scm      # Syntax highlighting rules
│   └── injections.scm      # Injection documentation/examples
├── test-datastar.html      # Test file with examples
└── simple-test.html        # Minimal test file
```

## Troubleshooting

### Neovim: No highlighting

1. Verify parser is installed:
```bash
ls ~/.local/share/nvim/site/parser/datastar.so
```

2. Check `:Inspect` output - should show datastar nodes

3. Ensure HTML injection queries are in `~/.config/nvim/after/queries/html/injections.scm`

4. Try `:write | edit` to reload the file

### Helix: Injections not working

Helix injection support is currently limited. Try:
1. Check `hx --health datastar` and `hx --health html`
2. Verify both show `✓` for parser and queries
3. Note: Attribute name injection may not work in Helix

### Compilation errors

Ensure you have a C compiler:
```bash
gcc --version  # or clang --version
```

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with real Datastar HTML files
5. Submit a pull request

Please:
- Update tests if adding new syntax
- Document breaking changes
- Follow existing code style

## License

MIT License - see LICENSE file for details

## Credits

- **Created by**: Yury Kleyman ([@YuryKL](https://github.com/YuryKL))
- **Datastar framework by**: [@delaneyj](https://github.com/delaneyj)
- **Built with**: [Tree-sitter](https://tree-sitter.github.io/)

## Links

- [Datastar Documentation](https://data-star.dev)
- [Tree-sitter Documentation](https://tree-sitter.github.io/tree-sitter/)
- [Report Issues](https://github.com/YuryKL/tree-sitter-datastar/issues)
