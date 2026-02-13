import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:yoshlar/logic/dashboard/dashboard_cubit.dart';
import 'package:yoshlar/logic/dashboard/dashboard_state.dart';
import 'package:yoshlar/presentation/nazorat/main/diagramma.dart';

class NazoratMainScreen extends StatefulWidget {
  const NazoratMainScreen({super.key});

  @override
  State<NazoratMainScreen> createState() => _NazoratMainScreenState();
}

class _NazoratMainScreenState extends State<NazoratMainScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is DashboardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<DashboardCubit>().loadDashboard(),
                  child: const Text("Qayta yuklash"),
                ),
              ],
            ),
          );
        }
        if (state is DashboardLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildSectionTitle("Asosiy ko'rsatkichlar"),
                    _buildMainStats(state),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Toifalar bo'yicha"),
                    _buildCategoryGrid(state),
                    const SizedBox(height: 20),
                    RegionsBarChart(regions: state.regions),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bosh sahifa",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          "Nazoratdagi yoshlar statistikasi",
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMainStats(DashboardLoaded state) {
    return SizedBox(
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 30,
        mainAxisSpacing: 30,
        childAspectRatio: 2,
        children: [
          _statCard("${state.stats.jamiYoshlar}", "Jami yoshlar", Icons.people, Colors.blue),
          _statCard("${state.stats.ogilBolalar}", "O'g'il bolalar", Icons.male, Colors.blue),
          _statCard("${state.stats.qizBolalar}", "Qiz bolalar", Icons.female, Colors.purple),
        ],
      ),
    );
  }

  Widget _statCard(String value, String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(DashboardLoaded state) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 5,
      ),
      itemBuilder: (context, index) {
        final cat = state.categories[index];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${cat.youthsCount}",
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${index + 1}. ${cat.name}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
