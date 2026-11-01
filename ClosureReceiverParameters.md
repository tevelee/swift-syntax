# Closure receiver bindings: experimental parser prototype

The `ClosureReceiverParameters` feature preserves an unescaped `self` keyword in a closure's local parameter-name position:

```swift
values.map { self in title }
values.reduce(into: Report()) { self, value in append(value) }
let callback: (Theme, Document) -> String = { theme, self in title + theme.separator }
```

The selected parameter still belongs to an ordinary function type. Both shorthand and typed forms are parsed, including borrowing/consuming/inout modifiers, capture aliases, and receiver selection in any parameter position. Escaped `self` remains an ordinary identifier. Feature-disabled typed self keeps its previous token representation.

The [compiler prototype](https://github.com/tevelee/swift/tree/feature/closure-receiver-parameters) implements receiver-role selection, deferred member lookup, and capture checks. The [pitch](https://github.com/tevelee/swift-evolution/blob/feature/closure-receiver-parameters/proposals/0000-closure-receiver-parameters.md) records the unresolved typed-self compatibility decision.

Revision 0.11 removes receiver-function type grammar and the generated FunctionTypeSyntax receiver/period fields. `@receiver` and dotted callback invocation are not part of this design. Parser acceptance of generic attribute syntax does not imply semantic support for an attribute.

## Validation

Targeted parser tests: 49 passed, including 24 receiver test methods. The full parser run scheduled 2,761 tests with zero failures (three long corpus tests disabled); all 16 CodeGeneration schema tests passed, and generated files reproduce exactly. Logs are recorded in the compiler implementation record. Parser success is separate from compiler semantic/runtime validation.

```sh
SKIP_LONG_TESTS=1 SWIFTSYNTAX_ENABLE_RAWSYNTAX_VALIDATION=1 swift test -j 2 \
  --filter SwiftParserTest --parallel --num-workers 2
swift test --package-path CodeGeneration -j 2 --filter ValidateSyntaxNodes
swift run --package-path CodeGeneration -j 2 generate-swift-syntax
```
