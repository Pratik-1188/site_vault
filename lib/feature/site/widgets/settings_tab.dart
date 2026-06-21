import 'package:flutter/material.dart';

import 'package:site_vault/shared/theme/app_radius.dart';
import 'package:site_vault/shared/utils/date_formatter.dart';

import '../model/site.dart';
import '../model/site_status.dart';

class SettingsTab extends StatefulWidget {
  final Site site;
  final Color baseColor;
  final bool isSaving;
  final Future<void> Function(
    String siteId,
    String name,
    String description,
    DateTime startedOn, {
    SiteStatus? status,
  })
  onSaveSiteSettings;

  const SettingsTab({
    super.key,
    required this.site,
    required this.baseColor,
    required this.isSaving,
    required this.onSaveSiteSettings,
  });

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  TextEditingController? _nameEditController;
  TextEditingController? _descEditController;
  DateTime? _selectedStartDate;

  @override
  void dispose() {
    _nameEditController?.dispose();
    _descEditController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    _nameEditController ??= TextEditingController(text: widget.site.name);
    _descEditController ??= TextEditingController(
      text: widget.site.description ?? '',
    );
    _selectedStartDate ??= widget.site.startedOn ?? DateTime.now();

    final isEditable = widget.site.status == SiteStatus.active;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isEditable) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: AppRadius.brSm,
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.site.status == SiteStatus.completed
                        ? Icons.lock_rounded
                        : Icons.delete_forever_rounded,
                    color: theme.colorScheme.onErrorContainer,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.site.status == SiteStatus.completed
                          ? 'This project is marked as COMPLETED. Its settings and status are locked and cannot be modified.'
                          : 'This project is marked as DELETED. All settings are locked in read-only archive mode.',
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              borderRadius: AppRadius.brMd,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Site/Project Configuration',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.baseColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameEditController,
                    enabled: isEditable,
                    decoration: const InputDecoration(
                      labelText: 'Site/Project Name *',
                      prefixIcon: Icon(Icons.domain_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descEditController,
                    enabled: isEditable,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Site/Project Description',
                      prefixIcon: Icon(Icons.description_rounded),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: isEditable
                          ? Colors.transparent
                          : theme.colorScheme.surfaceContainerLow.withValues(
                              alpha: 0.5,
                            ),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      borderRadius: AppRadius.brXs,
                    ),
                    child: ListTile(
                      enabled: isEditable,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      title: Text(
                        'Project Start Date',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        _selectedStartDate!.toReadableString(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      leading: Icon(
                        Icons.calendar_today_rounded,
                        color: isEditable
                            ? widget.baseColor
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      trailing: isEditable
                          ? const Icon(Icons.edit_calendar_rounded)
                          : null,
                      onTap: isEditable
                          ? () => _selectStartDate(context)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (isEditable)
            const SizedBox(height: 24),
          if (isEditable)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: widget.isSaving
                    ? null
                    : () => widget.onSaveSiteSettings(
                        widget.site.id,
                        _nameEditController!.text.trim(),
                        _descEditController!.text.trim(),
                        _selectedStartDate ?? DateTime.now(),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.baseColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.brSm),
                ),
                icon: widget.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                iconAlignment: IconAlignment.start,
                label: const Text(
                  'SAVE SITE CONFIGURATION',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          if (isEditable) ...[
            const SizedBox(height: 24),
            Text(
              'Status Actions',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatusActionCard(
              context: context,
              title: 'Mark Site as Completed',
              description:
                  'Lock the site, keep the record, and stop further edits.',
              icon: Icons.lock_rounded,
              accent: widget.baseColor,
              onPressed: widget.isSaving
                  ? null
                  : () => widget.onSaveSiteSettings(
                      widget.site.id,
                      _nameEditController!.text.trim(),
                      _descEditController!.text.trim(),
                      _selectedStartDate ?? DateTime.now(),
                      status: SiteStatus.completed,
                    ),
            ),
            const SizedBox(height: 12),
            _buildStatusActionCard(
              context: context,
              title: 'Delete This Item',
              description:
                  'Archive the site and soft-delete related expenses.',
              icon: Icons.delete_forever_rounded,
              accent: theme.colorScheme.error,
              destructive: true,
              onPressed: widget.isSaving
                  ? null
                  : () => widget.onSaveSiteSettings(
                      widget.site.id,
                      _nameEditController!.text.trim(),
                      _descEditController!.text.trim(),
                      _selectedStartDate ?? DateTime.now(),
                      status: SiteStatus.deleted,
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  Widget _buildStatusActionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color accent,
    required VoidCallback? onPressed,
    bool destructive = false,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: destructive
              ? theme.colorScheme.error.withValues(alpha: 0.2)
              : accent.withValues(alpha: 0.2),
        ),
        borderRadius: AppRadius.brMd,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: CircleAvatar(
          backgroundColor: destructive
              ? theme.colorScheme.errorContainer
              : accent.withValues(alpha: 0.12),
          child: Icon(
            icon,
            color: destructive ? theme.colorScheme.error : accent,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(description, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onPressed,
      ),
    );
  }
}
