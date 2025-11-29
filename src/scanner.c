/**
 * External scanner for tree-sitter-datastar
 * Handles plugin_key tokenization to stop at __ delimiter
 */

#include "tree_sitter/parser.h"
#include <wctype.h>

enum TokenType {
  PLUGIN_KEY,
};

void *tree_sitter_datastar_external_scanner_create() { return NULL; }
void tree_sitter_datastar_external_scanner_destroy(void *p) {}
void tree_sitter_datastar_external_scanner_reset(void *p) {}
unsigned tree_sitter_datastar_external_scanner_serialize(void *p, char *buffer) { return 0; }
void tree_sitter_datastar_external_scanner_deserialize(void *p, const char *b, unsigned n) {}

static inline bool is_plugin_key_char(int32_t c) {
  return (c >= 'a' && c <= 'z') ||
         (c >= 'A' && c <= 'Z') ||
         (c >= '0' && c <= '9') ||
         c == '-';
}

bool tree_sitter_datastar_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols) {
  if (!valid_symbols[PLUGIN_KEY]) {
    return false;
  }

  if (!is_plugin_key_char(lexer->lookahead)) {
    return false;
  }

  while (is_plugin_key_char(lexer->lookahead)) {
    lexer->advance(lexer, false);

    if (lexer->lookahead == '_') {
      lexer->mark_end(lexer);
      lexer->advance(lexer, false);
      if (lexer->lookahead == '_') {
        lexer->result_symbol = PLUGIN_KEY;
        return true;
      }
      return false;
    }
  }

  lexer->mark_end(lexer);
  lexer->result_symbol = PLUGIN_KEY;
  return true;
}
