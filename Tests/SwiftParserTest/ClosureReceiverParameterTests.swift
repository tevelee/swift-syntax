//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

@_spi(ExperimentalLanguageFeatures) import SwiftParser
import SwiftSyntax
import XCTest

final class ClosureReceiverParameterTests: ParserTestCase {
  override var languageFeatures: Parser.LanguageFeatures { [.closureReceiverParameters] }

  func testShorthandReceiver() {
    assertParse("_ = { self in self.value }")
  }

  func testTypedReceiver() {
    assertParse("_ = { (self: Item) in self.value }")
  }

  func testReceiverAmongOtherParameters() {
    assertParse("_ = { before, self, after in self.value + before + after }")
  }

  func testCaptureAliasAndReceiver() {
    assertParse("_ = { [owner = self] self in owner.use(self) }")
  }

  func testBorrowingReceiver() {
    assertParse("_ = { (self: borrowing Resource) in self.inspect() }")
  }

  func testConsumingReceiver() {
    assertParse("_ = { (self: consuming Resource) in self.close() }")
  }

  func testInoutReceiver() {
    assertParse("_ = { (self: inout Item) in self.value += 1 }")
  }

  func testEffects() {
    assertParse("_ = { (self: Item) async throws -> Int in try await self.load() }")
  }

  func testNestedCapture() {
    assertParse("_ = { self in self.callback = { [weak self] in self?.finish() } }")
  }

  func testEscapedSelfStaysAnIdentifier() {
    let tree = Parser.parse(source: "_ = { `self` in self.value }", languageFeatures: languageFeatures)
    let parameter = tree.tokens(viewMode: .sourceAccurate).first { $0.text == "`self`" }
    XCTAssertEqual(parameter?.tokenKind, .identifier("`self`"))
    XCTAssertFalse(tree.hasError)
  }

  func testReceiverStaysAKeyword() {
    let tree = Parser.parse(source: "_ = { self in self.value }", languageFeatures: languageFeatures)
    let selfToken = tree.tokens(viewMode: .sourceAccurate).first { $0.text == "self" }
    XCTAssertEqual(selfToken?.tokenKind, .keyword(.self))
    XCTAssertFalse(tree.hasError)
  }

  func testTypedReceiverStaysAKeyword() {
    let tree = Parser.parse(source: "_ = { (self: Item) in self.value }", languageFeatures: languageFeatures)
    let parameter = tree.tokens(viewMode: .sourceAccurate).first { $0.text == "self" }
    XCTAssertEqual(parameter?.tokenKind, .keyword(.self))
    XCTAssertFalse(tree.hasError)
  }

  func testLegacyTypedSelfStaysAnIdentifierWithoutFeature() {
    let tree = Parser.parse(source: "_ = { (self: Item) in self.value }", languageFeatures: [])
    let parameter = tree.tokens(viewMode: .sourceAccurate).first { $0.text == "self" }
    XCTAssertEqual(parameter?.tokenKind, .identifier("self"))
    XCTAssertFalse(tree.hasError)
  }

  func testSelfExpressionIsNotAReceiverSignature() {
    assertParse("_ = { self.value }")
  }

  func testFeatureIsOptIn() {
    assertParse(
      "_ = { self 1️⃣in self.value }",
      diagnostics: [DiagnosticSpec(message: "unexpected code 'in self.value' in closure")],
      languageFeatures: []
    )
  }
}
