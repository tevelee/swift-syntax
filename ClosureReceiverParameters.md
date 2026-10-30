# Closure receiver parameters: experimental parser POC

This branch adds the opt-in `ClosureReceiverParameters` parser feature for
closure signatures such as `{ self in count }` and `{ (self: Item) in value }`.
The keyword token is preserved so ASTGen can distinguish a receiver from an
ordinary escaped `` `self` `` parameter. Without the feature, existing typed
`self` parsing is preserved.

The companion compiler sketch is
[tevelee/swift, feature/closure-receiver-parameters](https://github.com/tevelee/swift/tree/feature/closure-receiver-parameters).
**That compiler has not yet been built or executed.** Parser tests do not prove
receiver lookup, capture, ownership, or lifetime semantics.

## Validation

The focused slice passed 40 parser tests, including 15 new receiver tests, with
raw-syntax validation enabled. CodeGeneration's 16 `ValidateSyntaxNodes` tests
also passed. Sources were regenerated using the repository's generator.

With a compatible Swift toolchain:

```sh
SKIP_LONG_TESTS=1 SWIFTSYNTAX_ENABLE_RAWSYNTAX_VALIDATION=1 swift test -j 4 \
  --filter 'ClosureReceiverParameterTests|ClosureMissingInTests|TrailingClosuresTests|ExpressionTests.testClosureLiterals'
swift test --package-path CodeGeneration -j 4 --filter ValidateSyntaxNodes
```

Regenerate after editing the syntax schema or feature list:

```sh
swift run --package-path CodeGeneration -j 4 generate-swift-syntax
```
