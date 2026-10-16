import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme/app_theme.dart';
import '../data/models/farm_model.dart';
import '../data/services/firestore_service.dart';
import 'common/app_button.dart';
import 'common/app_text_field.dart';
import 'common/sheet_container.dart';

// ── Toast ────────────────────────────────────────────────────

/// Toast kapsul di dasar layar (global-states.md). [bottomOffset] menaikkannya
/// agar tidak menutup tombol utama yang menempel di dasar.
void showAppToast(
  String message, {
  IconData icon = Icons.check_circle_outline,
  String? actionLabel,
  VoidCallback? onAction,
  double bottomOffset = AppSpace.xl,
}) {
  Get.closeAllSnackbars();
  Get.showSnackbar(
    GetSnackBar(
      messageText: Row(
        children: [
          Icon(icon, color: AppColors.onAccent, size: 24),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Text(
              message,
              style: AppText.body(
                size: 16,
                weight: FontWeight.w500,
                color: AppColors.onAccent,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
      mainButton: actionLabel == null
          ? null
          : TextButton(
              onPressed: () {
                Get.closeAllSnackbars();
                onAction?.call();
              },
              style: TextButton.styleFrom(
                minimumSize: const Size(AppSize.touch, AppSize.touch),
                foregroundColor: AppColors.surfaceSecondary,
              ),
              child: Text(
                actionLabel,
                style: AppText.body(
                  size: 16,
                  weight: FontWeight.w700,
                  color: AppColors.surfaceSecondary,
                  height: 1.2,
                ),
              ),
            ),
      duration: Duration(seconds: actionLabel == null ? 6 : 8),
      backgroundColor: AppColors.foregroundPrimary,
      borderRadius: AppRadius.full,
      margin: EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, bottomOffset),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.xl,
        vertical: AppSpace.sm,
      ),
      snackPosition: SnackPosition.BOTTOM,
    ),
  );
}

// ── Fase tanam ───────────────────────────────────────────────

class FarmPhase {
  const FarmPhase(this.label, this.stage, this.icon, this.description);

  final String label;
  final CropStage stage;
  final IconData icon;
  final String description;

  static const all = [
    FarmPhase('Bibit', CropStage.seedling, Icons.eco_outlined,
        'Tanaman masih kecil di persemaian'),
    FarmPhase('Vegetatif', CropStage.vegetative, Icons.grass,
        'Daun dan batang sedang tumbuh'),
    FarmPhase('Berbunga', CropStage.flowering, Icons.local_florist_outlined,
        'Mulai keluar bunga'),
    FarmPhase('Berbuah', CropStage.fruiting, Icons.apple, 'Buah mulai terbentuk'),
    FarmPhase('Panen', CropStage.harvesting, Icons.agriculture_outlined,
        'Buah siap dipetik'),
  ];
}

// ── Sheet ────────────────────────────────────────────────────

Future<T?> _openSheet<T>(Widget child) => Get.bottomSheet<T>(
  SheetContainer(child: child),
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
);

class _SheetTitle extends StatelessWidget {
  const _SheetTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpace.md),
    child: Text(text, style: AppText.heading(size: 18)),
  );
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.selected = false,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final bool danger;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.foregroundPrimary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: selected ? AppColors.surfaceSecondary : Colors.transparent,
          borderRadius: AppRadius.inputBorder,
          child: InkWell(
            borderRadius: AppRadius.inputBorder,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.md,
                  vertical: AppSpace.sm,
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 24, color: color),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppText.body(
                              size: 16,
                              weight: FontWeight.w600,
                              color: color,
                              height: 1.3,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: AppText.body(
                                size: 13,
                                color: danger
                                    ? AppColors.danger
                                    : AppColors.foregroundSecondary,
                                height: 1.3,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (selected)
                      const Icon(
                        Icons.check_circle,
                        size: 24,
                        color: AppColors.accentPrimary,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum FarmMenuAction { rename, delete }

Future<FarmMenuAction?> showFarmMenuSheet() => _openSheet<FarmMenuAction>(
  Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SheetRow(
        icon: Icons.edit_outlined,
        title: 'Ubah Nama Lahan',
        onTap: () => Get.back(result: FarmMenuAction.rename),
      ),
      _SheetRow(
        icon: Icons.delete_outline,
        title: 'Hapus Lahan',
        subtitle: 'Lahan dan datanya dihapus permanen',
        danger: true,
        onTap: () => Get.back(result: FarmMenuAction.delete),
      ),
      const SizedBox(height: AppSpace.sm),
      AppButton.secondary(label: 'Batal', onPressed: () => Get.back()),
    ],
  ),
);

Future<FarmPhase?> showPhaseSheet(CropStage current) => _openSheet<FarmPhase>(
  Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SheetTitle('Pilih Fase Tanam'),
      for (final phase in FarmPhase.all)
        _SheetRow(
          icon: phase.icon,
          title: phase.label,
          subtitle: phase.description,
          selected: phase.stage == current,
          onTap: () => Get.back(result: phase),
        ),
      const SizedBox(height: AppSpace.sm),
      AppButton.secondary(label: 'Batal', onPressed: () => Get.back()),
    ],
  ),
);

