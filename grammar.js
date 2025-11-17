/**
 * @file Grammar for Datastar @ data-star.dev
 * @author Yury Kleyman <kleymanyy@gmail.com>
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: "datastar",

  rules: {
    // TODO: add the actual grammar rules
    source_file: $ => "hello"
  }
});
