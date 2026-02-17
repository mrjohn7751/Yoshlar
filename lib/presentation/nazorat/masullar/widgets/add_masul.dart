import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoshlar/data/util/clipboard_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yoshlar/data/model/officer.dart';
import 'package:yoshlar/data/service/api_client.dart';
import 'package:yoshlar/logic/officer/officer_cubit.dart';

class AddOfficerScreen extends StatefulWidget {
  static const String routeName = 'add_masul';
  static const String editRouteName = 'edit_masul';

  final OfficerModel? existingOfficer;

  const AddOfficerScreen({super.key, this.existingOfficer});

  bool get isEditing => existingOfficer != null;

  @override
  State<AddOfficerScreen> createState() => _AddOfficerScreenState();
}

class _AddOfficerScreenState extends State<AddOfficerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedPosition;
  String? _selectedRegion;
  bool _isSubmitting = false;

  Uint8List? _photoBytes;
  String? _existingPhotoUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final officer = widget.existingOfficer!;
      _nameController.text = officer.fullName;
      _phoneController.text = officer.phone ?? '';
      _selectedPosition = officer.position;
      _selectedRegion = officer.region?.name;
      _existingPhotoUrl = officer.photo;
    }
  }

  Future<void> _pickPhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _photoBytes = bytes;
        _existingPhotoUrl = null;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEditing ? "Mas'ulni tahrirlash" : "Yangi mas'ul qo'shish",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.isEditing
                  ? widget.existingOfficer!.fullName
                  : "Mas'ul xodim ma'lumotlarini kiriting",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildImageUpload(),
              const SizedBox(height: 20),
              _buildCardWrapper(
                title: "Shaxsiy ma'lumotlar",
                child: Column(
                  children: [
                    _buildInputField(
                      label: "F.I.Sh *",
                      hint: "To'liq ism-sharif",
                      controller: _nameController,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: "Lavozim *",
                      hint: "Lavozimni tanlang",
                      items: ["Bosh mutaxassis", "Katta inspektor", "Mutaxassis", "Inspektor"],
                      value: _selectedPosition,
                      onChanged: (val) => setState(() => _selectedPosition = val),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: "Hudud *",
                      hint: "Hududni tanlang",
                      items: [
                        "Jizzax shahar", "Arnasoy tumani", "Baxmal tumani",
                        "G'allaorol tumani", "Do'stlik tumani", "Sharof Rashidov tumani",
                        "Zomin tumani", "Zarbdor tumani", "Zafarobod tumani",
                        "Mirzacho'l tumani", "Paxtakor tumani", "Forish tumani",
                        "Yangiobod tumani",
                      ],
                      value: _selectedRegion,
                      onChanged: (val) => setState(() => _selectedRegion = val),
                    ),
                  ],
                ),
              ),
              if (widget.isEditing && widget.existingOfficer?.username != null) ...[
                const SizedBox(height: 16),
                _buildCardWrapper(
                  title: "Kirish ma'lumotlari",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F7FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person_outline, size: 20, color: Colors.blue.shade400),
                            const SizedBox(width: 8),
                            Text(
                              "@${widget.existingOfficer!.username}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _buildCardWrapper(
                title: "Aloqa ma'lumotlari",
                child: Column(
                  children: [
                    _buildInputField(
                      label: "Telefon raqam *",
                      hint: "+998901234567",
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 13,
                      validator: (val) {
                        if (val != null && val.isNotEmpty) {
                          final phoneRegex = RegExp(r'^\+?998\d{9}$');
                          if (!phoneRegex.hasMatch(val.trim())) {
                            return "Noto'g'ri format. Masalan: +998901234567";
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUpload() {
    ImageProvider? imageProvider;
    if (_photoBytes != null) {
      imageProvider = MemoryImage(_photoBytes!);
    } else if (_existingPhotoUrl != null && _existingPhotoUrl!.startsWith('http')) {
      imageProvider = NetworkImage(_existingPhotoUrl!);
    }

    final hasImage = imageProvider != null;

    return Column(
      children: [
        GestureDetector(
          onTap: _pickPhoto,
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue.shade50,
            backgroundImage: imageProvider,
            child: !hasImage
                ? Icon(
                    Icons.person_outline,
                    size: 40,
                    color: Colors.blue.shade300,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _pickPhoto,
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey.shade200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            hasImage ? "Rasmni almashtirish" : "Rasm yuklash",
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildCardWrapper({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EEF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    TextInputType? keyboardType,
    TextEditingController? controller,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required List<String> items,
    String? value,
    ValueChanged<String?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                hint,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade200),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Bekor qilish",
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _saveData,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(widget.isEditing ? "Yangilash" : "Saqlash"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3384C3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    if (_nameController.text.isEmpty || _selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Majburiy maydonlarni to'ldiring")),
      );
      return;
    }

    final cubit = context.read<OfficerCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isSubmitting = true);

    try {
      final data = {
        'fullName': _nameController.text,
        'position': _selectedPosition,
        'region': _selectedRegion,
        'phone': _phoneController.text,
      };

      if (widget.isEditing) {
        await cubit.updateOfficer(
          widget.existingOfficer!.id,
          data,
          photoBytes: _photoBytes,
        );
        messenger.showSnackBar(
          const SnackBar(content: Text("Mas'ul muvaffaqiyatli yangilandi!")),
        );
        navigator.pop();
      } else {
        final credentials = await cubit.createOfficer(
          data,
          photoBytes: _photoBytes,
        );
        if (mounted && credentials != null) {
          await _showCredentialsDialog(
            credentials['username'] as String,
            credentials['password'] as String,
          );
        }
        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        messenger.showSnackBar(
          SnackBar(content: Text("Xatolik: ${safeErrorMessage(e)}")),
        );
      }
    }
  }

  Future<void> _showCredentialsDialog(String username, String password) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Mas'ul yaratildi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quyidagi ma'lumotlarni mas'ulga yuboring:",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _credentialRow("Foydalanuvchi nomi", username),
            const SizedBox(height: 8),
            _credentialRow("Parol", password),
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
  }

  Widget _credentialRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Expanded(
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
          ),
        ],
      ),
    );
  }
}
