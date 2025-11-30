# Template Language Support

This document lists the injection query configurations for different template languages.

## Supported Template Languages

### ✅ Working (Tested)

| Language | Grammar Repo | First Line | Install Path | Notes |
|----------|--------------|------------|--------------|-------|
| **HTML** (Neovim) | N/A | `; extends` | `~/.config/nvim/after/queries/html/injections.scm` | Use `injections-nvim.scm` |
| **HTML** (Helix) | N/A | Standard HTML | `~/.config/helix/runtime/queries/html/injections.scm` | Use `injections-helix.scm` |
| **Templ** | [vrischmann/tree-sitter-templ](https://github.com/vrischmann/tree-sitter-templ) | `; extends` | `~/.config/nvim/after/queries/templ/injections.scm` | Go template language |
| **HEEx** | [phoenixframework/tree-sitter-heex](https://github.com/phoenixframework/tree-sitter-heex) | `; extends` | `~/.config/nvim/after/queries/heex/injections.scm` | Phoenix/Elixir templates |
| **Blade** | [EmranMR/tree-sitter-blade](https://github.com/EmranMR/tree-sitter-blade) | `; inherits: html` | `~/.config/nvim/after/queries/blade/injections.scm` | Laravel PHP templates |

### ❌ Not Working / Needs Investigation

| Language | Grammar Repo | Status | Notes |
|----------|--------------|--------|-------|
| **Twig** | [gbprod/tree-sitter-twig](https://github.com/gbprod/tree-sitter-twig) | ❌ Not working | Twig injects HTML into `content` nodes, but the HTML parser within injected content doesn't expose attribute nodes that can be re-injected. The injection chain (twig → html → datastar) doesn't work. |
| **Django** | [interdependence/tree-sitter-htmldjango](https://github.com/interdependence/tree-sitter-htmldjango) | ❌ Parser incompatible | Grammar has incompatible tree-sitter language version (needs v13-14, current is v15). Parser won't load in modern tree-sitter/Neovim. |
| **Jinja** | Various repos | 🔍 Needs testing | Multiple Jinja grammars exist (jinja, htmljinja2). Need to find which one works and if it has the same issues as Twig/Django. |
| **ERB** | [tree-sitter/tree-sitter-embedded-template](https://github.com/tree-sitter/tree-sitter-embedded-template) | ❌ Parser incompatible | Same issue as Django - incompatible tree-sitter language version (needs v13-14, current is v15). Parser won't load. Also injects HTML into `content` nodes like Twig. |
| **Tera** | [uncenter/tree-sitter-tera](https://github.com/uncenter/tree-sitter-tera) | ❌ Parser incompatible | Rust template language. Grammar has incompatible tree-sitter language version (needs v13-14, current is v15). Parser won't load. Only injects YAML into frontmatter, doesn't handle HTML. |
| **Mustache** | [TheLeoP/tree-sitter-mustache](https://github.com/TheLeoP/tree-sitter-mustache) | ❌ Not working | Mustache grammar doesn't define HTML attributes - treats all HTML content as raw `text`. Parser fails with errors on HTML elements. No injection support for HTML structure. |

## Injection Query Template

All template languages use the same injection pattern with minor header differences:

```scm
; [HEADER - see table above]

; Inject datastar into attribute VALUES for expressions
((attribute
  (attribute_name) @_attr
  (quoted_attribute_value
    (attribute_value) @injection.content))
  (#match? @_attr "^data-(on|text|bind|show|signals|computed|class|style|attr|effect|init|ref|indicator|on-intersect|on-interval|on-signal-patch|on-signal-patch-filter|animate|custom-validity|on-raf|on-resize|persist|query-string|replace-url|rocket|scroll-into-view|view-transition|ignore|ignore-morph|preserve-attr|json-signals)")
  (#set! injection.language "datastar"))

; Inject datastar into attribute NAMES to parse data-plugin:key__modifier structure
((attribute_name) @injection.content
  (#match? @injection.content "^data-(on|text|bind|show|signals|computed|class|style|attr|effect|init|ref|indicator|on-intersect|on-interval|on-signal-patch|on-signal-patch-filter|animate|custom-validity|on-raf|on-resize|persist|query-string|replace-url|rocket|scroll-into-view|view-transition|ignore|ignore-morph|preserve-attr|json-signals)")
  (#set! injection.language "datastar")
  (#set! injection.include-children))
```

## Header Types

- **`; extends`**: Add these queries to existing injection queries (most common)
- **`; inherits: html`**: This grammar inherits from HTML (used by Blade)

## Installation Notes

### For Users

Copy the appropriate injection query to your editor's query directory based on which template language you use. The injection queries work by:

1. **Attribute VALUES**: Parse data-star expressions in attribute values like `data-on:click="$count++"`
2. **Attribute NAMES**: Parse the plugin:key__modifier structure in attribute names like `data-on:click__debounce.500ms`

### For Developers

When adding support for a new template language:

1. Find the tree-sitter grammar repository
2. Check if it has `attribute`, `attribute_name`, and `attribute_value` nodes
3. Use the template above with the appropriate header
4. Test and add to the table above

## Grammar Requirements

For datastar injections to work, the template language grammar must either:

1. **Define HTML attribute nodes** directly (`attribute`, `attribute_name`, `attribute_value`), OR
2. **Inject HTML** into content nodes (like Twig and Django do)

If a grammar only handles template syntax without HTML structure, additional work may be needed.
