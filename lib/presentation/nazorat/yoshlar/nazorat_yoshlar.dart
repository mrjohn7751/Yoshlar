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

class _NazoratYoshlarScreenState extends State<NazoratYoshlarScreen>
    with AutomaticKeepAliveClientMixin {
  List<String> genderItems = ["Barcha jinslar", "Erkak", "Ayol"];
  String selectedGender = "Barcha jinslar";

  List<String> regionItems = [
    "Jizzax shahar",
    "Arnasoy tumani",
    "Baxmal tumani",
    "G'allaorol tumani",
    "Do'stlik tumani",
    "Sharof Rashidov tumani",
    "Zomin tumani",
    "Zarbdor tumani",
    "Zafarobod tumani",
    "Mirzacho'l tumani",
    "Paxtakor tumani",
    "Forish tumani",
    "Yangiobod tumani",
  ];
  String selectedRegion = "Barcha hududlar";

  List<OfficerModel> _officers = [];
  int? _selectedOfficerId;

  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

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
        _scrollController.position.maxScrollExtent - 300) {
      context.read<YouthListCubit>().loadMore();
    }
  }

  void _checkIfNeedMore() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (_scrollController.position.maxScrollExtent <= 0) {
        context.read<YouthListCubit>().loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: BlocConsumer<YouthListCubit, YouthListState>(
        listener: (context, state) {
          if (state is YouthListLoaded && state.hasMorePages && !state.isLoadingMore) {
            _checkIfNeedMore();
          }
        },
        builder: (context, state) {
          final youths = state is YouthListLoaded ? state.youths : [];
          final isLoading = state is YouthListLoading;
          final isError = state is YouthListError;

          // Header (3 ta) + yoshlar + footer (1 ta)
          final itemCount = 3 + youths.length + 1;

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: isLoading ? 4 : (isError ? 4 : itemCount),
            itemBuilder: (context, index) {
              // 0 - Title va tugmalar
              if (index == 0) {
                return _buildHeader(state);
              }
              // 1 - Filtrlar
              if (index == 1) {
                return _buildFilters();
              }
              // 2 - Bo'sh joy
              if (index == 2) {
                return const SizedBox(height: 8);
              }

              // Loading holati
              if (isLoading && index == 3) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // Error holati
              if (isError && index == 3) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(child: Text((state as YouthListError).message)),
                );
              }

              // Yoshlar ro'yxati
              final youthIndex = index - 3;
              if (youthIndex < youths.length) {
                return NazoratUserCardWidget(user: youths[youthIndex]);
              }

              // Footer - loading more yoki tugadi
              if (state is YouthListLoaded) {
                if (state.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (!state.hasMorePages && state.youths.isNotEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        "Barcha yoshlar ko'rsatildi",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(YouthListState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
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
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        _buildOfficerDropdown(),
        _buildDropdown(genderItems, selectedGender, (val) {
          setState(() => selectedGender = val!);
          context.read<YouthListCubit>().setGenderFilter(
            val == "Barcha jinslar" ? null : val,
          );
        }),
        _buildRegionDropdown(),
      ],
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
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade600,
              size: 20,
            ),
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
            hint: const Text(
              "Barcha mas'ullar",
              style: TextStyle(fontSize: 13),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text("Barcha mas'ullar"),
              ),
              ..._officers.map(
                (o) => DropdownMenuItem<int?>(
                  value: o.id,
                  child: Text(o.fullName, overflow: TextOverflow.ellipsis),
                ),
              ),
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

  Widget _buildRegionDropdown() {
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
            value: selectedRegion == "Barcha hududlar"
                ? null
                : regionItems.indexOf(selectedRegion),
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade600,
              size: 20,
            ),
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
            hint: const Text("Barcha hududlar", style: TextStyle(fontSize: 13)),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text("Barcha hududlar"),
              ),
              ...regionItems.map(
                (o) => DropdownMenuItem<int?>(
                  value: regionItems.indexOf(o),
                  child: Text(o, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
            onChanged: (val) {
              setState(
                () => selectedRegion = val == null
                    ? "Barcha hududlar"
                    : regionItems[val],
              );
              context.read<YouthListCubit>().setRegionFilter(
                val == null ? null : regionItems[val],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String selected,
    ValueChanged<String?> onChanged,
  ) {
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
