import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yoshlar/data/service/api_client.dart';
import 'package:yoshlar/data/service/face_compare_service.dart';
import 'package:yoshlar/data/service/location_service.dart';
import 'package:yoshlar/logic/auth/auth_cubit.dart';
import 'package:yoshlar/logic/auth/auth_state.dart';
import 'package:yoshlar/logic/youth/youth_detail_cubit.dart';
import 'package:yoshlar/presentation/widgets/web_camera_dialog.dart';

class AddActivityPage extends StatefulWidget {
  static const routeName = 'add_activity';
  final int? youthId;
  final String? youthName;

  const AddActivityPage({super.key, this.youthId, this.youthName});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final List<Uint8List> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  final LocationService _locationService = LocationService();

  // Location state
  double? _latitude;
  double? _longitude;
  String _locationStatus = 'Aniqlanmoqda...';
  bool _locationLoading = true;

  static const int _minImages = 3;
  static const int _maxImages = 10;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _locationStatus = '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
          _locationLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationStatus = "Joylashuv aniqlanmadi";
          _locationLoading = false;
        });
      }
    }
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Maksimum $_maxImages ta rasm tanlash mumkin")),
      );
      return;
    }

    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      final remaining = _maxImages - _selectedImages.length;
      final toAdd = images.take(remaining).toList();
      final bytesList = await Future.wait(toAdd.map((img) => img.readAsBytes()));
      setState(() {
        _selectedImages.addAll(bytesList);
      });
      if (images.length > remaining) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Faqat $remaining ta rasm qo'shildi (maksimum $_maxImages)")),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Sarlavha"),
              _buildInputField("Faoliyat sarlavhasi", controller: _titleController),
              const SizedBox(height: 20),
              _buildLabel("Tavsif"),
              _buildInputField(
                "Faoliyat haqida batafsil ma'lumot",
                maxLines: 5,
                controller: _descriptionController,
              ),
              const SizedBox(height: 20),
              _buildLabel("Lokatsiya"),
              const SizedBox(height: 8),
              _buildLocationSection(),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildLabel("Rasmlar"),
                  const Spacer(),
                  Text(
                    "${_selectedImages.length}/$_maxImages (kamida $_minImages ta)",
                    style: TextStyle(
                      fontSize: 13,
                      color: _selectedImages.length < _minImages ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildImageSection(),
              const SizedBox(height: 40),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            _locationLoading
                ? Icons.my_location
                : (_latitude != null ? Icons.location_on : Icons.location_off),
            color: _latitude != null ? Colors.green : Colors.orange,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _locationStatus,
              style: TextStyle(
                fontSize: 14,
                color: _latitude != null ? Colors.black87 : Colors.red.shade700,
              ),
            ),
          ),
          if (_locationLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (_latitude == null)
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: () {
                setState(() {
                  _locationLoading = true;
                  _locationStatus = 'Aniqlanmoqda...';
                });
                _fetchLocation();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        InkWell(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: Colors.blue.shade700),
                const SizedBox(width: 10),
                const Text(
                  "Rasm qo'shish",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _selectedImages[index],
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 14,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Yangi faoliyat qo'shish",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.youthName ?? "",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInputField(String hint, {int maxLines = 1, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    "Yuborish",
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  void _showNoPhotoWarning() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text("Diqqat!", style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          "Sizning profilingizga rasm yuklanmagan. "
          "Faoliyat qo'shish uchun rahbariyat sizning rasmingizni yuklashi kerak. "
          "Iltimos, rahbariyatga murojaat qiling.",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tushundim"),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sarlavhani kiriting")),
      );
      return;
    }

    if (_selectedImages.length < _minImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kamida $_minImages ta rasm tanlang (hozir ${_selectedImages.length} ta)")),
      );
      return;
    }

    // context.read ni async gapdan oldin chaqirish
    final authCubit = context.read<AuthCubit>();
    final faceService = context.read<FaceCompareService>();
    final youthDetailCubit = context.read<YouthDetailCubit>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isSubmitting = true);

    try {
      // 1. Lokatsiya (allaqachon initState da olingan)
      final lat = _latitude;
      final lng = _longitude;

      // 2. Yuz solishtirish (selfie)

      final authState = authCubit.state;
      int? officerId;
      bool hasPhoto = false;
      if (authState is AuthAuthenticated) {
        officerId = authState.user.officerId;
        hasPhoto = authState.user.officerPhoto;
      }

      if (officerId != null) {
        if (!hasPhoto) {
          if (mounted) {
            setState(() => _isSubmitting = false);
            _showNoPhotoWarning();
          }
          return;
        }

        if (!mounted) return;

        // Web camera dialog orqali selfie olish
        final Uint8List? selfieBytes = await WebCameraCaptureDialog.show(context);

        if (selfieBytes == null) {
          if (mounted) {
            setState(() => _isSubmitting = false);
            messenger.showSnackBar(
              const SnackBar(content: Text("Selfie talab qilinadi")),
            );
          }
          return;
        }
        final result = await faceService.compareFace(officerId, selfieBytes);

        final similarity = result['similarity'];
        final isMatch = result['match'] == true;

        if (!isMatch) {
          if (mounted) {
            setState(() => _isSubmitting = false);
            final simText = similarity != null ? ' (${similarity}%)' : '';
            messenger.showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? "Yuz mos kelmadi$simText. Kamida 70% talab qilinadi"),
                duration: const Duration(seconds: 4),
              ),
            );
          }
          return;
        }

        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text("Yuz tasdiqlandi (${similarity ?? ''}%)"),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      // 3. Faoliyat yuborish
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final data = <String, dynamic>{
        'title': title,
        'description': _descriptionController.text.trim(),
        'date': dateStr,
        'status': 'rejalashtirilgan',
      };

      if (lat != null && lng != null) {
        data['latitude'] = lat;
        data['longitude'] = lng;
      }

      await youthDetailCubit.createActivity(
        data,
        imageBytes: _selectedImages.isNotEmpty ? _selectedImages : null,
      );
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text("Faoliyat muvaffaqiyatli qo'shildi!")),
        );
        Navigator.pop(context);
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
}
