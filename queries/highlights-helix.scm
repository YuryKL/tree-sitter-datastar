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

; Datastar-specific tokens - MUST come before generic identifier rule
; Signals: $identifier - capture entire node to ensure uniform color
(signal_reference) @variable.builtin

; Actions: @action(...) - highlight @ and action name, but let arguments parse normally
; Capture identifier inside action_call specifically to override generic (identifier) below
(action_call "@" @function.builtin)
((action_call (identifier) @function.builtin))

; JavaScript operators
["=" "+=" "-=" "*=" "/=" "%=" "&&=" "||=" "??="] @operator
["&&" "||" "??" "==" "!=" "===" "!==" "<" ">" "<=" ">=" "in" "instanceof"] @operator
["+" "-" "*" "/" "%" "**" "<<" ">>" ">>>" "&" "|" "^"] @operator
["!" "~" "typeof" "void" "delete" "++" "--"] @operator
["?" ":"] @operator

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

; Identifiers - generic catch-all
; Note: This will also match identifiers in action_call, but action_call captures
; should take precedence if the editor respects pattern order
(identifier) @variable

; Punctuation
["(" ")" "{" "}" "[" "]" "," ":"] @punctuation.delimiter

; Property keys in objects
(property (identifier) @property)
(property (string_literal) @property)