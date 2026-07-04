# Contributing to AI Language Coach

## Development Workflow

1. Fork the repository and create a feature branch from `develop`.
2. Follow the coding standards in `docs/24-Coding-Standards.md`.
3. Write tests for all new code (unit, widget, golden as appropriate).
4. Run the validation pipeline locally before pushing.
5. Open a Pull Request against `develop` with a completed checklist.

## Local Validation

```bash
make setup       # Install dependencies
make gen         # Run code generators
make analyze     # Format + static analysis
make test        # Run all tests with coverage
```

## CI/CD Pipeline

| Workflow | Trigger | Description |
|---|---|---|
| `flutter_ci.yml` | PR/push to `develop`, `main` | Analyze, unit tests, widget tests, integration tests, coverage |
| `flutter_release.yml` | Tag `v*.*.*` | Build APK, AAB, iOS archive; create GitHub Release |
| `supabase_deploy.yml` | Push to `main` | Deploy DB migrations and Edge Functions |
| `coverage_report.yml` | Weekly (Mon) + manual | Full coverage run with Codecov upload |

### Branch Strategy

- `main` — Production-ready code. Merges from `develop` only.
- `develop` — Integration branch. All feature PRs merge here.
- `feature/*` — New features from `develop`.
- `fix/*` — Bug fixes from `develop`.
- `release/*` — Release preparation branches.

### Commit Convention

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

feat(auth): add OAuth login
fix(chat): handle empty message response
test(lessons): add golden tests for lesson cards
ci(workflows): add weekly coverage report
```

Allowed types: `feat`, `fix`, `refactor`, `test`, `docs`, `ci`, `chore`, `style`, `perf`.

## Testing Guidelines

### Test Types

| Type | Location | Command |
|---|---|---|
| Unit tests | `test/` | `flutter test test/features/` |
| Widget tests | `test/` | `flutter test test/features/` |
| Golden tests | `test/features/golden/` | `flutter test --update-goldens` |
| Integration tests | `integration_test/` | `flutter test integration_test/` |

### Coverage

- Target: **80%+** line coverage.
- Run `flutter test --coverage` and review `coverage/lcov.info`.
- Generated code (`*.freezed.dart`, `*.g.dart`) is excluded from coverage.
- Codecov checks block PRs where coverage drops >5%.

### Writing Tests

- **Unit tests**: Test repository and service classes with `mocktail` mocks.
- **Widget tests**: Use `tester.pumpWidget()` with `ProviderScope` for Riverpod widgets.
- **Golden tests**: Place golden PNGs in `test/goldens/`. Run with `--update-goldens` to generate.
- **Integration tests**: Test full user flows using `IntegrationTestWidgetsFlutterBinding`.

## Code Review

All PRs require:
1. At least one approval from a CODEOWNER of the affected paths.
2. Passing CI checks (analyze, test, coverage).
3. No secrets or credentials in the diff.
4. WCAG AA compliant touch targets (48x48dp).

## Security

- Do not commit `.env` files, keystores, or service account JSONs.
- Report vulnerabilities to `security@ailanguagecoach.com`.
- See `SECURITY.md` for disclosure policy.
