import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoshlar/logic/youth/youth_list_cubit.dart';
import 'package:yoshlar/logic/youth/youth_list_state.dart';
import 'package:yoshlar/presentation/nazorat/yoshlar/nazorat_yoshlar_item/user_card.dart';

class MainYoshlarFilterScreen extends StatefulWidget {
  static const routeName = "main_yoshlar";
  final String gender;
  const MainYoshlarFilterScreen({super.key, required this.gender});

  @override
  State<MainYoshlarFilterScreen> createState() =>
      _MainYoshlarFilterScreenState();
}

class _MainYoshlarFilterScreenState extends State<MainYoshlarFilterScreen> {
  List<String> genderItems = ["Barcha jinslar", "Erkak", "Ayol"];
  String selectedGender = "Erkak";

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<YouthListCubit>().setGenderFilter(widget.gender);
    context.read<YouthListCubit>().loadYouths();
    _scrollController.addListener(_onScroll);
    context.read<YouthListCubit>().setGenderFilter(widget.gender);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<YouthListCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<YouthListCubit, YouthListState>(
        builder: (context, state) {
          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Jami yoshlar",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Jami: ${state is YouthListLoaded ? state.total : '...'} nafar",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 8),
              if (state is YouthListLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state is YouthListError)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(child: Text(state.message)),
                )
              else if (state is YouthListLoaded) ...[
                ...state.youths.map(
                  (user) => NazoratUserCardWidget(user: user),
                ),
                if (state.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (!state.hasMorePages && state.youths.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        "Barcha yoshlar ko'rsatildi",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
