import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/repositories/job_repository.dart';
import 'package:wassali/models/job_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wassali/features/customer/jobs/presentation/screens/create_job_screen.dart';

final myJobsProvider = FutureProvider.autoDispose<List<JobModel>>((ref) async {
  final repo = ref.watch(jobRepositoryProvider);
  return repo.getMyJobs();
});

class MyJobsScreen extends ConsumerWidget {
  const MyJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(myJobsProvider);

    return Scaffold(
      backgroundColor: ColorTokens.background,
      appBar: AppBar(
        title: const Text('وظائفي', style: TextStyle(fontWeight: FontWeight.bold, color: ColorTokens.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: ColorTokens.textPrimary),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateJobScreen()));
        },
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: jobsAsync.when(
        data: (jobs) {
          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_outline_rounded, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('لم تقم بنشر أي وظائف بعد', style: TextStyle(color: ColorTokens.textMuted, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final job = jobs[index];
              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                  child: job.logo != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(10), child: CachedNetworkImage(imageUrl: job.logo!, fit: BoxFit.cover))
                      : const Icon(Icons.business_rounded, color: Colors.grey),
                ),
                title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${job.companyName} • المشاهدات: ${job.viewsCount}', style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.edit_rounded, color: Colors.grey, size: 20),
                onTap: () {},
              ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('خطأ في التحميل')),
      ),
    );
  }
}
