import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yoshlar/data/model/officer.dart';
import 'package:yoshlar/data/service/officer_service.dart';
import 'package:yoshlar/logic/youth/youth_list_cubit.dart';
import 'package:yoshlar/logic/youth/youth_list_state.dart';
import 'package:yoshlar/presentation/nazorat/yoshlar/nazorat_yoshlar_item/add_yoshlar.dart';
import 'package:yoshlar/presentation/nazorat/yoshlar/nazorat_yoshlar_item/import_yoshlar.dart';
import 'package:yoshlar/presentation/nazorat/yoshlar/nazorat_yoshlar_item/user_card.dart';

class NazoratYoshlarScreen extends StatefulWidget {
  const NazoratYoshlarScreen({super.key});

  @override
  State<NazoratYoshlarScreen> createState() => _NazoratYoshlarScreenState();
}

class _NazoratYoshlarScreenState extends State<NazoratYoshlarScreen> {
  List<String> genderItems = ["Barcha jinslar", "Erkak", "Ayol"];
  String selectedGender = "Barcha jinslar";

  List<OfficerModel> _officers = [];
  int? _selectedOfficerId;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<YouthListCubit>().loadYouths();
    _loadOfficers();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadOfficers() async {
    try {
      final officers = await context.read<OfficerService>().getOfficers();
      if (mounted) setState(() => _officers = officers);
    } catch (_) {}
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
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Jami: ${state is YouthListLoaded ? state.total : '...'} nafar",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.pushNamed(ImportYouthScreen.routeName);
                          },
                          icon: const Icon(Icons.upload_file, size: 18),
                          label: const Text("Excel Import"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.pushNamed(AddYouthScreen.routeName);
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Qo'shish"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildOfficerDropdown(),
                  _buildDropdown(genderItems, selectedGender, (val) {
                    setState(() => selectedGender = val!);
                    context.read<YouthListCubit>().setGenderFilter(
                      val == "Barcha jinslar" ? null : val,
                    );
                  }),
                ],
              ),
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

  Widget _buildOfficerDropdown() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 4, left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int?>(
            value: _selectedOfficerId,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600, size: 20),
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
            hint: const Text("Barcha mas'ullar", style: TextStyle(fontSize: 13)),
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
            onChanged: (val) {
              setState(() => _selectedOfficerId = val);
              context.read<YouthListCubit>().setOfficerFilter(val);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String selected, ValueChanged<String?> onChanged) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 4, left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selected,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade600,
              size: 20,
            ),
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
          ),
        ),
      ),
    );
  }
}
