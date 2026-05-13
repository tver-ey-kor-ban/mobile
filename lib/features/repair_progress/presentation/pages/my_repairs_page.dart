import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/repair_progress_api_service.dart';
import '../../data/models/repair_progress_model.dart';

class MyRepairsPage extends StatefulWidget {
  const MyRepairsPage({super.key});

  @override
  State<MyRepairsPage> createState() => _MyRepairsPageState();
}

class _MyRepairsPageState extends State<MyRepairsPage> {
  final _service = RepairProgressApiService();
  List<RepairProgressModel> _repairs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthService>().token;
    if (token != null) _service.setAuthToken(token);
    setState(() => _loading = true);
    final list = await _service.getMyRepairs();
    setState(() {
      _repairs = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repair Progress'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _repairs.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _repairs.length,
                      itemBuilder: (_, i) => _buildCard(_repairs[i]),
                    ),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build_circle_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No repairs in progress',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildCard(RepairProgressModel repair) {
    final stageColor = _stageColor(repair.stage);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Text(
                repair.description.isNotEmpty
                    ? repair.description
                    : 'Repair #${repair.id}',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: stageColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: stageColor),
              ),
              child: Text(
                _stageName(repair.stage),
                style: TextStyle(
                    fontSize: 11, color: stageColor, fontWeight: FontWeight.bold),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: repair.progress,
              backgroundColor: Colors.grey.shade200,
              color: stageColor,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(repair.progress * 100).toInt()}% Complete  —  Step ${repair.stageIndex + 1} of ${RepairProgressModel.stages.length}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          if (repair.estimatedCompletion != null) ...[
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                'Est. completion: ${_formatDate(repair.estimatedCompletion!)}',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ]),
          ],
          if (repair.updates.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Recent Updates',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            ...repair.updates.take(3).map((u) => _updateItem(u)),
          ],
        ]),
      ),
    );
  }

  Widget _updateItem(RepairUpdate u) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: const EdgeInsets.only(top: 5, right: 8),
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${_stageName(u.fromStage)} → ${_stageName(u.toStage)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            if (u.note != null && u.note!.isNotEmpty)
              Text(u.note!,
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            Text(_formatDate(u.createdAt),
                style:
                    TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ]),
        ),
      ]),
    );
  }

  String _stageName(String s) {
    return s.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }

  Color _stageColor(String stage) {
    switch (stage) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
      case 'quality_check':
        return Colors.blue;
      case 'ready_for_pickup':
        return Colors.purple;
      case 'waiting_parts':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String d) {
    try {
      final dt = DateTime.parse(d);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return d;
    }
  }
}
