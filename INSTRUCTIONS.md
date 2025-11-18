# Setup Instructions for tree-sitter-datastar

This guide will help you set up syntax highlighting for Datastar expressions in your editor.

## Prerequisites

- Your editor must support Tree-sitter
- Basic understanding of Tree-sitter configuration

## Editor Setup

### VS Code

1. **Install the Tree-sitter extension**:
   ```
   ext install tree-sitter.tree-sitter
   ```

2. **Add the grammar to your settings**:
   ```json
   {
     "tree-sitter.grammars": [
       {
         "name": "datastar", 
         "path": "./node_modules/tree-sitter-datastar"
       }
     ]
   }
   ```

   **Note**: No file associations needed - the grammar injects into HTML files automatically.

### Neovim

1. **Install using your package manager** (e.g., with lazy.nvim):
   ```lua
   {
     "nvim-treesitter/nvim-treesitter",
     config = function()
       require('nvim-treesitter.configs').setup({
         ensure_installed = { "html", "javascript", "typescript" },
         highlight = { enable = true },
       })
       
       -- Add datastar parser (for HTML injection only)
       local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
       parser_config.datastar = {
         install_info = {
           url = "path/to/tree-sitter-datastar",
           files = {"src/parser.c"},
         },
         -- No filetype needed - injects into HTML
       }
     end
   }
   ```

2. **Install the parser**:
   ```
   :TSInstall datastar
   ```

### Emacs

1. **First, ensure you have the tree-sitter packages**:
   ```elisp
   (use-package tree-sitter
     :ensure t
     :config
     (global-tree-sitter-mode))
   
   (use-package tree-sitter-langs
     :ensure t
     :after tree-sitter)
   ```

2. **Clone and build the grammar**:
   ```bash
   cd ~/.emacs.d/
   git clone https://github.com/your-repo/tree-sitter-datastar
   cd tree-sitter-datastar
   tree-sitter generate
   tree-sitter build
   ```

3. **Add the grammar to your configuration**:
   ```elisp
   (use-package tree-sitter
     :ensure t
     :config
     (global-tree-sitter-mode)
     
     ;; Add the grammar path
     (setq tree-sitter-load-path 
           (append tree-sitter-load-path 
                   '("~/.emacs.d/tree-sitter-datastar")))
     
     ;; Register the language
     (tree-sitter-load 'datastar "~/.emacs.d/tree-sitter-datastar/libtree-sitter-datastar.so")
     
     ;; Associate with HTML for injection
     (add-to-list 'tree-sitter-major-mode-language-alist
                  '(html-mode . html))
   ```

4. **Alternative: Manual installation**:
   If the above doesn't work, try:
   ```elisp
   ;; In your init.el
   (add-to-list 'load-path "~/.emacs.d/tree-sitter-datastar")
   
   ;; Load manually
   (require 'tree-sitter)
   (tree-sitter-require 'html) ; Make sure HTML parser is loaded first
   
   ;; The datastar grammar will inject into HTML automatically
   ```

## HTML Integration

The main benefit of this grammar is parsing Datastar expressions within HTML attributes.

### Example HTML with Highlighting

```html
<!DOCTYPE html>
<html>
<body>
  <!-- Attribute names get highlighted -->
  <div data-on:click="$count += 1">
    <!-- JavaScript expressions with datastar tokens -->
    Click count: <span data-text="$count"></span>
  </div>
  
  <!-- Complex expressions -->
  <div data-show="$user.isLoggedIn && $user.permissions.canView">
    <h1 data-text="$user.name || 'Guest'"></h1>
    
    <!-- Action calls -->
    <button data-on:click="@logout()">
      Logout
    </button>
    
    <!-- Arrow functions and complex logic -->
    <ul data-bind="$items.filter(x => x.active).map(item => item.name)">
    </ul>
  </div>
  
  <!-- Ternary operators -->
  <div data-class:hidden="$loading ? false : !$data">
    <span data-text="$error ? $error.message : 'Loading...'"></span>
  </div>
</body>
</html>
```

