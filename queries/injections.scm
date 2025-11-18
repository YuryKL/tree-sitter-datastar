; Injection rules for datastar expressions in HTML data-* attributes
; This allows the datastar grammar to parse expressions within HTML attribute values

; Inject into attribute values for all datastar attributes that contain expressions
(attribute 
  (attribute_name) @attr_name
  (quoted_attribute_value 
    (attribute_value) @injection.content)
  (#match? @attr_name "^data-(attr|bind|class|computed|effect|ignore|ignore-morph|indicator|init|json-signals|on|on-intersect|on-interval|on-signal-patch|on-signal-patch-filter|preserve-attr|ref|show|signals|style|text|animate|custom-validity|on-raf|on-resize|persist|query-string|replace-url|rocket|scroll-into-view|view-transition)")
  (#set! injection.language "datastar"))

; Also inject into unquoted attribute values
(attribute 
  (attribute_name) @attr_name
  (attribute_value) @injection.content
  (#match? @attr_name "^data-(attr|bind|class|computed|effect|ignore|ignore-morph|indicator|init|json-signals|on|on-intersect|on-interval|on-signal-patch|on-signal-patch-filter|preserve-attr|ref|show|signals|style|text|animate|custom-validity|on-raf|on-resize|persist|query-string|replace-url|rocket|scroll-into-view|view-transition)")
  (#set! injection.language "datastar"))