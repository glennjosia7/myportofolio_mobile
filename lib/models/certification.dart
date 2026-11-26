import 'package:json_annotation/json_annotation.dart';

part 'certification.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Certification {
  const Certification({
    this.id,
    required this.name,
    required this.issuingOrganization,
    required this.issueDate,
    this.expirationDate,
    required this.credentialId,
    required this.credentialUrl,
  });

  @JsonKey(includeToJson: false)
  final int? id;
  final String name;
  final String issuingOrganization;
  final String issueDate;
  final String? expirationDate;
  final String credentialId;
  final String credentialUrl;

  factory Certification.fromJson(Map<String, dynamic> json) =>
      _$CertificationFromJson(json);

  Map<String, dynamic> toJson() => _$CertificationToJson(this);
}
