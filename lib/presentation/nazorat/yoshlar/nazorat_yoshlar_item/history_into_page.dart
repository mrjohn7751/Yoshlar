import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yoshlar/data/util/clipboard_helper.dart';
import 'package:yoshlar/logic/auth/auth_cubit.dart';
import 'package:yoshlar/logic/auth/auth_state.dart';
import 'package:yoshlar/logic/youth/youth_detail_cubit.dart';
import 'package:yoshlar/logic/youth/youth_detail_state.dart';
import 'package:yoshlar/presentation/nazorat/yoshlar/nazorat_yoshlar_item/image_show.dart';

class NazoratHistoryIntoPage extends StatefulWidget {
  static const String routeName = 'history_into_page';
  final int? activityId;
  final String? youthName;

  const NazoratHistoryIntoPage({super.key, this.activityId, this.youthName});

  @override
  State<NazoratHistoryIntoPage> createState() => _NazoratHistoryIntoPageState();
}

class _NazoratHistoryIntoPageState extends State<NazoratHistoryIntoPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.activityId != null) {
      context.read<ActivityDetailCubit>().loadActivityDetail(
        widget.activityId!,
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.youthName ?? "Faoliyat",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Builder(
            builder: (context) {
              final authState = context.watch<AuthCubit>().state;
              if (authState is AuthAuthenticated &&
                  authState.user.isRahbariyat) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: "Faoliyatni o'chirish",
                  onPressed: () => _showDeleteDialog(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<ActivityDetailCubit, ActivityDetailState>(
        builder: (context, state) {
          if (state is ActivityDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ActivityDetailError) {
            return Center(child: Text(state.message));
          }
          if (state is ActivityDetailLoaded) {
            final activity = state.activity;
            final comments = state.comments;
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildInfoCard("Сарлавҳа", activity.title),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          "Тавсиф",
                          activity.description.isNotEmpty
                              ? activity.description
                              : "-",
                        ),
                        // if (activity.result.isNotEmpty) ...[
                        //   const SizedBox(height: 16),
                        //   _buildInfoCard("Natija", activity.result),
                        // ],
                        const SizedBox(height: 16),
                        if (activity.latitude != null &&
                            activity.longitude != null)
                          _buildLocationCard(
                            activity.latitude!,
                            activity.longitude!,
                          ),
                        if (activity.latitude != null)
                          const SizedBox(height: 16),
                        if (activity.officer != null)
                          _buildOfficerCard(activity.officer!),
                        if (activity.officer != null)
                          const SizedBox(height: 16),
                        if (activity.images.isNotEmpty)
                          _buildImageGallery(activity.images),
                        if (activity.images.isNotEmpty)
                          const SizedBox(height: 16),
                        _buildCommentsSection(comments),
                      ],
                    ),
                  ),
                ),
                _buildCommentInput(),
                const SizedBox(height: 24),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildLocationCard(double lat, double lng) {
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final coordsText = '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Локация",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 20, color: Colors.red.shade400),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  coordsText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
                tooltip: "Нусхалаш",
                onPressed: () async {
                  final copied = await copyToClipboard('$lat,$lng');
                  if (context.mounted) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          copied
                              ? "Координаталар нусхаланди"
                              : "Нусхалаб бўлмади",
                        ),
                      ),
                    );
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => launchUrl(
                Uri.parse(googleMapsUrl),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.map, size: 16),
              label: const Text(
                "Гоогле Мапс да очиш",
                style: TextStyle(fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: BorderSide(color: Colors.blue.shade200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficerCard(dynamic officer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Масъул ходим",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: const Icon(Icons.person, size: 16, color: Colors.blue),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    officer.fullName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    officer.position,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<dynamic> images) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.image_outlined, size: 18, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                "Расмлар",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              // Ekran kengligiga qarab ustunlar sonini aniqlaymiz
              int crossAxisCount = 2; // Mobil uchun default
              if (constraints.maxWidth > 1200) {
                crossAxisCount = 6; // Katta monitorlar uchun
              } else if (constraints.maxWidth > 800) {
                crossAxisCount = 4;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: images.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent:
                      150, // Vebda kichikroq kataklar (taxminan 150px)
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1, // Kvadrat shakli
                ),
                itemBuilder: (context, index) {
                  final img = images[index];
                  return GestureDetector(
                    // SHU YERDA FUNKSIYANI CHAQIRAMIZ
                    onTap: () => openImageGallery(context, images, index),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                        image: img.url.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(img.url),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: img.url.isEmpty
                          ? const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(List<dynamic> comments) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.message, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                "Изоҳлар (${comments.length})",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (comments.isEmpty)
            const Text("Изоҳлар йўқ", style: TextStyle(color: Colors.grey))
          else
            ...comments.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildCommentItem(
                  c.user?.name ?? "Номаълум",
                  c.createdAt,
                  c.body,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(String name, String time, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Изоҳ ёзинг...",
                hintStyle: const TextStyle(fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {
                final text = _commentController.text.trim();
                if (text.isNotEmpty) {
                  context.read<ActivityDetailCubit>().addComment(text);
                  _commentController.clear();
                  FocusScope.of(context).unfocus();
                }
              },
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Faoliyatni o'chirish"),
        content: const Text(
          "Haqiqatan ham bu faoliyatni o'chirmoqchimisiz? Bu amalni qaytarib bo'lmaydi.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Bekor qilish"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (widget.activityId != null) {
                try {
                  await context.read<ActivityDetailCubit>().deleteActivity(
                    widget.activityId!,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Faoliyat muvaffaqiyatli o'chirildi"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Xatolik: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text("O'chirish", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    );
  }
}
