import 'package:flutter/material.dart';

class StepOneUserInfo extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController dateController;
  final TextEditingController timeController;

  const StepOneUserInfo({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.dateController,
    required this.timeController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ព័ត៌មានអតិថិជន",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text("បញ្ចូលព័ត៌មានផ្ទាល់ខ្លួនរបស់អ្នក"),
        const SizedBox(height: 20),

        _buildTextField(
          label: "ឈ្មោះ-ត្រកូល *",
          icon: Icons.person,
          controller: nameController,
        ),
        const SizedBox(height: 15),

        _buildTextField(
          label: "លេខទូរស័ព្ទ *",
          icon: Icons.phone,
          controller: phoneController,
        ),
        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: "ថ្ងៃខែ *",
                icon: Icons.calendar_today,
                controller: dateController,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                label: "ម៉ោង *",
                icon: Icons.access_time,
                controller: timeController,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
