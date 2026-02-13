import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  @override
  void initState() {
    super.initState();
    if (widget.officerId != null) {
      context.read<OfficerCubit>().loadOfficerYouths(widget.officerId!);
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
          widget.officerName ?? "Nazoratdagi yoshlar",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.black),
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
              return const Center(child: Text("Yoshlar topilmadi"));
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.youths.length,
              itemBuilder: (context, index) {
                return UserCardWidget(user: state.youths[index]);
              },
            );
          }
          return const SizedBox();
        },
      ),
    ),
    );
  }
}
