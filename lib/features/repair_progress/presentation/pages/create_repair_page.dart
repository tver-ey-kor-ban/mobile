import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/repair_progress_api_service.dart';
import '../../data/models/repair_progress_model.dart';

class CreateRepairPage extends StatefulWidget {
  final int shopId;
  final int? appointmentId;

  const CreateRepairPage({
    super.key,
    required this.shopId,
    this.appointmentId,
  });

  @override
  State<CreateRepairPage> createState() => _CreateRepairPageState();
}

class _CreateRepairPageState extends State<CreateRepairPage> {
  final _service = RepairProgressApiService();
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _estCtrl = TextEditingController();
  String _stage = 'received';
  bool _submitting = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    _estCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final token = context.read<AuthService>().token;
    if (token != null) _service.setAuthToken(token);
    setState(() => _submitting = true);

    final data = <String, dynamic>{
      'stage': _stage,
      'description': _descCtrl.text.trim(),
      if (widget.appointmentId != null) 'appointment_id': widget.appointmentId,
      if (_estCtrl.text.isNotEmpty)
        'estimated_completion': '${_estCtrl.text}T00:00:00',
    };

    final result = await _service.createRepair(widget.shopId, data);
    setState(() => _submitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result != null
            ? 'Repair record created'
            : 'Failed to create repair'),
        backgroundColor: result != null ? Colors.green : Colors.red,
      ));
      if (result != null) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Repair Record'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _stage,
              decoration: const InputDecoration(
                  labelText: 'Initial Stage', border: OutlineInputBorder()),
              items: RepairProgressModel.stages.map((s) {
                final label = s
                    .replaceAll('_', ' ')
                    .split(' ')
                    .map((w) => w[0].toUpperCase() + w.substring(1))
                    .join(' ');
                return DropdownMenuItem(value: s, child: Text(label));
              }).toList(),
              onChanged: (v) => setState(() => _stage = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Description *', border: OutlineInputBorder()),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _estCtrl,
              decoration: const InputDecoration(
                labelText: 'Estimated Completion (YYYY-MM-DD)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Create Repair Record',
                      style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
