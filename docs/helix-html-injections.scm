; Standard HTML injections
((comment) @injection.content
 (#set! injection.language "comment"))

((script_element
  (raw_text) @injection.content)
 (#set! injection.language "javascript"))

((style_element
  (raw_text) @injection.content)
 (#set! injection.language "css"))

; Inject datastar into attribute VALUES for all datastar plugins
((attribute
  (attribute_name) @_attr
  (quoted_attribute_value
    (attribute_value) @injection.content))
  (#match? @_attr "^data-(on|text|bind|show|signals|computed|class|style|attr|effect|init|ref|indicator|on-intersect|on-interval|on-signal-patch|on-signal-patch-filter|animate|custom-validity|on-raf|on-resize|persist|query-string|replace-url|rocket|scroll-into-view|view-transition|ignore|ignore-morph|preserve-attr|json-signals)")
  (#set! injection.language "datastar")
  (#set! injection.combined))
