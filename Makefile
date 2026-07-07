# Makefile: AI Language Coach

.PHONY: setup gen analyze test test-watch test-integration test-golden \
        coverage clean db-lint db-push funcs-deploy verify-env ci \
        admin-setup admin-analyze admin-test admin-build

# Setup dependencies
setup:
	cd frontend && flutter pub get

# Run code generators (Freezed, JSON Serializers, Riverpod providers)
gen:
	cd frontend && dart run build_runner build --delete-conflicting-outputs

# Format and analyze code
analyze:
	cd frontend && dart format .
	cd frontend && flutter analyze

# Run unit and widget tests with coverage
test:
	cd frontend && flutter test --coverage

# Run tests in watch mode
test-watch:
	cd frontend && flutter test --watch

# Run integration tests
test-integration:
	cd frontend && flutter test integration_test/

# Run golden tests and update goldens
test-golden:
	cd frontend && flutter test --update-goldens test/features/golden/

# Generate coverage report (requires lcov)
coverage:
	cd frontend && flutter test --coverage
	cd frontend && genhtml coverage/lcov.info -o coverage/html
	@echo "Coverage report: frontend/coverage/html/index.html"

# Clean build artifacts
clean:
	cd frontend && flutter clean
	cd frontend && dart run build_runner clean

# Run database migrations checks locally
db-lint:
	supabase db lint

# Push database migrations to production
db-push:
	supabase db push

# Deploy backend Edge Functions
funcs-deploy:
	supabase functions deploy --all

# Verify environment variables
verify-env:
	sh infra/scripts/verify_env.sh

# Full CI pipeline (local)
ci: setup analyze test

# Admin Web targets
admin-setup:
	cd apps/admin_web && flutter pub get

admin-analyze:
	cd apps/admin_web && flutter analyze

admin-test:
	cd apps/admin_web && flutter test

admin-build:
	cd apps/admin_web && flutter build web --release
