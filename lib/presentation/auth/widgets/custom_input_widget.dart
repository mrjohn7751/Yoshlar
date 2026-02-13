import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: Icon(widget.prefixIcon),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}
