import 'package:mocktail/mocktail.dart';
import 'package:site_vault/feature/site/model/site.dart';
import 'package:site_vault/feature/site/repository/site_repository.dart';

/// A mock implementation of [SiteRepository] for test isolated execution.
class MockSiteRepository extends Mock implements SiteRepository {}

/// A helper function to create [Site] fixtures with sensible default values.
Site makeSite({
  String id = 'site-1',
  String firmId = 'firm-a',
  String name = 'Test Site',
  String? description,
  DateTime? startedOn,
  DateTime? completedOn,
  String status = 'active',
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = DateTime.now();
  return Site(
    id: id,
    firmId: firmId,
    name: name,
    description: description,
    startedOn: startedOn,
    completedOn: completedOn,
    status: status,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}
