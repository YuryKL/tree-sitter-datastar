; Highlighting rules for datastar expressions

; Datastar attribute names - parsed from HTML attribute names
; data-{plugin}:{modifier} OR data-{plugin}
; Capture with modifier
(datastar_attribute
  "data-" @tag.attribute
  (plugin_name) @tag.builtin
  ":" @punctuation.delimiter
  (modifier) @property)

; Capture without modifier (data-signals, data-init, etc.)
(datastar_attribute
  "data-" @tag.attribute
  (plugin_name) @tag.builtin)

(signal_reference) @variable.builtin

; Action calls - highlight @ and identifier with same color
(action_name "@" @function.builtin)
(action_name (identifier) @function.builtin)

; JavaScript operators
["=" "+=" "-=" "*=" "/=" "%=" "**=" "&&=" "||=" "??=" "&=" "|=" "^=" "<<=" ">>=" ">>>="] @operator
["&&" "||" "??" "==" "!=" "===" "!==" "<" ">" "<=" ">=" "in" "instanceof"] @operator
["+" "-" "*" "/" "%" "**" "<<" ">>" ">>>" "&" "|" "^"] @operator
["!" "~" "typeof" "void" "delete" "++" "--"] @operator
["?" ":"] @operator
"..." @operator

; Member access
["." "?." "[" "]" "?.["] @operator

; Literals
(string_literal) @string
(number_literal) @number  
(boolean_literal) @constant.builtin
(null_literal) @constant.builtin
(undefined_literal) @constant.builtin

; Keywords
["typeof" "void" "delete" "in" "instanceof"] @keyword

(identifier) @variable

; Punctuation
["(" ")" "{" "}" "[" "]" "," ":" ";"] @punctuation.delimiter

; Property keys in objects
(property (identifier) @property)
(property (string_literal) @property)
