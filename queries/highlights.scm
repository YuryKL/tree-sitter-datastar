; Highlighting rules for datastar expressions

; Datastar attribute names
(datastar_attribute 
  "data-" @keyword
  (plugin_name) @type
  ":" @operator
  (modifier) @property)

; Datastar-specific tokens
(signal_reference "$" @keyword.directive)
(signal_reference (identifier) @variable.special)
(action_call "@" @keyword.directive)
(action_call (identifier) @function.call)

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
["true" "false" "null" "undefined"] @constant.builtin
["typeof" "void" "delete" "in" "instanceof"] @keyword

; Identifiers
(identifier) @variable

; Punctuation
["(" ")" "{" "}" "[" "]" "," ";" ":"] @punctuation.delimiter

; Property keys in objects
(property (identifier) @property)
(property (string_literal) @property)