## Syntax Highlighting Colors

The grammar provides these highlight groups:

### Datastar-Specific
- `@keyword.directive` - `$` and `@` symbols
- `@variable.special` - Signal names after `$`
- `@function.call` - Action names after `@`
- `@type` - Plugin names (on, bind, show, etc.)
- `@property` - Attribute modifiers (click, value, etc.)

### JavaScript Elements
- `@operator` - All JavaScript operators (`&&`, `||`, `===`, `=>`, etc.)
- `@string` - String literals
- `@number` - Number literals  
- `@constant.builtin` - `true`, `false`, `null`, `undefined`
- `@punctuation.delimiter` - Brackets, commas, semicolons
- `@variable` - Regular identifiers

## Troubleshooting

### Grammar Not Loading

1. **Check the path**: Ensure the grammar files are in the correct location
2. **Verify dependencies**: Make sure Tree-sitter itself is installed
3. **Restart editor**: Some editors need a restart after adding new grammars

### No HTML Injection

1. **Check injection queries**: Ensure `queries/injections.scm` is present
2. **HTML parser**: Make sure tree-sitter-html is also installed
3. **File type**: Verify the file is recognized as HTML

### Missing Highlights

1. **Highlight queries**: Ensure `queries/highlights.scm` is loaded
2. **Theme compatibility**: Some themes may not support all highlight groups
3. **Fallback**: Check if basic syntax highlighting works first

### Shared Library Errors (Emacs)

If you get "Cannot find shared library for language: datastar":

1. **Build the library**:
   ```bash
   cd /path/to/tree-sitter-datastar
   tree-sitter build  # Creates libtree-sitter-datastar.so
   ```

2. **Check the library exists**:
   ```bash
   ls -la libtree-sitter-datastar.so
   ```

3. **Ensure correct path in config**:
   ```elisp
   ;; Use full absolute path
   (tree-sitter-load 'datastar "/full/path/to/tree-sitter-datastar/libtree-sitter-datastar.so")
   ```

4. **Alternative: Use tree-sitter-langs**:
   ```elisp
   ;; Add to tree-sitter-langs directory instead
   (setq tree-sitter-langs-grammar-dir "~/.emacs.d/tree-sitter-langs/bin")
   ;; Copy libtree-sitter-datastar.so to that directory
   ```

## Testing Your Setup

Create a test HTML file:

```html
<div data-on:click="$count += 1" data-show="$visible">
  <span data-text="$user.name || 'Anonymous'"></span>
  <button data-on:click="@refresh()">Refresh</button>
</div>
```

You should see:
- `data-on`, `data-show`, `data-text` highlighted as keywords
- `:click` highlighted as properties  
- `$count`, `$visible`, `$user` highlighted as special variables
- `@refresh` highlighted as a function call
- JavaScript operators and literals properly colored

## Advanced Configuration

### Custom Highlight Groups

You can customize highlighting by mapping Tree-sitter groups to your theme:

```vim
" Vim/Neovim
hi link @keyword.directive Special
hi link @variable.special Identifier
hi link @function.call Function
```

```elisp
;; Emacs
(set-face-attribute 'tree-sitter-hl-face:keyword.directive nil :foreground "#ff6b6b")
(set-face-attribute 'tree-sitter-hl-face:variable.special nil :foreground "#4ecdc4")
```

### Performance Considerations

For large HTML files, you may want to:
1. Limit injection depth
2. Use lazy loading for Tree-sitter
3. Consider file-size thresholds for enabling parsing

## Contributing

If you find issues with highlighting or want to improve the grammar:

1. Check the [grammar rules](grammar.js)
2. Update [highlight queries](queries/highlights.scm) 
3. Test with [example files](test-*.datastar)
4. Submit a pull request

## Resources

- [Tree-sitter Documentation](https://tree-sitter.github.io/)
- [Datastar Documentation](https://data-star.dev)
- [Writing Tree-sitter Grammars](https://tree-sitter.github.io/tree-sitter/creating-parsers)