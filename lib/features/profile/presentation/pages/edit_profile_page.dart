import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    _nameCtrl = TextEditingController(text: auth.userName ?? '');
    _phoneCtrl = TextEditingController(text: auth.userPhone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    context.read<AuthService>().updateProfile(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        );

    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.red.shade50,
                      child: Text(
                        (auth.userName ?? 'U').substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 15, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Full Name
              _buildLabel('Full Name'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  hint: 'Enter your full name',
                  icon: Icons.person_outline,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),

              // Email (read-only)
              _buildLabel('Email'),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: auth.userEmail ?? '',
                readOnly: true,
                decoration: _inputDecoration(
                  hint: 'Email',
                  icon: Icons.email_outlined,
                ).copyWith(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  suffixIcon: Tooltip(
                    message: 'Email cannot be changed',
                    child: Icon(Icons.lock_outline,
                        size: 18, color: Colors.grey.shade400),
                  ),
                ),
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),

              // Username (read-only)
              if (auth.username != null) ...[
                _buildLabel('Username'),
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: '@${auth.username}',
                  readOnly: true,
                  decoration: _inputDecoration(
                    hint: 'Username',
                    icon: Icons.alternate_email,
                  ).copyWith(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    suffixIcon: Tooltip(
                      message: 'Username cannot be changed',
                      child: Icon(Icons.lock_outline,
                          size: 18, color: Colors.grey.shade400),
                    ),
                  ),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
              ],

              // Phone
              _buildLabel('Phone Number'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration(
                  hint: 'Enter your phone number (optional)',
                  icon: Icons.phone_outlined,
                ),
              ),
              const SizedBox(height: 36),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save Changes',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    );
  }

  InputDecoration _inputDecoration(
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
