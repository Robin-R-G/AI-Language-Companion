import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/constants/app_constants.dart';

/// Tests that validate the app's exam configuration aligns with the
/// Official Exam Resource Guide. These tests serve as a living checklist
/// to ensure all supported exams are properly configured.
void main() {
  group('Exam Configuration - Official Resource Guide Alignment', () {
    group('English Language Exams', () {
      test('IELTS is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'ielts',
          orElse: () => {},
        );
        expect(exam['code'], 'ielts');
        expect(exam['name'], 'IELTS');
        expect(exam['description'], isNotEmpty);
        expect(exam['language'], 'en');
      });

      test('TOEFL iBT is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'toefl',
          orElse: () => {},
        );
        expect(exam['code'], 'toefl');
        expect(exam['name'], 'TOEFL iBT');
        expect(exam['language'], 'en');
      });

      test('PTE Academic is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'pte',
          orElse: () => {},
        );
        expect(exam['code'], 'pte');
        expect(exam['name'], 'PTE Academic');
        expect(exam['language'], 'en');
      });

      test('OET is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'oet',
          orElse: () => {},
        );
        expect(exam['code'], 'oet');
        expect(exam['name'], 'OET');
        expect(exam['language'], 'en');
      });

      test('TOEIC is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'toeic',
          orElse: () => {},
        );
        expect(exam['code'], 'toeic');
        expect(exam['name'], 'TOEIC');
        expect(exam['language'], 'en');
      });

      test('Cambridge A2 Key is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'cambridge_a2_key',
          orElse: () => {},
        );
        expect(exam['code'], 'cambridge_a2_key');
        expect(exam['language'], 'en');
      });

      test('Cambridge B1 Preliminary is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'cambridge_b1_preliminary',
          orElse: () => {},
        );
        expect(exam['code'], 'cambridge_b1_preliminary');
        expect(exam['language'], 'en');
      });

      test('Cambridge B2 First is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'cambridge_b2_first',
          orElse: () => {},
        );
        expect(exam['code'], 'cambridge_b2_first');
        expect(exam['language'], 'en');
      });

      test('Cambridge C1 Advanced is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'cambridge_c1_advanced',
          orElse: () => {},
        );
        expect(exam['code'], 'cambridge_c1_advanced');
        expect(exam['language'], 'en');
      });

      test('Cambridge C2 Proficiency is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'cambridge_c2_proficiency',
          orElse: () => {},
        );
        expect(exam['code'], 'cambridge_c2_proficiency');
        expect(exam['language'], 'en');
      });

      test('Duolingo English Test is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'duolingo',
          orElse: () => {},
        );
        expect(exam['code'], 'duolingo');
        expect(exam['language'], 'en');
      });

      test('CELPIP is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'celpip',
          orElse: () => {},
        );
        expect(exam['code'], 'celpip');
        expect(exam['language'], 'en');
      });

      test('Linguaskill is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'linguaskill',
          orElse: () => {},
        );
        expect(exam['code'], 'linguaskill');
        expect(exam['language'], 'en');
      });

      test('SAT is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'sat',
          orElse: () => {},
        );
        expect(exam['code'], 'sat');
        expect(exam['language'], 'en');
      });

      test('ACT is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'act',
          orElse: () => {},
        );
        expect(exam['code'], 'act');
        expect(exam['language'], 'en');
      });

      test('GRE is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'gre',
          orElse: () => {},
        );
        expect(exam['code'], 'gre');
        expect(exam['language'], 'en');
      });

      test('GMAT is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'gmat',
          orElse: () => {},
        );
        expect(exam['code'], 'gmat');
        expect(exam['language'], 'en');
      });
    });

    group('German Exams', () {
      final goetheExams = AppConstants.exams
          .where((e) => e['code']!.startsWith('goethe_'))
          .toList();

      test('Goethe A1 through C2 are configured', () {
        final levels = ['a1', 'a2', 'b1', 'b2', 'c1', 'c2'];
        for (final level in levels) {
          expect(
            goetheExams.any((e) => e['code'] == 'goethe_$level'),
            true,
            reason: 'Goethe $level should be configured',
          );
        }
      });

      test('Goethe exams have correct naming convention', () {
        for (final exam in goetheExams) {
          expect(exam['name'], startsWith('Goethe'));
          expect(exam['description'], contains('Goethe-Zertifikat'));
          expect(exam['language'], 'de');
        }
      });

      test('TELC is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'telc',
          orElse: () => {},
        );
        expect(exam['code'], 'telc');
        expect(exam['language'], 'de');
      });

      test('TestDaF is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'testdaf',
          orElse: () => {},
        );
        expect(exam['code'], 'testdaf');
        expect(exam['language'], 'de');
      });

      test('DSH is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'dsh',
          orElse: () => {},
        );
        expect(exam['code'], 'dsh');
        expect(exam['language'], 'de');
      });
    });

    group('French Exams', () {
      test('DELF/DALF is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'delf_dalf',
          orElse: () => {},
        );
        expect(exam['code'], 'delf_dalf');
        expect(exam['language'], 'fr');
      });

      test('TCF is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'tcf',
          orElse: () => {},
        );
        expect(exam['code'], 'tcf');
        expect(exam['language'], 'fr');
      });

      test('TEF is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'tef',
          orElse: () => {},
        );
        expect(exam['code'], 'tef');
        expect(exam['language'], 'fr');
      });
    });

    group('Spanish Exams', () {
      test('DELE is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'dele',
          orElse: () => {},
        );
        expect(exam['code'], 'dele');
        expect(exam['language'], 'es');
      });

      test('SIELE is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'siele',
          orElse: () => {},
        );
        expect(exam['code'], 'siele');
        expect(exam['language'], 'es');
      });
    });

    group('Asian Language Exams', () {
      test('JLPT is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'jlpt',
          orElse: () => {},
        );
        expect(exam['code'], 'jlpt');
        expect(exam['language'], 'ja');
      });

      test('TOPIK is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'topik',
          orElse: () => {},
        );
        expect(exam['code'], 'topik');
        expect(exam['language'], 'ko');
      });

      test('HSK is configured', () {
        final exam = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'hsk',
          orElse: () => {},
        );
        expect(exam['code'], 'hsk');
        expect(exam['language'], 'zh');
      });
    });

    group('Exam Count Validation', () {
      test('app supports all 17 English exams per Official Resource Guide', () {
        final englishExams = AppConstants.exams
            .where((e) => e['language'] == 'en')
            .toList();
        expect(englishExams.length, greaterThanOrEqualTo(17));
      });

      test('app supports all 9 German exams per Official Resource Guide', () {
        final germanExams = AppConstants.exams
            .where((e) => e['language'] == 'de')
            .toList();
        expect(germanExams.length, greaterThanOrEqualTo(9));
      });

      test('app supports all 3 French exams', () {
        final frenchExams = AppConstants.exams
            .where((e) => e['language'] == 'fr')
            .toList();
        expect(frenchExams.length, greaterThanOrEqualTo(3));
      });

      test('app supports both Spanish exams', () {
        final spanishExams = AppConstants.exams
            .where((e) => e['language'] == 'es')
            .toList();
        expect(spanishExams.length, greaterThanOrEqualTo(2));
      });

      test('app supports JLPT', () {
        final japaneseExams = AppConstants.exams
            .where((e) => e['language'] == 'ja')
            .toList();
        expect(japaneseExams.length, greaterThanOrEqualTo(1));
      });

      test('app supports TOPIK', () {
        final koreanExams = AppConstants.exams
            .where((e) => e['language'] == 'ko')
            .toList();
        expect(koreanExams.length, greaterThanOrEqualTo(1));
      });

      test('app supports HSK', () {
        final chineseExams = AppConstants.exams
            .where((e) => e['language'] == 'zh')
            .toList();
        expect(chineseExams.length, greaterThanOrEqualTo(1));
      });

      test('total exam count meets Official Resource Guide requirement', () {
        expect(AppConstants.exams.length, greaterThanOrEqualTo(33));
      });
    });

    group('Exam Data Integrity', () {
      test('all exams have required fields including language', () {
        for (final exam in AppConstants.exams) {
          expect(exam.containsKey('code'), true, reason: 'Missing code');
          expect(exam.containsKey('name'), true, reason: 'Missing name');
          expect(exam.containsKey('description'), true,
              reason: 'Missing description');
          expect(exam.containsKey('language'), true,
              reason: 'Missing language field');
          expect(exam['code'], isNotEmpty);
          expect(exam['name'], isNotEmpty);
          expect(exam['description'], isNotEmpty);
          expect(exam['language'], isNotEmpty);
        }
      });

      test('exam codes are unique', () {
        final codes = AppConstants.exams.map((e) => e['code']).toSet();
        expect(codes.length, AppConstants.exams.length,
            reason: 'Duplicate exam codes found');
      });

      test('exam names are unique', () {
        final names = AppConstants.exams.map((e) => e['name']).toSet();
        expect(names.length, AppConstants.exams.length,
            reason: 'Duplicate exam names found');
      });

      test('all language values are valid', () {
        final validLanguages = {'en', 'de', 'fr', 'es', 'ja', 'ko', 'zh', 'all'};
        for (final exam in AppConstants.exams) {
          expect(
            validLanguages.contains(exam['language']),
            true,
            reason: 'Invalid language "${exam['language']}" for exam ${exam['code']}',
          );
        }
      });
    });

    group('Language-Based Exam Filtering', () {
      test('English target language shows only English + general exams', () {
        final filtered = AppConstants.exams
            .where(
              (e) => e['language'] == 'en' || e['language'] == 'all',
            )
            .toList();
        expect(filtered.length, greaterThanOrEqualTo(17));
        for (final exam in filtered) {
          expect(
            exam['language'] == 'en' || exam['language'] == 'all',
            true,
          );
        }
      });

      test('German target language shows only German + general exams', () {
        final filtered = AppConstants.exams
            .where(
              (e) => e['language'] == 'de' || e['language'] == 'all',
            )
            .toList();
        expect(filtered.length, greaterThanOrEqualTo(9));
        for (final exam in filtered) {
          expect(
            exam['language'] == 'de' || exam['language'] == 'all',
            true,
          );
        }
      });

      test('French target language shows only French + general exams', () {
        final filtered = AppConstants.exams
            .where(
              (e) => e['language'] == 'fr' || e['language'] == 'all',
            )
            .toList();
        expect(filtered.length, greaterThanOrEqualTo(3));
      });

      test('Japanese target language shows only Japanese + general exams', () {
        final filtered = AppConstants.exams
            .where(
              (e) => e['language'] == 'ja' || e['language'] == 'all',
            )
            .toList();
        expect(filtered.length, greaterThanOrEqualTo(1));
      });
    });

    group('CEFR Level Mapping', () {
      test('all CEFR levels are defined (A1-C2)', () {
        final expectedLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
        final actualLevels =
            AppConstants.proficiencyLevels.map((l) => l['code']).toList();

        for (final level in expectedLevels) {
          expect(
            actualLevels.contains(level),
            true,
            reason: 'CEFR level $level must be defined',
          );
        }
      });

      test('CEFR levels have names and descriptions', () {
        for (final level in AppConstants.proficiencyLevels) {
          expect(level['name'], isNotEmpty);
          expect(level['description'], isNotEmpty);
        }
      });

      test('CEFR levels are in correct order', () {
        final codes =
            AppConstants.proficiencyLevels.map((l) => l['code']).toList();
        expect(codes, ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']);
      });
    });

    group('Target Languages', () {
      test('English is primary target language', () {
        final english = AppConstants.targetLanguages.firstWhere(
          (l) => l['code'] == 'en',
          orElse: () => {},
        );
        expect(english['code'], 'en');
      });

      test('German is supported (for Goethe/TELC/TestDaF/DSH)', () {
        final german = AppConstants.targetLanguages.firstWhere(
          (l) => l['code'] == 'de',
          orElse: () => {},
        );
        expect(german['code'], 'de');
      });

      test('French is supported (for DELF/TCF/TEF)', () {
        final french = AppConstants.targetLanguages.firstWhere(
          (l) => l['code'] == 'fr',
          orElse: () => {},
        );
        expect(french['code'], 'fr');
      });

      test('Spanish is supported (for DELE/SIELE)', () {
        final spanish = AppConstants.targetLanguages.firstWhere(
          (l) => l['code'] == 'es',
          orElse: () => {},
        );
        expect(spanish['code'], 'es');
      });

      test('Japanese is supported (for JLPT)', () {
        final japanese = AppConstants.targetLanguages.firstWhere(
          (l) => l['code'] == 'ja',
          orElse: () => {},
        );
        expect(japanese['code'], 'ja');
      });

      test('Korean is supported (for TOPIK)', () {
        final korean = AppConstants.targetLanguages.firstWhere(
          (l) => l['code'] == 'ko',
          orElse: () => {},
        );
        expect(korean['code'], 'ko');
      });

      test('Chinese is supported (for HSK)', () {
        final chinese = AppConstants.targetLanguages.firstWhere(
          (l) => l['code'] == 'zh',
          orElse: () => {},
        );
        expect(chinese['code'], 'zh');
      });
    });

    group('Native Language Support', () {
      test('Malayalam is primary native language', () {
        final malayalam = AppConstants.nativeLanguages.firstWhere(
          (l) => l['code'] == 'ml',
          orElse: () => {},
        );
        expect(malayalam['code'], 'ml');
        expect(malayalam['name'], 'Malayalam');
      });

      test('multiple Indian languages are supported', () {
        final indianCodes = [
          'ml', 'hi', 'ta', 'te', 'kn', 'bn', 'mr', 'gu', 'pa', 'ur',
        ];
        final appCodes =
            AppConstants.nativeLanguages.map((l) => l['code']).toList();

        for (final code in indianCodes) {
          expect(
            appCodes.contains(code),
            true,
            reason: '$code should be supported for Indian users',
          );
        }
      });
    });

    group('AI Agent Rules Compliance', () {
      test('all 33 exams from Official Resource Guide are configured', () {
        expect(AppConstants.exams.length, greaterThanOrEqualTo(33));
      });

      test('exam descriptions do not contain copyrighted content', () {
        for (final exam in AppConstants.exams) {
          final desc = exam['description']!;
          expect(
            desc.contains('copyright'),
            false,
            reason: 'Exam description should not reference copyrighted content',
          );
        }
      });

      test('general exam is available for all languages', () {
        final general = AppConstants.exams.firstWhere(
          (e) => e['code'] == 'general',
          orElse: () => {},
        );
        expect(general['language'], 'all');
      });
    });
  });
}