/// Mengembalikan nilai [FarmModel.lastPesticideTime] yang dipilih.
Future<String?> showSpraySheet() => _openSheet<String>(const _SpraySheet());

class _SpraySheet extends StatefulWidget {
  const _SpraySheet();

  @override
  State<_SpraySheet> createState() => _SpraySheetState();
}

class _SpraySheetState extends State<_SpraySheet> {
  static const _options = [
    ('Kurang dari 3 hari lalu', 'Risiko diturunkan sementara', 'Baru saja (< 3 hari)'),
    ('Sekitar seminggu lalu', 'Risiko dihitung seperti biasa', 'Seminggu lalu'),
  ];

  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SheetTitle('Kapan Anda menyemprot?'),
        for (final o in _options)
          _SheetRow(
            icon: Icons.water_drop_outlined,
            title: o.$1,
            subtitle: o.$2,
            selected: _selected == o.$3,
            onTap: () => setState(() => _selected = o.$3),
          ),
        const SizedBox(height: AppSpace.sm),
        AppButton(
          label: 'Simpan',
          onPressed: _selected == null ? null : () => Get.back(result: _selected),
        ),
        const SizedBox(height: AppSpace.md),
        AppButton.secondary(label: 'Batal', onPressed: () => Get.back()),
      ],
    );
  }
}

// ── Dialog ───────────────────────────────────────────────────

Dialog _dialogShell({required List<Widget> children}) => Dialog(
  backgroundColor: AppColors.surfaceCard,
  insetPadding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sheet)),
  child: Padding(
    padding: const EdgeInsets.all(AppSpace.lg),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  ),
);

Future<String?> showRenameDialog(String initial) =>
    Get.dialog<String>(_RenameDialog(initial: initial));

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});
  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Nama lahan belum diisi.');
      return;
    }
    Get.back(result: name);
  }

  @override
  Widget build(BuildContext context) {
    return _dialogShell(
      children: [
        Text('Ubah Nama Lahan', style: AppText.heading(size: 18)),
        const SizedBox(height: AppSpace.md),
        AppTextField(
          label: 'Nama lahan',
          controller: _controller,
          errorText: _error,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: AppSpace.xl),
        AppButton(label: 'Simpan', onPressed: _save),
        const SizedBox(height: AppSpace.md),
        AppButton.secondary(label: 'Batal', onPressed: () => Get.back()),
      ],
    );
  }
}

Future<bool> showDeleteDialog(String farmName) async {
  final ok = await Get.dialog<bool>(
    _dialogShell(
      children: [
        Text('Hapus Lahan?', style: AppText.heading(size: 18)),
        const SizedBox(height: AppSpace.md),
        Text.rich(
          TextSpan(
            style: AppText.body(size: 14, height: 1.45),
            children: [
              const TextSpan(text: 'Anda yakin ingin menghapus '),
              TextSpan(
                text: farmName,
                style: AppText.body(
                  size: 16,
                  weight: FontWeight.w700,
                  color: AppColors.foregroundPrimary,
                ),
              ),
              const TextSpan(text: '? Data lahan ini tidak bisa dikembalikan.'),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.xl),
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: 'Batal',
                onPressed: () => Get.back(result: false),
              ),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: AppButton.danger(
                label: 'Ya, Hapus',
                onPressed: () => Get.back(result: true),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Menghapus lahan lalu menampilkan toast "Batalkan". Batalkan membuat ulang
/// lahan yang sama (id baru). Mengembalikan false bila penghapusan gagal.
Future<bool> deleteFarmWithUndo(FarmModel farm) async {
  final service = FirestoreService();
  try {
    await service.deleteFarm(farm.id!);
  } catch (_) {
    showAppToast(
      'Lahan belum bisa dihapus. Periksa internet Anda.',
      icon: Icons.error_outline,
    );
    return false;
  }
  showAppToast(
    '${farm.farmName} dihapus',
    icon: Icons.delete_outline,
    actionLabel: 'Batalkan',
    onAction: () async {
      try {
        await service.addFarm(farm.copyWith());
        showAppToast('${farm.farmName} dipulihkan');
      } catch (_) {
        showAppToast(
          'Lahan belum bisa dipulihkan.',
          icon: Icons.error_outline,
        );
      }
    },
  );
  return true;
}
