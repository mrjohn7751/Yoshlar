import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoshlar/data/service/auth_service.dart';

class PasswordResetHistoryScreen extends StatefulWidget {
  const PasswordResetHistoryScreen({super.key});

  @override
  State<PasswordResetHistoryScreen> createState() =>
      _PasswordResetHistoryScreenState();
}

class _PasswordResetHistoryScreenState
    extends State<PasswordResetHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLogs();
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
      _loadMore();
    }
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response =
          await context.read<AuthService>().getResetLogs(page: 1);
      final data = (response['data'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      final lastPage = response['last_page'] as int? ?? 1;

      if (mounted) {
        setState(() {
          _logs.clear();
          _logs.addAll(data);
          _currentPage = 1;
          _hasMore = _currentPage < lastPage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final response =
          await context.read<AuthService>().getResetLogs(page: nextPage);
      final data = (response['data'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      final lastPage = response['last_page'] as int? ?? 1;

      if (mounted) {
        setState(() {
          _logs.addAll(data);
          _currentPage = nextPage;
          _hasMore = _currentPage < lastPage;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Parol tiklash tarixi",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Yuz orqali tiklangan parollar",
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!,
                              style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadLogs,
                            child: const Text("Qayta yuklash"),
                          ),
                        ],
                      ),
                    )
                  : _logs.isEmpty
                      ? const Center(
                          child: Text("Parol tiklash tarixi mavjud emas"))
                      : RefreshIndicator(
                          onRefresh: _loadLogs,
                          child: ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _logs.length +
                                (_isLoadingMore || !_hasMore ? 1 : 0),
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              if (index == _logs.length) {
                                if (_isLoadingMore) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(
                                      "Barcha yozuvlar ko'rsatildi",
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 13),
                                    ),
                                  ),
                                );
                              }
                              return _buildLogCard(_logs[index]);
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    final officer = log['officer'] as Map<String, dynamic>?;
    final officerName = officer?['full_name'] ?? "Noma'lum";
    final username = log['username'] ?? '';
    final ipAddress = log['ip_address'] ?? '';
    final createdAt = log['created_at'] ?? '';

    String formattedDate = '';
    if (createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt);
        formattedDate =
            '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        formattedDate = createdAt;
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
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
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.lock_reset, color: Colors.orange.shade700, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  officerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.language,
                            size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          ipAddress,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
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
    );
  }
}
