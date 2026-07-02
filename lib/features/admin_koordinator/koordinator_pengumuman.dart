import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/pengumuman_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/text_styles.dart';
import '../../core/button_styles.dart';
import '../../core/input_decoration.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/error_state_widget.dart';

class KoordinatorPengumuman extends ConsumerStatefulWidget {
  const KoordinatorPengumuman({super.key});

  @override
  ConsumerState<KoordinatorPengumuman> createState() => _KoordinatorPengumumanState();
}

class _KoordinatorPengumumanState extends ConsumerState<KoordinatorPengumuman> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  void _submit() {
    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      final currentUser = ref.read(authProvider);
      final authorName = currentUser?.name ?? 'Koordinator';
      ref.read(pengumumanProvider.notifier).addAnnouncement(
        _titleController.text,
        _contentController.text,
        authorName,
      );
      _titleController.clear();
      _contentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengumuman berhasil di-broadcast!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(sortedAnnouncementsProvider);
    final isWide = MediaQuery.of(context).size.width > 800;

    final formWidget = AppCard(
      role: 'koordinator',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Buat Pengumuman Baru', style: AppTextStyles.h4),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: AppInputDecoration.create(hintText: 'Judul Pengumuman', labelText: 'Judul'),
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: AppInputDecoration.create(hintText: 'Isi Pengumuman', labelText: 'Isi Pengumuman'),
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          AppButton.clean(
            text: 'Broadcast Sekarang',
            onPressed: _submit,
          ),
        ],
      ),
    );

    final listWidget = announcementsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorStateWidget(
        message: e.toString(),
        onRetry: () => ref.refresh(pengumumanProvider),
      ),
      data: (announcements) {
        if (announcements.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text('Belum ada pengumuman.', style: AppTextStyles.body),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: !isWide,
          physics: isWide ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final a = announcements[index];
            final date = DateTime.parse(a['created_at'] ?? DateTime.now().toIso8601String());
            return AppCard(
              role: 'koordinator',
              margin: const EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.zero,
              child: ListTile(
                title: Text(a['judul'] ?? '', style: AppTextStyles.h5),
                subtitle: Text(a['isi'] ?? '', style: AppTextStyles.body),
                trailing: Text('${date.day}/${date.month}', style: AppTextStyles.bodySmall),
              ),
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: buildCustomAppBar(
        context: context,
        role: 'koordinator',
        isNested: true,
        title: 'Pengumuman',
      ),
      body: isWide
          ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: SingleChildScrollView(child: formWidget)),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: listWidget),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  formWidget,
                  const SizedBox(height: 24),
                  Text('Riwayat Pengumuman', style: AppTextStyles.h3),
                  const SizedBox(height: 16),
                  listWidget,
                ],
              ),
            ),
    );
  }
}
