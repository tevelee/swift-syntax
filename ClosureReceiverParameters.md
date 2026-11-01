# Closure receiver parameters: experimental parser POC

This branch adds the opt-in `ClosureReceiverParameters` parser feature for
closure signatures such as `{ self in count }` and `{ (self: Item) in value }`.
The keyword token is preserved so ASTGen can distinguish a receiver from an
ordinary escaped `` `self` `` parameter. Without the feature, existing typed
`self` parsing is preserved.

The companion compiler sketch is
[tevelee/swift, feature/closure-receiver-parameters](https://github.com/tevelee/swift/tree/feature/closure-receiver-parameters).
The compiler prototype has now passed targeted local compiler and runtime tests;
see its [validation record](https://github.com/tevelee/swift/blob/feature/closure-receiver-parameters/docs/ClosureReceiverParameters.md).
The parser results below independently establish syntax/schema behavior.

## Validation

The local macOS SwiftParser suite passed: 2,759 tests, 3 skipped, 0 failures,
including 22 receiver tests, with raw-syntax validation enabled. CodeGeneration's
16 `ValidateSyntaxNodes` tests also passed. Sources were regenerated using the
repository's generator. A branch-specific GitHub Actions workflow repeats the
parser and schema suites and checks generated sources on Linux.

With a compatible Swift toolchain:

```sh
SKIP_LONG_TESTS=1 SWIFTSYNTAX_ENABLE_RAWSYNTAX_VALIDATION=1 swift test -j 4 \
  --filter SwiftParserTest
swift test --package-path CodeGeneration -j 4 --filter ValidateSyntaxNodes
```

Regenerate after editing the syntax schema or feature list:

```sh
swift run --package-path CodeGeneration -j 4 generate-swift-syntax
```
