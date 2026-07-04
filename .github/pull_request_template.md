## Pull Request Summary

### Description
[Provide a brief description of the changes made, explaining the implementation details or bug fix context]

### Type of Change
- [ ] Feature (New user-facing functionality)
- [ ] Fix (Non-breaking bug resolution)
- [ ] Refactor (Code changes for readability or layout improvements)
- [ ] Docs (Documentation-only update)
- [ ] Test (Adding missing test coverages)
- [ ] CI (Infrastructure, workflows, automation)

### Related Issues
Closes #

### Breaking Changes
[Does this PR introduce any breaking changes? If so, describe and explain migration path]

---

## Contributor Verification Checklist

Before requesting reviews, verify:
- [ ] **Clean Architecture compliance:** Domain layer remains pure Dart without UI dependencies.
- [ ] **Linter & Analyzer:** `flutter analyze` runs successfully without warnings.
- [ ] **Automated Tests:** `flutter test` executes and passes all test blocks.
- [ ] **Code Coverage:** Coverage does not drop below 80%. Run `flutter test --coverage` to verify.
- [ ] **No Secrets:** No `.env` files, production database passwords, or API keys are committed.
- [ ] **State Cleanliness:** Riverpod controllers utilize `autoDispose` hooks where appropriate.
- [ ] **Shimmer UI States:** Shimmer skeletons are visible during asynchronous fetches.
- [ ] **Empty UI States:** Empty states contain illustrations and CTA buttons.
- [ ] **WCAG AA Touch Targets:** Tap targets are at least **48x48dp** in dimensions.
- [ ] **Generated Code:** `dart run build_runner build` succeeds without conflicts.

---

### Screenshots
[Attach before/after screenshots for UI changes]
