package tree_sitter_datastar_test

import (
	"testing"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
	tree_sitter_datastar "github.com/tree-sitter/tree-sitter-datastar/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_datastar.Language())
	if language == nil {
		t.Errorf("Error loading Datastar grammar")
	}
}
