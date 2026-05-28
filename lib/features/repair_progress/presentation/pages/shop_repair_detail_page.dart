import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/repair_progress_api_service.dart';
import '../../data/models/repair_progress_model.dart';

class ShopRepairDetailPage extends StatefulWidget {
  final int shopId;
  final RepairProgressModel repair;

  const ShopRepairDetailPage({
    super.key,
    required this.shopId,
    required this.repair,
  });

  @override
  State<ShopRepairDetailPage> createState() => _ShopRepairDetailPageState();
}

class _ShopRepairDetailPageState extends State<ShopRepairDetailPage> {
  final _service = RepairProgressApiService();
  late RepairProgressModel _repair;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _repair = widget.repair;
  }

  Future<void> _updateStage() async {
    final token = context.read<AuthService>().token;
    if (token != null) _service.setAuthToken(token);

    String selectedStage = _repair.stage;
    final noteCtrl = TextEditingController();
    final estCtrl = TextEditingController(
        text: _repair.estimatedCompletion?.substring(0, 10) ?? '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Update Stage'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              initialValue: selectedStage,
              decoration: const InputDecoration(
                  labelText: 'New Stage', border: OutlineInputBorder()),
              items: RepairProgressModel.stages.map((s) {
                final label = s
                    .replaceAll('_', ' ')
                    .split(' ')
                    .map((w) => w[0].toUpperCase() + w.substring(1))
                    .join(' ');
                return DropdownMenuItem(value: s, child: Text(label));
              }).toList(),
              onChanged: (v) => setDlg(() => selectedStage = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Note (optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: estCtrl,
              decoration: const InputDecoration(
                  labelText: 'Est. Completion (YYYY-MM-DD)',
                  border: OutlineInputBorder()),
            ),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700),
              child:
                  const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;
    setState(() => _updating = true);

    final data = <String, dynamic>{'stage': selectedStage};
    if (noteCtrl.text.isNotEmpty) data['note'] = noteCtrl.text;
    if (estCtrl.text.isNotEmpty) {
      data['estimated_completion'] = '${estCtrl.text}T00:00:00';
    }

    final updated =
        await _service.updateRepairStage(widget.shopId, _repair.id, data);
    setState(() {
      if (updated != null) _repair = updated;
      _updating = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(updated != null ? 'Stage updated' : 'Failed to update stage'),
        backgroundColor: updated != null ? Colors.green : Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final stageIdx = _repair.stageIndex;

    return Scaffold(
      appBar: AppBar(
        title: Text('Repair #${_repair.id}'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Info card
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_repair.vehicleInfo != null)
                      _row('Vehicle', _repair.vehicleInfo!),
                    _row('Description', _repair.description),
                    if (_repair.estimatedCompletion != null)
                      _row('Est. Completion',
                          _formatDate(_repair.estimatedCompletion!)),
                  ]),
            ),
          ),
          const SizedBox(height: 16),

          // Stage progress
          const Text('Progress',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...List.generate(RepairProgressModel.stages.length, (i) {
            final stage = RepairProgressModel.stages[i];
            final label = stage
                .replaceAll('_', ' ')
                .split(' ')
                .map((w) => w[0].toUpperCase() + w.substring(1))
                .join(' ');
            final isDone = i <= stageIdx;
            final isCurrent = i == stageIdx;

            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? Colors.red.shade700 : Colors.grey.shade300,
                  ),
                  child: Icon(
                    isDone ? Icons.check : Icons.circle_outlined,
                    size: 16,
                    color: isDone ? Colors.white : Colors.grey,
                  ),
                ),
                if (i < RepairProgressModel.stages.length - 1)
                  Container(
                      width: 2,
                      height: 32,
                      color:
                          isDone ? Colors.red.shade300 : Colors.grey.shade300),
              ]),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent
                        ? Colors.red.shade700
                        : isDone
                            ? Colors.black87
                            : Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ]);
          }),

          const SizedBox(height: 24),

          // Update history
          if (_repair.updates.isNotEmpty) ...[
            const Text('Update History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._repair.updates.map((u) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.update, size: 18),
                    title: Text(
                        '${_stageLabel(u.fromStage)} → ${_stageLabel(u.toStage)}',
                        style: const TextStyle(fontSize: 13)),
                    subtitle: u.note != null
                        ? Text(u.note!, style: const TextStyle(fontSize: 12))
                        : null,
                    trailing: Text(_formatDate(u.createdAt),
                        style: const TextStyle(fontSize: 11)),
                  ),
                )),
            const SizedBox(height: 16),
          ],
        ]),
      ),
      bottomNavigationBar: _repair.stage != 'completed'
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _updating ? null : _updateStage,
                icon: _updating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.arrow_forward),
                label: const Text('Update Stage'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          : null,
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        ),
        Expanded(
          child: Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }

  String _stageLabel(String s) => s
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');

  String _formatDate(String d) {
    try {
      final dt = DateTime.parse(d);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return d;
    }
  }
}
