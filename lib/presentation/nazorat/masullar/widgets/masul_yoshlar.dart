// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yoshlar/data/model/user.dart';
import 'package:yoshlar/data/service/api_client.dart';
import 'package:yoshlar/logic/officer/officer_cubit.dart';
import 'package:yoshlar/logic/officer/officer_state.dart';
import 'package:yoshlar/presentation/nazorat/masullar/widgets/attacht_yoshlar.dart';
import 'package:yoshlar/presentation/yoshlar/main/widgets/main_widget.dart';

class MasulYoshlarScreen extends StatefulWidget {
  static const routeName = 'masul_yoshlar';
  final int? officerId;
  final String? officerName;

  const MasulYoshlarScreen({super.key, this.officerId, this.officerName});

  @override
  State<MasulYoshlarScreen> createState() => _MasulYoshlarScreenState();
}

class _MasulYoshlarScreenState extends State<MasulYoshlarScreen> {
  bool _isSelectMode = false;
  final Set<int> _selectedYouthIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.officerId != null) {
      context.read<OfficerCubit>().loadOfficerYouths(widget.officerId!);
    }
  }

  void _toggleSelectMode() {
    setState(() {
      _isSelectMode = !_isSelectMode;
      _selectedYouthIds.clear();
    });
  }

  void _toggleYouth(int youthId) {
    setState(() {
      if (_selectedYouthIds.contains(youthId)) {
        _selectedYouthIds.remove(youthId);
      } else {
        _selectedYouthIds.add(youthId);
      }
    });
  }

  Future<void> _detachSelected() async {
    if (_selectedYouthIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ёшларни ажратиш"),
        content: Text(
          "${_selectedYouthIds.length} та ёшлар мас'улдан ажратилсинми?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Бекор қилиш"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Ажратиш"),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await context.read<OfficerCubit>().detachYouths(
        widget.officerId!,
        _selectedYouthIds.toList(),
      );
      if (mounted) {
        setState(() {
          _isSelectMode = false;
          _selectedYouthIds.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ёшлар муваффақиятли ажратилди")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Хатолик: ${safeErrorMessage(e)}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<OfficerCubit>().loadOfficers();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.officerName ?? "Ёшлар назорати",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              icon: Image.asset(
                _isSelectMode
                    ? "assets/images/delete_user.png"
                    : "assets/images/delete_user.png",
                width: 32,
                height: 32,
              ),
              tooltip: _isSelectMode ? "Бекор қилиш" : "Ажратиш",
              onPressed: _toggleSelectMode,
            ),
            IconButton(
              icon: Image.asset(
                "assets/images/add_user.png",
                width: 32,
                height: 32,
              ),
              onPressed: () {
                context.pushNamed(
                  AttachYouthScreen.routeName,
                  extra: {
                    'officerId': widget.officerId,
                    'officerName': widget.officerName,
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: _isSelectMode && _selectedYouthIds.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: _detachSelected,
                backgroundColor: Colors.red,
                icon: const Icon(Icons.link_off, color: Colors.white),
                label: Text(
                  "Ажратиш (${_selectedYouthIds.length})",
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : null,
        body: BlocBuilder<OfficerCubit, OfficerState>(
          builder: (context, state) {
            if (state is OfficerLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OfficerError) {
              return Center(child: Text(state.message));
            }
            if (state is OfficerYouthsLoaded) {
              if (state.youths.isEmpty) {
                return const Center(child: Text("Ёшлар топилмади"));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.youths.length,
                itemBuilder: (context, index) {
                  final youth = state.youths[index];
                  if (_isSelectMode) {
                    return _buildSelectableYouthCard(youth);
                  }
                  return UserCardWidget(user: youth);
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildSelectableYouthCard(UserModel youth) {
    final isSelected = _selectedYouthIds.contains(youth.id);
    return GestureDetector(
      onTap: () => _toggleYouth(youth.id!),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.red.shade300 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              activeColor: Colors.red,
              onChanged: (_) => _toggleYouth(youth.id!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    youth.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "${youth.gender} • ${youth.birthDate}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
