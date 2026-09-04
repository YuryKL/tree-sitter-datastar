; extends

; Inject datastar into attribute VALUES for expressions (regular attributes)
((jsx_attribute
  (property_identifier) @_attr
  (string (string_fragment) @injection.content))
  (#match? @_attr "^data-(on|text|bind|show|signals|computed|class|style|attr|effect|init|ref|indicator|on-intersect|on-interval|on-signal-patch|on-signal-patch-filter|animate|custom-validity|on-raf|on-resize|persist|query-string|replace-url|rocket|scroll-into-view|view-transition|ignore|ignore-morph|preserve-attr|json-signals)")
  (#set! injection.language "datastar"))

; Inject datastar into attribute VALUES for namespaced attributes (data-on:click etc.)
((jsx_attribute
  (jsx_namespace_name) @_attr
  (string (string_fragment) @injection.content))
  (#match? @_attr "^data-(on|text|bind|show|signals|computed|class|style|attr|effect|init|ref|indicator|on-intersect|on-interval|on-signal-patch|on-signal-patch-filter|animate|custom-validity|on-raf|on-resize|persist|query-string|replace-url|rocket|scroll-into-view|view-transition|ignore|ignore-morph|preserve-attr|json-signals)")
  (#set! injection.language "datastar"))

; Inject datastar into attribute VALUES for namespaced attributes with JSX template expressions
; Matches: data-on:click={`@get('/endpoint')`} (template literal in JSX expression)
((jsx_attribute
  (jsx_namespace_name) @_attr
  (jsx_expression
    (template_string
      (string_fragment) @injection.content)))
  (#match? @_attr "^data-(on|text|bind|show|signals|computed|class|style|attr|effect|init|ref|indicator|on-intersect|on-interval|on-signal-patch|on-signal-patch-filter|animate|custom-validity|on-raf|on-resize|persist|query-string|replace-url|rocket|scroll-into-view|view-transition|ignore|ignore-morph|preserve-attr|json-signals)")
  (#set! injection.language "datastar"))

; Inject datastar into attribute VALUES for regular attributes with JSX template expressions
; Matches: data-init={`@get('/updates')`}
((jsx_attribute
  (property_identifier) @_attr
  (jsx_expression
    (template_string
      (string_fragment) @injection.content)))
  (#match? @_attr "^data-(on|text|bind|show|signals|computed|class|style|attr|effect|init|ref|indicator|on-intersect|on-interval|on-signal-patch|on-signal-patch-filter|animate|custom-validity|on-raf|on-resize|persist|query-string|replace-url|rocket|scroll-into-view|view-transition|ignore|ignore-morph|preserve-attr|json-signals)")
  (#set! injection.language "datastar"))

; Inject datastar into attribute NAMES (regular property_identifier)
((property_identifier) @injection.content
  (#match? @injection.content "^data-(on|text|bind|show|signals|computed|class|style|attr|effect|init|ref|indicator|on-intersect|on-interval|on-signal-patch|on-signal-patch-filter|animate|custom-validity|on-raf|on-resize|persist|query-string|replace-url|rocket|scroll-into-view|view-transition|ignore|ignore-morph|preserve-attr|json-signals)")
  (#set! injection.language "datastar")
  (#set! injection.include-children))

; Inject datastar into attribute NAMES (jsx_namespace_name for namespaced attrs)
((jsx_namespace_name) @injection.content
  (#match? @injection.content "^data-(on|text|bind|show|signals|computed|class|style|attr|effect|init|ref|indicator|on-intersect|on-interval|on-signal-patch|on-signal-patch-filter|animate|custom-validity|on-raf|on-resize|persist|query-string|replace-url|rocket|scroll-into-view|view-transition|ignore|ignore-morph|preserve-attr|json-signals)")
  (#set! injection.language "datastar")
  (#set! injection.include-children))

; Inject datastar into attrs={{ }} object KEYS (attribute names like data-on-signal-patch__throttle.200ms)
((jsx_attribute
  (property_identifier) @_name
  (jsx_expression
    (object
      (pair
        key: (string (string_fragment) @injection.content)
        (#match? @injection.content "^data-(on|text|bind|show|signals|computed|class|style|attr|effect|init|ref|indicator|on-intersect|on-interval|on-signal-patch|on-signal-patch-filter|animate|custom-validity|on-raf|on-resize|persist|query-string|replace-url|rocket|scroll-into-view|view-transition|ignore|ignore-morph|preserve-attr|json-signals)")
      ))))
  (#eq? @_name "attrs")
  (#set! injection.language "datastar")
  (#set! injection.include-children))

; Inject datastar into attrs={{ }} object VALUES (expressions)
((jsx_attribute
  (property_identifier) @_name
  (jsx_expression
    (object
      (pair
        key: (string (string_fragment) @_key)
        value: (string (string_fragment) @injection.content)
        (#match? @_key "^data-(on|text|bind|show|signals|computed|class|style|attr|effect|init|ref|indicator|on-intersect|on-interval|on-signal-patch|on-signal-patch-filter|animate|custom-validity|on-raf|on-resize|persist|query-string|replace-url|rocket|scroll-into-view|view-transition|ignore|ignore-morph|preserve-attr|json-signals)")
      ))))
  (#eq? @_name "attrs")
  (#set! injection.language "datastar"))
