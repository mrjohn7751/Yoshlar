import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:yoshlar/data/model/category.dart';
import 'package:yoshlar/logic/dashboard/dashboard_cubit.dart';
import 'package:yoshlar/logic/dashboard/dashboard_state.dart';
import 'package:yoshlar/presentation/nazorat/main/diagramma.dart';
import 'package:yoshlar/presentation/nazorat/main/widgets/diagramma_talim.dart';
import 'package:yoshlar/presentation/nazorat/main/widgets/yoshlar_item_filter.dart';

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
                  onPressed: () =>
                      context.read<DashboardCubit>().loadDashboard(),
                  child: const Text("Қайта юклаш"),
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
                    _buildSectionTitle("Асосий кўрсаткичлар"),
                    _buildMainStats(state),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Тоифалар бўйича"),
                    _buildCategoryGrid(state),
                    if (state.hasMoreCategories)
                      _buildLoadMoreButton(
                        isLoading: state.isLoadingMoreCategories,
                        onPressed: () =>
                            context.read<DashboardCubit>().loadMoreCategories(),
                      ),
                    const SizedBox(height: 20),
                    RegionsBarChart(regions: state.regions),
                    const SizedBox(height: 20),

                    MultiResponsivePiePage(),
                    const SizedBox(height: 40),
                    // if (state.hasMoreRegions)
                    //   _buildLoadMoreButton(
                    //     isLoading: state.isLoadingMoreRegions,
                    //     onPressed: () =>
                    //         context.read<DashboardCubit>().loadMoreRegions(),
                    //   ),
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
          "Бош саҳифа",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          "Ёшлар назорати статистикаси",
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
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        bool isMobile = width < 600;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: isMobile ? 8 : 24,
            mainAxisSpacing: isMobile ? 8 : 24,

            // 👇 Height aniq boshqariladi
            mainAxisExtent: isMobile ? 140 : 180,
          ),
          itemBuilder: (context, index) {
            final items = [
              {
                "value": "${state.stats.jamiYoshlar}",
                "title": "Жами ёшлар",
                "icon": Icons.people,
                "color": Colors.blue,
                "index": 0,
              },
              {
                "value": "${state.stats.ogilBolalar}",
                "title": "Еркаклар",
                "icon": Icons.male,
                "color": Colors.blue,
                "index": 1,
              },
              {
                "value": "${state.stats.qizBolalar}",
                "title": "Aёллар",
                "icon": Icons.female,
                "color": Colors.purple,
                "index": 2,
              },
            ];

            final item = items[index];

            return _statCard(
              item["value"] as String,
              item["title"] as String,
              item["icon"] as IconData,
              item["color"] as Color,
              width,
              item["index"] as int,
            );
          },
        );
      },
    );
  }

  Widget _statCard(
    String value,
    String title,
    IconData icon,
    Color color,
    double width,
    int index,
  ) {
    bool isMobile = width < 600;

    return GestureDetector(
      onTap: () {
        String gender = index == 0
            ? ""
            : index == 1
            ? "Erkak"
            : "Ayol";
        context.pushNamed(
          MainYoshlarFilterScreen.routeName,
          extra: {"gender": gender},
        );
      },

      child: Container(
        padding: EdgeInsets.all(isMobile ? 8 : 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: isMobile ? 18 : 24),
            SizedBox(height: isMobile ? 2 : 6),
            Text(
              value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isMobile ? 14 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,

              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(DashboardLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        bool isMobile = width < 600;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: isMobile ? 8 : 16,
            mainAxisSpacing: isMobile ? 8 : 16,

            // 👇 height aniq beriladi
            mainAxisExtent: isMobile ? 80 : 65,
          ),
          itemBuilder: (context, index) {
            final cat = state.categories[index];
            return _categoryCard(cat, isMobile);
          },
        );
      },
    );
  }

  Widget _buildLoadMoreButton({
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.expand_more, size: 20),
                label: const Text("Кўпроқ юклаш"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                ),
              ),
      ),
    );
  }

  Widget _categoryCard(CategoryModel cat, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: isMobile ? 36 : 40,
            width: isMobile ? 36 : 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FittedBox(
              child: Text(
                "${cat.youthsCount}",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),

          Expanded(
            child: Text(
              cat.name,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
