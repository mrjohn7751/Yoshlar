import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yoshlar/data/model/user.dart';
import 'package:yoshlar/presentation/nazorat/yoshlar/nazorat_yoshlar_item/add_yoshlar.dart';
import 'package:yoshlar/presentation/nazorat/yoshlar/nazorat_yoshlar_item/nazorat_yoshlar_history.dart';

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
                height: 80,
                width: double.infinity,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: user.image != null && user.image!.startsWith('http')
                          ? Image.network(
                              user.image!,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, e, st) => _defaultAvatar(),
                            )
                          : _defaultAvatar(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            " \u2022 Tug'ulgan sana: ${user.birthDate}\n \u2022 Jinsi: ${user.gender}",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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
                      .map((tag) => _buildCardButton(
                            Icons.admin_panel_settings_outlined,
                            tag,
                            Colors.black,
                          ))
                      .toList(),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.pushNamed(
                          AddYouthScreen.editRouteName,
                          extra: {'youth': user},
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text("Tahrirlash", style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: BorderSide(color: Colors.blue.shade200),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (user.officers.isNotEmpty) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, size: 24, color: Colors.blue),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.officers[0].fullName,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            Text(
                              user.officers[0].position,
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      if (user.officers[0].phone != null) ...[
                        const Icon(Icons.call, size: 18, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          user.officers[0].phone!,
                          style: const TextStyle(fontSize: 14, color: Colors.blue),
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

  Widget _defaultAvatar() {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.person, size: 40, color: Colors.blue),
    );
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
      onPressed: () {},
      icon: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(icon, size: 16),
      ),
      label: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Text(label, style: const TextStyle(fontSize: 13)),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}
