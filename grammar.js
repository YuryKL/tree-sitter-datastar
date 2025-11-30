/**
 * @file Grammar for Datastar @ data-star.dev
 * @author Yury Kleyman <kleymanyy@gmail.com>
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: "datastar",

  externals: $ => [
    $.plugin_key
  ],

  conflicts: $ => [
    [$.sequence_expression]
  ],

  rules: {
    source_file: $ => choice(
      $.datastar_attribute,
      repeat1($._statement)
    ),

    datastar_attribute: $ => seq(
      "data-",
      $.plugin_name,
      optional(choice(
        seq("__", $.modifier),
        seq(":", $.plugin_key, optional(seq("__", $.modifier)))
      ))
    ),

    plugin_name: $ => choice(
      // Standard plugins
      "attr", "bind", "class", "computed", "effect", "ignore", "ignore-morph",
      "indicator", "init", "json-signals", "on", "on-intersect", "on-interval",
      "on-signal-patch", "on-signal-patch-filter", "preserve-attr", "ref",
      "show", "signals", "style", "text",
      // Pro plugins
      "animate", "custom-validity", "on-raf", "on-resize", "persist",
      "query-string", "replace-url", "rocket", "scroll-into-view", "view-transition"
    ),

    modifier: $ => /[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)?/,

    _statement: $ => choice(
      $.expression_statement,
      $.assignment_statement,
      $.sequence_expression
    ),

    expression_statement: $ => $._expression,

    assignment_statement: $ => seq(
      $._lhs_expression,
      choice("=", "+=", "-=", "*=", "/=", "%=", "**=", "&&=", "||=", "??=", "&=", "|=", "^=", "<<=", ">>=", ">>>="),
      $._expression
    ),

    // Comma/semicolon operator for sequences (e.g., "a = 1, b = 2" or "a = 1; b = 2")
    sequence_expression: $ => prec.left(0, seq(
      $._statement,
      repeat1(seq(choice(',', ';'), $._statement))
    )),

    _lhs_expression: $ => choice(
      $.signal_reference,
      $.member_expression,
      $.computed_member_expression
    ),

    _expression: $ => choice(
      $.primary_expression,
      $.binary_expression,
      $.unary_expression,
      $.conditional_expression,
      $.call_expression,
      $.member_expression,
      $.computed_member_expression,
      $.parenthesized_expression,
      $.arrow_function
    ),

    primary_expression: $ => choice(
      $.identifier,
      $.signal_reference,
      $.action_call,
      $.literal,
      $.array,
      $.object
    ),

    // Datastar-specific
    signal_reference: $ => seq("$", $._property_chain),
    action_call: $ => seq($.action_name, "(", optional($.arguments), ")"),
    action_name: $ => seq("@", $.identifier),

    _property_chain: $ => prec.left(seq(
      $.signal_identifier,
      repeat(choice(
        seq(".", $.signal_identifier),
        seq("[", $._expression, "]"),
        seq("?.", $.signal_identifier),
        seq("?.[", $._expression, "]")
      ))
    )),

    // Binary operators
    binary_expression: $ => choice(
      ...[
        ['??', 3],
        ['||', 4],
        ['&&', 5],
        ['|', 6],
        ['^', 7],
        ['&', 8],
        ['==', 9], ['!=', 9], ['===', 9], ['!==', 9],
        ['<', 10], ['<=', 10], ['>', 10], ['>=', 10], ['in', 10], ['instanceof', 10],
        ['<<', 11], ['>>', 11], ['>>>', 11],
        ['+', 12], ['-', 12],
        ['*', 13], ['/', 13], ['%', 13],
        ['**', 14]
      ].map(([operator, precedence]) =>
        prec.left(precedence, seq($._expression, operator, $._expression))
      )
    ),

    unary_expression: $ => choice(
      prec.left(15, seq(choice('!', '~', '-', '+', 'typeof', 'void', 'delete'), $._expression)),
      prec.left(16, seq($._expression, choice('++', '--')))
    ),

    conditional_expression: $ => prec.right(2, seq(
      $._expression, '?', $._expression, ':', $._expression
    )),

    call_expression: $ => prec.left(17, seq(
      $._expression,
      '(',
      optional($.arguments),
      ')'
    )),

    member_expression: $ => prec.left(17, seq(
      $._expression,
      choice('.', '?.'),
      $.identifier
    )),

    computed_member_expression: $ => prec.left(17, seq(
      $._expression,
      choice('[', '?.['),
      $._expression,
      ']'
    )),

    parenthesized_expression: $ => seq('(', $._expression, ')'),

    // Literals
    literal: $ => choice(
      $.string_literal,
      $.number_literal,
      $.boolean_literal,
      $.null_literal,
      $.undefined_literal
    ),

    string_literal: $ => choice(
      seq('"', repeat(choice(/[^"\\]/, $.escape_sequence)), '"'),
      seq("'", repeat(choice(/[^'\\]/, $.escape_sequence)), "'"),
      seq("`", repeat(choice(/[^`\\]/, $.escape_sequence)), "`")
    ),

    escape_sequence: $ => seq("\\", choice(
      /[\\'"nrtbf]/,
      /u[0-9a-fA-F]{4}/,
      /x[0-9a-fA-F]{2}/,
      /[0-7]{1,3}/
    )),

    number_literal: $ => /\d+(\.\d+)?([eE][+-]?\d+)?/,
    boolean_literal: $ => choice("true", "false"),
    null_literal: $ => "null",
    undefined_literal: $ => "undefined",

    // Collections
    array: $ => seq('[', optional(seq(
      choice($._expression, $.spread_element),
      repeat(seq(',', choice($._expression, $.spread_element))),
      optional(',')
    )), ']'),

    object: $ => seq(
      '{',
      optional(seq(
        choice($.property, $.spread_element),
        repeat(seq(',', choice($.property, $.spread_element))),
        optional(',')
      )),
      '}'
    ),

    property: $ => seq(
      choice($.identifier, $.string_literal, seq('[', $._expression, ']')),
      ':',
      $._expression
    ),

    // Spread operator (...expr)
    spread_element: $ => seq('...', $._expression),

    // Arrow functions
    arrow_function: $ => prec.right(1, seq(
      choice(
        $.identifier,
        seq('(', optional($.parameter_list), ')')
      ),
      '=>',
      $._expression
    )),

    parameter_list: $ => prec(1, seq($.identifier, repeat(seq(',', $.identifier)))),

    arguments: $ => seq(
      choice($._expression, $.spread_element),
      repeat(seq(',', choice($._expression, $.spread_element)))
    ),

    // Standard JavaScript identifier (used for variables, properties, etc.)
    identifier: $ => /[a-zA-Z_][a-zA-Z0-9_]*/,

    // Datastar-specific identifier that allows hyphens (for signal names like $foo-bar)
    // This is used only in signal_reference contexts
    signal_identifier: $ => /[a-zA-Z_][a-zA-Z0-9_-]*/
  }
});
