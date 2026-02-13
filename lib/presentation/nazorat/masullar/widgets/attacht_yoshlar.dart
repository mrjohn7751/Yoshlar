import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoshlar/data/model/user.dart';
import 'package:yoshlar/logic/officer/officer_cubit.dart';

class AttachYouthScreen extends StatefulWidget {
  static const String routeName = 'attacht_yoshlar';
  final int? officerId;
  final String? officerName;

  const AttachYouthScreen({super.key, this.officerId, this.officerName});

  @override
  State<AttachYouthScreen> createState() => _AttachYouthScreenState();
}

class _AttachYouthScreenState extends State<AttachYouthScreen> {
  final Set<int> _selectedIds = {};
  List<UserModel> _unattachedYouths = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnattachedYouths();
  }

  Future<void> _loadUnattachedYouths() async {
    if (widget.officerId == null) return;
    try {
      final youths = await context.read<OfficerCubit>().getUnattachedYouths(widget.officerId!);
      if (mounted) {
        setState(() {
          _unattachedYouths = youths.cast<UserModel>();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.officerName ?? "",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Yoshlarni biriktirish",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildActionHeader(),
                Expanded(child: _buildYouthList()),
              ],
            ),
    );
  }

  Widget _buildActionHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color(0xFFF4F7F9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text("Bekor qilish"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.white),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _selectedIds.isEmpty
                      ? null
                      : () async {
                          if (widget.officerId == null) return;
                          await context.read<OfficerCubit>().attachYouths(
                            widget.officerId!,
                            _selectedIds.toList(),
                          );
                          if (mounted) Navigator.pop(context);
                        },
                  icon: const Icon(Icons.check, size: 18),
                  label: Text("Biriktirish (${_selectedIds.length})"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3384C3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Biriktirilmagan yoshlar (${_unattachedYouths.length})",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildYouthList() {
    if (_unattachedYouths.isEmpty) {
      return const Center(child: Text("Biriktirilmagan yoshlar yo'q"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _unattachedYouths.length,
      itemBuilder: (context, index) {
        final youth = _unattachedYouths[index];
        final isSelected = _selectedIds.contains(youth.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 4,
            ),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: isSelected,
                  activeColor: const Color(0xFF3384C3),
                  onChanged: (val) {
                    setState(() {
                      if (val == true && youth.id != null) {
                        _selectedIds.add(youth.id!);
                      } else if (youth.id != null) {
                        _selectedIds.remove(youth.id!);
                      }
                    });
                  },
                ),
                CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  radius: 18,
                  child: const Icon(
                    Icons.person,
                    size: 20,
                    color: Color(0xFF3384C3),
                  ),
                ),
              ],
            ),
            title: Text(
              youth.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              youth.region?.name ?? youth.location,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            onTap: () {
              setState(() {
                if (youth.id != null) {
                  if (isSelected) {
                    _selectedIds.remove(youth.id!);
                  } else {
                    _selectedIds.add(youth.id!);
                  }
                }
              });
            },
          ),
        );
      },
    );
  }
}
