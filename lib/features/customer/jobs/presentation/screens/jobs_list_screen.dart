import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/repositories/job_repository.dart';
import 'package:wassali/models/job_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

final jobsProvider = FutureProvider.autoDispose<List<JobModel>>((ref) async {
  final repo = ref.watch(jobRepositoryProvider);
  return repo.fetchJobs();
});

class JobsListScreen extends ConsumerWidget {
  const JobsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobsProvider);

    return Scaffold(
      backgroundColor: ColorTokens.background,
      appBar: AppBar(
        title: const Text('الوظائف وفرص العمل', style: TextStyle(fontWeight: FontWeight.bold, color: ColorTokens.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: ColorTokens.textPrimary),
      ),
      body: jobsAsync.when(
        data: (jobs) {
          if (jobs.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final job = jobs[index];
              return _JobCard(job: job)
                  .animate()
                  .fade(duration: 400.ms, delay: (50 * index).ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: ColorTokens.primary)),
        error: (e, st) => Center(child: Text('حدث خطأ: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('لا توجد وظائف متاحة حالياً', style: TextStyle(fontSize: 18, color: ColorTokens.textMuted, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobModel job;

  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to Details
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: job.logo != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(imageUrl: job.logo!, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.business_rounded, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: ColorTokens.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(job.companyName, style: const TextStyle(color: ColorTokens.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
                    ),
                    const Icon(Icons.bookmark_outline_rounded, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildTag(Icons.location_on_rounded, job.location),
                    const SizedBox(width: 12),
                    _buildTag(Icons.access_time_rounded, _formatEmploymentType(job.employmentType)),
                  ],
                ),
                if (job.salary != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined, size: 16, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(job.salary!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: ColorTokens.textMuted),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: ColorTokens.textMuted, fontSize: 13)),
      ],
    );
  }

  String _formatEmploymentType(String type) {
    switch (type) {
      case 'FULL_TIME': return 'دوام كامل';
      case 'PART_TIME': return 'دوام جزئي';
      case 'FREELANCE': return 'عمل حر';
      case 'INTERNSHIP': return 'تدريب';
      default: return 'عقد';
    }
  }
}
