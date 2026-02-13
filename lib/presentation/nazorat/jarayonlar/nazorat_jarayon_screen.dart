import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yoshlar/data/model/activity.dart';
import 'package:yoshlar/data/model/officer.dart';
import 'package:yoshlar/data/service/officer_service.dart';
import 'package:yoshlar/logic/activity/activity_list_cubit.dart';
import 'package:yoshlar/logic/activity/activity_list_state.dart';
import 'package:yoshlar/presentation/nazorat/yoshlar/nazorat_yoshlar_item/history_into_page.dart';

class ProcessBody extends StatefulWidget {
  const ProcessBody({super.key});

  @override
  State<ProcessBody> createState() => _ProcessBodyState();
}

class _ProcessBodyState extends State<ProcessBody> {
  final ScrollController _scrollController = ScrollController();
  List<OfficerModel> _officers = [];
  int? _selectedOfficerId;

  @override
  void initState() {
    super.initState();
    context.read<ActivityListCubit>().loadActivities();
    _loadOfficers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ActivityListCubit>().loadMore();
    }
  }

  Future<void> _loadOfficers() async {
    try {
      final officers = await context.read<OfficerService>().getOfficers();
      if (mounted) {
        setState(() => _officers = officers);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityListCubit, ActivityListState>(
      builder: (context, state) {
        final activities = state is ActivityListLoaded ? state.activities : <Activity>[];
        final total = state is ActivityListLoaded ? state.total : 0;
        final isLoading = state is ActivityListLoading;
        final isLoadingMore = state is ActivityListLoaded && state.isLoadingMore;

        return Column(
          children: [
            // Header + filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Ishlash jarayonlari",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Jami: $total ta jarayon",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildOfficerFilter(),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Activities list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state is ActivityListError
                      ? Center(child: Text(state.message))
                      : activities.isEmpty
                          ? const Center(child: Text("Jarayonlar topilmadi"))
                          : ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: activities.length + (isLoadingMore || !(state as ActivityListLoaded).hasMorePages ? 1 : 0),
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                if (index == activities.length) {
                                  if (isLoadingMore) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: Text(
                                        "Barcha jarayonlar ko'rsatildi",
                                        style: TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                    ),
                                  );
                                }
                                return _buildProcessCard(activities[index]);
                              },
                            ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOfficerFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: _selectedOfficerId,
          isExpanded: true,
          hint: const Text(
            "Barcha mas'ullar",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          icon: const Icon(Icons.filter_list, size: 20),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text("Barcha mas'ullar"),
            ),
            ..._officers.map((o) => DropdownMenuItem<int?>(
                  value: o.id,
                  child: Text(o.fullName, overflow: TextOverflow.ellipsis),
                )),
          ],
          onChanged: (value) {
            setState(() => _selectedOfficerId = value);
            context.read<ActivityListCubit>().setOfficerFilter(value);
          },
        ),
      ),
    );
  }

  Widget _buildProcessCard(Activity activity) {
    final isCompleted = activity.status == ActivityStatus.bajarilgan;
    final officerName = activity.officer?.fullName ?? "Noma'lum";
    final youthName = activity.youthName ?? "Noma'lum";

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          NazoratHistoryIntoPage.routeName,
          extra: {'activityId': activity.id, 'youthName': youthName},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.chat_bubble_outline, color: Colors.blue.shade700, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              youthName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              activity.title,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCompleted ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCompleted ? Colors.green.shade200 : Colors.orange.shade200,
                          ),
                        ),
                        child: Text(
                          isCompleted ? "Bajarilgan" : "Rejalashtirilgan",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.green.shade700 : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (activity.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      activity.description,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (activity.result.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Natija:",
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                          Text(
                            activity.result,
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          officerName,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            activity.dateWithTime,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
