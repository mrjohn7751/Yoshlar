import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yoshlar/data/model/officer.dart';
import 'package:yoshlar/data/service/api_client.dart';
import 'package:yoshlar/data/service/officer_service.dart';
import 'package:yoshlar/data/util/clipboard_helper.dart';
import 'package:yoshlar/logic/officer/officer_cubit.dart';
import 'package:yoshlar/logic/officer/officer_state.dart';
import 'package:yoshlar/presentation/nazorat/masullar/widgets/add_masul.dart';
import 'package:yoshlar/presentation/nazorat/masullar/widgets/masul_yoshlar.dart';
import 'package:yoshlar/presentation/widgets/debug_image.dart';

class NazoratMasulScreen extends StatefulWidget {
  const NazoratMasulScreen({super.key});

  @override
  State<NazoratMasulScreen> createState() => _NazoratMasulScreenState();
}

class _NazoratMasulScreenState extends State<NazoratMasulScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OfficerCubit>().loadOfficers();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OfficerCubit, OfficerState>(
      builder: (context, state) {
        final officers = state is OfficerListLoaded ? state.officers : <OfficerModel>[];
        final isLoading = state is OfficerLoading;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Mas'ul xodimlar",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Jami: ${officers.length} nafar",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.pushNamed(AddOfficerScreen.routeName);
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Qo'shish"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: "Xodim nomi bo'yicha qidirish...",
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (state is OfficerError)
                Center(child: Text(state.message))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: officers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildOfficerCard(officers[index]);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOfficerCard(OfficerModel officer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DebugNetworkImage(
                imageUrl: officer.photo,
                rawBackendValue: officer.rawPhoto,
                height: 80,
                width: 80,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      officer.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      officer.position,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    if (officer.username != null)
                      _buildInfoRow(Icons.person_outline, "@${officer.username}"),
                    if (officer.region != null)
                      _buildInfoRow(Icons.location_on_outlined, officer.region!.name),
                    if (officer.phone != null)
                      _buildInfoRow(Icons.phone_outlined, officer.phone!),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCardButton(Icons.edit_outlined, "Tahrirlash", Colors.blue, () {
                context.pushNamed(
                  AddOfficerScreen.editRouteName,
                  extra: {'officer': officer},
                );
              }),
              const SizedBox(width: 8),
              _buildCardButton(Icons.people_outline, "Yoshlari (${officer.youthsCount})", Colors.black, () {
                context.pushNamed(
                  MasulYoshlarScreen.routeName,
                  extra: {'officerId': officer.id, 'officerName': officer.fullName},
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          if (officer.username != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showResetPasswordDialog(officer),
                icon: const Icon(Icons.key_outlined, size: 16),
                label: const Text("Parol yangilash", style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange.shade700,
                  side: BorderSide(color: Colors.orange.shade200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showGenerateCredentialsDialog(officer),
                icon: const Icon(Icons.person_add_outlined, size: 16),
                label: const Text("Akkaunt yaratish", style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade700,
                  side: BorderSide(color: Colors.green.shade200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
        ],
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildCardButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 13)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Future<void> _showGenerateCredentialsDialog(OfficerModel officer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Akkaunt yaratish"),
        content: Text(
          "${officer.fullName} uchun login va parol generatsiya qilinsinmi?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Bekor qilish"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text("Yaratish"),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final officerService = context.read<OfficerService>();
      final credentials = await officerService.generateCredentials(officer.id);
      if (!mounted) return;

      // Reload officers to update the list with new username
      context.read<OfficerCubit>().loadOfficers();

      final username = credentials['username'] as String;
      final password = credentials['password'] as String;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text("Akkaunt yaratildi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Quyidagi ma'lumotlarni mas'ulga yuboring:",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              _credentialBox("Foydalanuvchi nomi", username),
              const SizedBox(height: 8),
              _credentialBox("Parol", password),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                final copied = await copyToClipboard(
                  "Foydalanuvchi nomi: $username\nParol: $password",
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(copied ? "Nusxalandi!" : "Nusxalab bo'lmadi")),
                  );
                }
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text("Nusxalash"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3384C3),
                foregroundColor: Colors.white,
              ),
              child: const Text("Yopish"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Xatolik: ${safeErrorMessage(e)}")),
        );
      }
    }
  }

  Future<void> _showResetPasswordDialog(OfficerModel officer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Parolni yangilash"),
        content: Text(
          "${officer.fullName} uchun yangi parol generatsiya qilinsinmi?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Bekor qilish"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text("Yangilash"),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final officerService = context.read<OfficerService>();
      final credentials = await officerService.resetPassword(officer.id);
      if (!mounted) return;

      final username = credentials['username'] as String;
      final password = credentials['password'] as String;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text("Yangi kirish ma'lumotlari"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Quyidagi ma'lumotlarni mas'ulga yuboring:",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              _credentialBox("Foydalanuvchi nomi", username),
              const SizedBox(height: 8),
              _credentialBox("Yangi parol", password),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                final copied = await copyToClipboard(
                  "Foydalanuvchi nomi: $username\nParol: $password",
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(copied ? "Nusxalandi!" : "Nusxalab bo'lmadi")),
                  );
                }
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text("Nusxalash"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3384C3),
                foregroundColor: Colors.white,
              ),
              child: const Text("Yopish"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Xatolik: ${safeErrorMessage(e)}")),
        );
      }
    }
  }

  Widget _credentialBox(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
