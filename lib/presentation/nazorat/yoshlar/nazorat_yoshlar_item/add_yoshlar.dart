import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yoshlar/data/model/user.dart';
import 'package:yoshlar/data/service/api_client.dart';
import 'package:yoshlar/logic/youth/youth_list_cubit.dart';
import 'package:yoshlar/presentation/widgets/debug_image.dart';

class AddYouthScreen extends StatefulWidget {
  static const String routeName = 'add_youth';
  static const String editRouteName = 'edit_youth';

  final UserModel? existingYouth;

  const AddYouthScreen({super.key, this.existingYouth});

  bool get isEditing => existingYouth != null;

  @override
  State<AddYouthScreen> createState() => _AddYouthScreenState();
}

class _AddYouthScreenState extends State<AddYouthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedGender;
  String? _selectedRegion;
  String? _selectedEducation;
  String? _selectedEmployment;
  String? _selectedRiskLevel;
  bool _isSubmitting = false;

  Uint8List? _photoBytes;
  String? _existingPhotoUrl;
  String? _existingRawImage;
  final ImagePicker _picker = ImagePicker();

  static const List<Map<String, dynamic>> _regions = [
    {'id': 1, 'name': 'Jizzax shahar'},
    {'id': 2, 'name': 'Arnasoy tumani'},
    {'id': 3, 'name': 'Baxmal tumani'},
    {'id': 4, 'name': "G'allaorol tumani"},
    {'id': 5, 'name': "Do'stlik tumani"},
    {'id': 6, 'name': 'Sharof Rashidov tumani'},
    {'id': 7, 'name': 'Zomin tumani'},
    {'id': 8, 'name': 'Zarbdor tumani'},
    {'id': 9, 'name': 'Zafarobod tumani'},
    {'id': 10, 'name': "Mirzacho'l tumani"},
    {'id': 11, 'name': 'Paxtakor tumani'},
    {'id': 12, 'name': 'Forish tumani'},
    {'id': 13, 'name': 'Yangiobod tumani'},
  ];

  final Map<String, bool> _categories = {
    "Probatsiya nazoratidagilar": false,
    "Ilgari sudlanganlar": false,
    "Yod g'oyalar ta'siriga tushganlar": false,
    "Jinoyat sodir etgan voyaga yetmaganlar": false,
    "Giyohvandlar va spirtli ichimliklar ruju quyganlar": false,
    "Mehribonlik uyidan chiqqanlar": false,
    "Agressiv xulq-atvorli yoshlar": false,
    "Ma'muriy huquqbuzarlik sodir etganlar": false,
  };

  @override
  void initState() {
    super.initState();
    final youth = widget.existingYouth;
    if (youth != null) {
      _nameController.text = youth.name;
      _phoneController.text = youth.phone ?? '';
      _birthDateController.text = youth.birthDate;
      _locationController.text = youth.location;
      _selectedGender = youth.gender.isNotEmpty ? youth.gender : null;
      _selectedEducation = youth.status.isNotEmpty ? youth.status : null;
      _selectedEmployment = youth.activity.isNotEmpty ? youth.activity : null;
      _selectedRiskLevel = youth.riskLevel.isNotEmpty ? youth.riskLevel : null;

      // Set region
      if (youth.region != null) {
        final match = _regions.cast<Map<String, dynamic>?>().firstWhere(
          (r) => r!['name'] == youth.region!.name,
          orElse: () => null,
        );
        if (match != null) _selectedRegion = match['name'] as String;
      }

      // Set photo
      _existingPhotoUrl = youth.image;
      _existingRawImage = youth.rawImage;

      // Set categories
      for (final tag in youth.tags) {
        if (_categories.containsKey(tag)) {
          _categories[tag] = true;
        }
      }
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
    _birthDateController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEditing;
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
              isEdit ? "Yoshni tahrirlash" : "Yangi yosh qo'shish",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isEdit ? widget.existingYouth!.name : "Barcha majburiy maydonlarni to'ldiring",
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
              const SizedBox(height: 16),
              _buildPersonalInfoSection(),
              const SizedBox(height: 16),
              _buildAddressSection(),
              const SizedBox(height: 16),
              _buildEducationSection(),
              const SizedBox(height: 16),
              _buildCategoriesSection(),
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
    final hasLocalPhoto = _photoBytes != null;
    final hasNetworkPhoto = _existingPhotoUrl != null && _existingPhotoUrl!.startsWith('http');
    final hasImage = hasLocalPhoto || hasNetworkPhoto;

    return Column(
      children: [
        GestureDetector(
          onTap: _pickPhoto,
          child: hasLocalPhoto
              ? CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: MemoryImage(_photoBytes!),
                )
              : hasNetworkPhoto
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: DebugNetworkImage(
                        imageUrl: _existingPhotoUrl,
                        rawBackendValue: _existingRawImage,
                        height: 80,
                        width: 80,
                        borderRadius: BorderRadius.circular(40),
                      ),
                    )
                  : CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue.shade50,
                      child: Icon(
                        Icons.person_outline,
                        size: 40,
                        color: Colors.blue.shade300,
                      ),
                    ),
        ),
        const SizedBox(height: 8),
        if (_existingPhotoUrl != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'URL: ${_existingPhotoUrl!.length > 60 ? '...${_existingPhotoUrl!.substring(_existingPhotoUrl!.length - 60)}' : _existingPhotoUrl}',
              style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ),
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

  Widget _buildPersonalInfoSection() {
    return _buildCardWrapper(
      icon: Icons.person_outline,
      title: "Shaxsiy ma'lumotlar",
      child: Column(
        children: [
          _buildTextField(
            label: "F.I.Sh. *",
            hint: "To'liq ism familiya",
            controller: _nameController,
          ),
          const SizedBox(height: 16),
          _buildPhoneField(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: "Jinsi *",
                  items: ["Erkak", "Ayol"],
                  value: _selectedGender,
                  onChanged: (val) => setState(() => _selectedGender = val),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  label: "Tug'ilgan sana *",
                  hint: "2000-01-01",
                  controller: _birthDateController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return _buildCardWrapper(
      title: "Yashash manzili",
      child: Column(
        children: [
          _buildDropdown(
            label: "Tuman *",
            items: _regions.map((r) => r['name'] as String).toList(),
            value: _selectedRegion,
            onChanged: (val) => setState(() => _selectedRegion = val),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Manzil",
            hint: "Mahalla, ko'cha, uy raqami",
            controller: _locationController,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildEducationSection() {
    return _buildCardWrapper(
      title: "Ta'lim va bandlik",
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: "Ta'lim holati",
                  items: ["O'qimoqda", "Bitirgan", "O'qimayapti"],
                  value: _selectedEducation,
                  onChanged: (val) => setState(() => _selectedEducation = val),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: "Bandlik holati",
                  items: ["Ishsiz", "Ishlamoqda"],
                  value: _selectedEmployment,
                  onChanged: (val) => setState(() => _selectedEmployment = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: "Xavf darajasi",
            items: ["Past xavf", "O'rta xavf", "Yuqori xavf"],
            value: _selectedRiskLevel,
            onChanged: (val) => setState(() => _selectedRiskLevel = val),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return _buildCardWrapper(
      title: "Yoshlar toifalari *",
      child: Column(
        children: _categories.keys.map((String key) {
          return CheckboxListTile(
            title: Text(key, style: const TextStyle(fontSize: 14)),
            value: _categories[key],
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            onChanged: (bool? value) {
              setState(() {
                _categories[key] = value!;
              });
            },
          );
        }).toList(),
      ),
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
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Bekor qilish",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _saveData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3384C3),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    widget.isEditing ? "Yangilash" : "Saqlash",
                    style: const TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardWrapper({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
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
          Row(
            children: [
              if (icon != null) Icon(icon, size: 20, color: Colors.black87),
              if (icon != null) const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Telefon raqam",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 13,
          decoration: InputDecoration(
            hintText: "+998901234567",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
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
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    DateTime initialDate = DateTime(2000, 1, 1);
    if (_birthDateController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_birthDateController.text);
      } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1970),
      lastDate: now,
    );
    if (picked != null) {
      _birthDateController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Widget _buildDateField({
    required String label,
    required String hint,
    required TextEditingController controller,
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
          readOnly: true,
          onTap: _pickDate,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
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

  Widget _buildTextField({
    required String label,
    required String hint,
    IconData? suffixIcon,
    int maxLines = 1,
    TextEditingController? controller,
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
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 20) : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
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
                "Tanlang",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    if (_nameController.text.isEmpty || _selectedGender == null || _birthDateController.text.isEmpty || _selectedRegion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Majburiy maydonlarni to'ldiring")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final selectedTags = _categories.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    final regionId = _regions.firstWhere((r) => r['name'] == _selectedRegion)['id'];

    // Xavf darajasini backend formatiga o'girish
    String? riskLevelApi;
    if (_selectedRiskLevel != null) {
      const riskMap = {
        'Past xavf': 'past',
        "O'rta xavf": 'orta',
        'Yuqori xavf': 'yuqori',
      };
      riskLevelApi = riskMap[_selectedRiskLevel];
    }

    final data = {
      'name': _nameController.text,
      'phone': _phoneController.text.isNotEmpty ? _phoneController.text : null,
      'gender': _selectedGender,
      'birthDate': _birthDateController.text,
      'region_id': regionId,
      'location': _locationController.text,
      'status': _selectedEducation,
      'activity': _selectedEmployment,
      'riskLevel': riskLevelApi,
      'tags': selectedTags,
    };

    try {
      if (widget.isEditing) {
        await context.read<YouthListCubit>().updateYouth(widget.existingYouth!.id!, data, imageBytes: _photoBytes);
      } else {
        await context.read<YouthListCubit>().createYouth(data, imageBytes: _photoBytes);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? "Yosh muvaffaqiyatli yangilandi!"
                : "Yosh muvaffaqiyatli qo'shildi!"),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Xatolik: ${safeErrorMessage(e)}")),
        );
      }
    }
  }
}
