import XCTest
import SwiftTreeSitter
import TreeSitterDatastar

final class TreeSitterDatastarTests: XCTestCase {
    func testCanLoadGrammar() throws {
        let parser = Parser()
        let language = Language(language: tree_sitter_datastar())
        XCTAssertNoThrow(try parser.setLanguage(language),
                         "Error loading Datastar grammar")
    }
}
