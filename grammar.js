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
      $.assignment_statement
    ),

    expression_statement: $ => $._expression,

    assignment_statement: $ => seq(
      $._lhs_expression,
      choice("=", "+=", "-=", "*=", "/=", "%=", "&&=", "||=", "??="),
      $._expression
    ),

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
    action_call: $ => seq("@", $.identifier, "(", optional($.arguments), ")"),

    _property_chain: $ => prec.left(seq(
      $.identifier,
      repeat(choice(
        seq(".", $.identifier),
        seq("[", $._expression, "]"),
        seq("?.", $.identifier),
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
    array: $ => seq('[', optional(seq($._expression, repeat(seq(',', $._expression)), optional(','))), ']'),

    object: $ => seq(
      '{',
      optional(seq(
        $.property,
        repeat(seq(',', $.property)),
        optional(',')
      )),
      '}'
    ),

    property: $ => seq(
      choice($.identifier, $.string_literal, seq('[', $._expression, ']')),
      ':',
      $._expression
    ),

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

    arguments: $ => seq($._expression, repeat(seq(',', $._expression))),

    identifier: $ => /[a-zA-Z_][a-zA-Z0-9_]*/
  }
});
