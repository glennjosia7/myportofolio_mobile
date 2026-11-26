import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/certification.dart';

const _completePayload = <String, dynamic>{
  'id': 42,
  'name': 'Cloud Architecture Associate',
  'issuing_organization': 'Example Cloud Institute',
  'issue_date': '2026-05-10',
  'expiration_date': '2029-05-10',
  'credential_id': 'QA-CERT-042',
  'credential_url': 'https://example.com/verify/QA-CERT-042',
  'star_count': 3,
  'is_starred': true,
  'starred_by_names': 'qa-user',
};

void main() {
  test(
    'Certification decodes complete DRF payload and ignores star metadata',
    () {
      final certification = Certification.fromJson(_completePayload);

      expect(certification.id, 42);
      expect(certification.name, 'Cloud Architecture Associate');
      expect(certification.issuingOrganization, 'Example Cloud Institute');
      expect(certification.issueDate, '2026-05-10');
      expect(certification.expirationDate, '2029-05-10');
      expect(certification.credentialId, 'QA-CERT-042');
      expect(
        certification.credentialUrl,
        'https://example.com/verify/QA-CERT-042',
      );
    },
  );

  test('missing or explicit null expiration_date decodes to null', () {
    final withoutKey = Map<String, dynamic>.from(_completePayload)
      ..remove('expiration_date');
    final withNull = <String, dynamic>{
      ..._completePayload,
      'expiration_date': null,
    };

    expect(Certification.fromJson(withoutKey).expirationDate, isNull);
    expect(Certification.fromJson(withNull).expirationDate, isNull);
  });

  test('toJson emits snake_case, excludes id and star metadata, and keeps date-only values', () {
    final saved = Certification.fromJson(_completePayload);
    expect(saved.toJson(), <String, dynamic>{
      'name': 'Cloud Architecture Associate',
      'issuing_organization': 'Example Cloud Institute',
      'issue_date': '2026-05-10',
      'expiration_date': '2029-05-10',
      'credential_id': 'QA-CERT-042',
      'credential_url': 'https://example.com/verify/QA-CERT-042',
    });

    const unsaved = Certification(
      name: 'Security Foundations',
      issuingOrganization: 'Test Academy',
      issueDate: '2026-11-26',
      credentialId: 'QA-SEC-001',
      credentialUrl: 'https://example.com/verify/QA-SEC-001',
    );
    final json = unsaved.toJson();
    expect(json.containsKey('id'), isFalse);
    expect(json['expiration_date'], isNull);
    expect(json['expiration_date'], isNot('null'));
    expect(json['issue_date'], '2026-11-26');
  });

  test('invalid DRF payload throws TypeError consistent with ApiClient', () {
    final missingName = Map<String, dynamic>.from(_completePayload)
      ..remove('name');
    final wrongIdType = <String, dynamic>{
      ..._completePayload,
      'id': 'not-an-int',
    };

    expect(
      () => Certification.fromJson(missingName),
      throwsA(isA<TypeError>()),
    );
    expect(
      () => Certification.fromJson(wrongIdType),
      throwsA(isA<TypeError>()),
    );
  });
}
