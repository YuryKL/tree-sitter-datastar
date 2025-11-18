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

**Standard (31 total):**
`attr`, `bind`, `class`, `computed`, `effect`, `ignore`, `ignore-morph`, `indicator`, `init`, `json-signals`, `on`, `on-intersect`, `on-interval`, `on-signal-patch`, `on-signal-patch-filter`, `preserve-attr`, `ref`, `show`, `signals`, `style`, `text`, `animate`, `custom-validity`, `on-raf`, `on-resize`, `persist`, `query-string`, `replace-url`, `rocket`, `scroll-into-view`, `view-transition`

## Grammar Examples

### Attribute Names
```html
<div data-on:click="...">          <!-- Plugin: on, Modifier: click -->
<input data-bind:value="...">      <!-- Plugin: bind, Modifier: value -->
<span data-show="...">             <!-- Plugin: show -->
```

### JavaScript Expressions (within HTML attributes)
```html
<div data-bind="$user.name = 'John Doe'">                    <!-- Signal assignment -->
<ul data-show="$items.filter(x => x.active)">               <!-- Arrow functions -->  
<span data-text="$count > 0 ? 'visible' : 'hidden'">        <!-- Ternary operator -->
<button data-on:click="@get('/api/data', {limit: $pageSize})"> <!-- Action calls -->
<div data-class="$data?.user?.preferences?.theme">          <!-- Optional chaining -->
```

## Installation

```bash
npm install tree-sitter-datastar
```

## Development

```bash
# Generate parser
tree-sitter generate

# Test parsing (standalone expressions for development)
tree-sitter parse test-final.datastar

# Run tests
npm test
```

**Note**: The `.datastar` test files are only used for grammar development. In practice, this grammar injects into HTML templates and doesn't require standalone files.

## License

MIT
