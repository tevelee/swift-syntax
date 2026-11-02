@_spi(ExperimentalLanguageFeatures) import SwiftParser
@_spi(ExperimentalLanguageFeatures) import SwiftSyntax
import XCTest

final class PackDestructuringTests: ParserTestCase {
  override var languageFeatures: Parser.LanguageFeatures { [.packDestructuring] }

  func testHeadAndTail() {
    assertParse("func f() { let (head, each tail) = value }")
    assertParse("func f() { let (each prefix, last) = value }")
    assertParse("func f() { let (_, each middle, _) = value }")
    assertParse("func f() { let (_, each _) = value }")
  }

  func testMarkerIsStoredOnTheTupleElement() {
    let source = "let (_, each tail) = value"
    let tree = Parser.parse(source: source, languageFeatures: languageFeatures)
    let declaration = tree.statements.first!.item.as(VariableDeclSyntax.self)!
    let pattern = declaration.bindings.first!.pattern.as(TuplePatternSyntax.self)!
    XCTAssertEqual(pattern.elements.last!.eachKeyword?.text, "each")
    XCTAssertFalse(tree.hasError)
    XCTAssertEqual(tree.description, source)
  }

  func testUppercaseBinding() {
    assertParse("func f() { let (_, each Rest) = value }")
  }

  func testOrdinaryEachIdentifiers() {
    assertParse("let (each, other) = value")
    assertParse("let (`each`, other) = value")
  }

  func testDisabledFeature() {
    let source = "let (_, each tail) = value"
    let tree = Parser.parse(source: source)
    XCTAssertTrue(tree.hasError)
    XCTAssertEqual(tree.description, source)
  }
}
