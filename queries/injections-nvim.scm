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
