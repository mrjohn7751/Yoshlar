import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yoshlar/data/model/user.dart';
import 'package:yoshlar/data/service/api_client.dart';
import 'package:yoshlar/data/util/call_launcher.dart';
import 'package:yoshlar/logic/youth/youth_list_cubit.dart';
import 'package:yoshlar/presentation/nazorat/yoshlar/nazorat_yoshlar_item/add_yoshlar.dart';
import 'package:yoshlar/presentation/nazorat/yoshlar/nazorat_yoshlar_item/nazorat_yoshlar_history.dart';
import 'package:yoshlar/presentation/widgets/debug_image.dart';

class NazoratUserCardWidget extends StatelessWidget {
  final UserModel user;

  const NazoratUserCardWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          NazoratYoshlarHistory.routeName,
          extra: {'youthId': user.id, 'youthName': user.name},
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DebugNetworkImage(
                      imageUrl: user.image,
                      height: 80,
                      width: 80,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              makePhoneCall(user.phone ?? "+998905382288");
                            },
                            child: Row(
                              children: [
                                Icon(Icons.call, size: 16, color: Colors.blue),
                                Text(
                                  " ${user.phone}",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                size: 16,
                                color: Colors.blue,
                              ),
                              Text(
                                " ${user.birthDate}",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            context.pushNamed(
                              AddYouthScreen.editRouteName,
                              extra: {'youth': user},
                            );
                          },
                          icon: const Icon(Icons.edit, size: 16),

                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: BorderSide(color: Colors.blue.shade200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _showDeleteDialog(context, user),
                          icon: const Icon(Icons.delete_outline, size: 16),

                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _infoRow(Icons.location_on_outlined, user.location),
              _infoRow(Icons.school_outlined, user.status),
              _infoRow(Icons.work_outline, user.activity),
              const SizedBox(height: 4),
              if (user.tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: user.tags
                      .map(
                        (tag) => _buildCardButton(
                          Icons.admin_panel_settings_outlined,
                          tag,
                          Colors.black,
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 8),
              const SizedBox(height: 4),
              if (user.officers.isNotEmpty) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 24,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.officers[0].fullName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              user.officers[0].position,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (user.officers[0].phone != null) ...[
                        const Icon(Icons.call, size: 18, color: Colors.blue),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            makePhoneCall(
                              user.officers[0].phone ?? "+998905382288",
                            );
                          },
                          child: Text(
                            user.officers[0].phone!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Yoshlarni o'chirish"),
        content: Text(
          "${user.name} o'chirilsinmi? Bu amalni ortga qaytarib bo'lmaydi.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Bekor qilish"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("O'chirish"),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<YouthListCubit>().deleteYouth(user.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Yoshlar muvaffaqiyatli o'chirildi")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Xatolik: ${safeErrorMessage(e)}")),
        );
      }
    }
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildCardButton(IconData icon, String label, Color color) {
    return OutlinedButton.icon(
      onPressed: null,
      icon: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(icon, size: 16),
      ),
      label: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey,
        side: BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}
