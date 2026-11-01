# Receiver function types: experimental parser POC

The `ClosureReceiverParameters` feature now parses Kotlin-style receiver
function types:

```swift
func with<T, R>(_ value: T, _ body: T.() throws -> R) rethrows -> R {
  try body(value)
}
let render: Document.(Theme) -> String = { theme in title + theme.separator }
let configure: (inout Configuration).() -> Void = { timeout = 30 }
```

`FunctionTypeSyntax` stores an optional `receiver` and separating `period`.
The receiver is separate from the ordinary parameter list in the syntax tree.
The companion [compiler branch](https://github.com/tevelee/swift/tree/feature/closure-receiver-parameters)
provides the experimental contextual binding, type marker, lookup, and lowering.
The [proposal draft](https://github.com/tevelee/swift-evolution/blob/feature/closure-receiver-parameters/proposals/0000-closure-receiver-parameters.md)
uses receiver function types as its primary design.

The earlier explicit-binder parser tests remain as a regression baseline; this
does not mean both syntaxes are proposed for adoption.

## Validation

Local SwiftParser suite: 2,762 tests, 3 skipped, zero failures, including 25
receiver test methods. All 16 CodeGeneration schema tests passed. Generated
sources are produced with the repository's generator. These checks establish
parser/schema behavior, separately from the compiler's semantic tests.

```sh
SKIP_LONG_TESTS=1 SWIFTSYNTAX_ENABLE_RAWSYNTAX_VALIDATION=1 swift test -j 4 \
  --filter SwiftParserTest
swift test --package-path CodeGeneration -j 4 --filter ValidateSyntaxNodes
swift run --package-path CodeGeneration -j 4 generate-swift-syntax
```
