import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoshlar/logic/youth/youth_detail_cubit.dart';
import 'package:yoshlar/logic/youth/youth_detail_state.dart';
import 'package:yoshlar/presentation/yoshlar/main/main_item_screen.dart/history_item_widget.dart';

class NazoratYoshlarHistory extends StatefulWidget {
  static const routeName = 'nazorat_history';
  final int? youthId;
  final String? youthName;

  const NazoratYoshlarHistory({super.key, this.youthId, this.youthName});

  @override
  State<NazoratYoshlarHistory> createState() => _NazoratYoshlarHistoryState();
}

class _NazoratYoshlarHistoryState extends State<NazoratYoshlarHistory> {
  @override
  void initState() {
    super.initState();
    if (widget.youthId != null) {
      context.read<YouthDetailCubit>().loadYouthDetail(widget.youthId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.youthName ?? "Yosh",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocBuilder<YouthDetailCubit, YouthDetailState>(
          builder: (context, state) {
            if (state is YouthDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is YouthDetailError) {
              return Center(child: Text(state.message));
            }
            if (state is YouthDetailLoaded) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Faoliyatlar tarixi",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: state.activities.isEmpty
                          ? const Center(child: Text("Faoliyatlar topilmadi"))
                          : ListView.builder(
                              itemCount: state.activities.length,
                              itemBuilder: (context, index) {
                                return ActivityCard(
                                  activity: state.activities[index],
                                  youthName: widget.youthName,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
