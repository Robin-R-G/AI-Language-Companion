import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Custom test reporter for CI/CD coverage reports.
class TestCoverageReporter {
  final List<TestResult> _results = [];
  final Stopwatch _stopwatch = Stopwatch();

  void startSuite() {
    _stopwatch.start();
    _results.clear();
  }

  void recordResult(String testName, bool passed, {String? error}) {
    _results.add(
      TestResult(
        name: testName,
        passed: passed,
        error: error,
        timestamp: DateTime.now(),
      ),
    );
  }

  void endSuite() {
    _stopwatch.stop();
    _printReport();
  }

  void _printReport() {
    final passed = _results.where((r) => r.passed).length;
    final failed = _results.where((r) => !r.passed).length;
    final total = _results.length;

    print('\n╔══════════════════════════════════════╗');
    print('║      QA Test Suite Report            ║');
    print('╠══════════════════════════════════════╣');
    print('║ Total Tests: $total');
    print('║ Passed: $passed');
    print('║ Failed: $failed');
    print('║ Duration: ${_stopwatch.elapsedMilliseconds}ms');
    print(
      '║ Coverage: ${total > 0 ? (passed / total * 100).toStringAsFixed(1) : 0}%',
    );
    print('╚══════════════════════════════════════╝');

    if (failed > 0) {
      print('\nFailed Tests:');
      for (final result in _results.where((r) => !r.passed)) {
        print('  ✗ ${result.name}');
        if (result.error != null) {
          print('    Error: ${result.error}');
        }
      }
    }
  }

  /// Generate JSON report for CI/CD integration.
  String toJsonReport() {
    final passed = _results.where((r) => r.passed).length;
    final failed = _results.where((r) => !r.passed).length;

    return '''
{
  "summary": {
    "total": ${_results.length},
    "passed": $passed,
    "failed": $failed,
    "duration_ms": ${_stopwatch.elapsedMilliseconds},
    "coverage_percent": ${_results.isNotEmpty ? (passed / _results.length * 100).toStringAsFixed(1) : 0}
  },
  "timestamp": "${DateTime.now().toIso8601String()}",
  "results": [${_results.map((r) => r.toJson()).join(',')}]
}''';
  }

  /// Write report to file.
  void writeReportToFile(String path) {
    final file = File(path);
    file.writeAsStringSync(toJsonReport());
  }
}

class TestResult {
  final String name;
  final bool passed;
  final String? error;
  final DateTime timestamp;

  TestResult({
    required this.name,
    required this.passed,
    this.error,
    required this.timestamp,
  });

  String toJson() {
    return '''
{
  "name": "$name",
  "passed": $passed,
  "error": ${error != null ? '"$error"' : 'null'},
  "timestamp": "${timestamp.toIso8601String()}"
}''';
  }
}

/// Test category for organized reporting.
enum TestCategory {
  unit,
  widget,
  integration,
  golden,
  accessibility,
  performance,
  smoke,
  edgeFunction,
}
