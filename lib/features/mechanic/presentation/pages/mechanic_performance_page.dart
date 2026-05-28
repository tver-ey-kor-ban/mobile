import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/mechanic_api_service.dart';

class MechanicPerformancePage extends StatefulWidget {
  final int shopId;
  const MechanicPerformancePage({super.key, required this.shopId});

  @override
  State<MechanicPerformancePage> createState() =>
      _MechanicPerformancePageState();
}

class _MechanicPerformancePageState extends State<MechanicPerformancePage> {
  final _service = MechanicApiService();
  Map<String, dynamic>? _myPerf;
  Map<String, dynamic>? _allPerf;
  bool _loading = true;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthService>();
    if (auth.token != null) _service.setAuthToken(auth.token!);
    _isOwner = auth.isShopOwner;
    setState(() => _loading = true);

    final myPerf = await _service.getMyPerformance(widget.shopId);
    Map<String, dynamic>? allPerf;
    if (_isOwner) {
      allPerf = await _service.getAllMechanicsPerformance(widget.shopId);
    }

    setState(() {
      _myPerf = myPerf;
      _allPerf = allPerf;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_myPerf != null) ...[
                        const Text('My Performance',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildMyPerf(),
                        const SizedBox(height: 24),
                      ],
                      if (_isOwner && _allPerf != null) ...[
                        const Text('Team Performance',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildTeamPerf(),
                      ],
                      if (_myPerf == null && _allPerf == null) _buildEmpty(),
                    ]),
              ),
            ),
    );
  }

  Widget _buildMyPerf() {
    final p = _myPerf!;
    final totalJobs = p['total_jobs'] ?? p['jobs_completed'] ?? 0;
    final revenue =
        (p['total_revenue'] ?? p['revenue_generated'] ?? 0.0).toDouble();
    final avgRating = (p['average_rating'] ?? p['rating'] ?? 0.0).toDouble();
    final rank = p['rank'];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _perfStat('Jobs', '$totalJobs', Colors.blue, Icons.build_outlined),
            _perfStat('Revenue', '\$${revenue.toStringAsFixed(0)}',
                Colors.green, Icons.attach_money),
            _perfStat('Rating', avgRating.toStringAsFixed(1), Colors.orange,
                Icons.star_outline),
          ]),
          if (rank != null) ...[
            const Divider(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 8),
              Text('Shop Rank: #$rank',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ]),
          ],
        ]),
      ),
    );
  }

  Widget _buildTeamPerf() {
    final summary = _allPerf?['shop_summary'] ?? {};
    final mechanics = (_allPerf?['mechanics'] as List<dynamic>?) ?? [];

    return Column(children: [
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _perfStat('Total Jobs', '${summary['total_jobs'] ?? 0}',
                Colors.blue, Icons.build_outlined),
            _perfStat(
                'Revenue',
                '\$${(summary['total_revenue'] ?? 0.0).toStringAsFixed(0)}',
                Colors.green,
                Icons.attach_money),
            _perfStat('Mechanics', '${summary['mechanic_count'] ?? 0}',
                Colors.purple, Icons.people_outlined),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      if (mechanics.isNotEmpty) ...[
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Mechanics',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ),
        const SizedBox(height: 8),
        ...mechanics.map((m) {
          final name = m['mechanic_name'] ?? m['name'] ?? 'Mechanic';
          final jobs = m['total_jobs'] ?? m['jobs'] ?? 0;
          final rev = (m['total_revenue'] ?? m['revenue'] ?? 0.0).toDouble();
          final rating = (m['average_rating'] ?? m['rating'] ?? 0.0).toDouble();
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade100,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'M',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
              title: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('$jobs jobs  ·  \$${rev.toStringAsFixed(0)}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                Text(rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 13)),
              ]),
            ),
          );
        }),
      ],
    ]);
  }

  Widget _perfStat(String label, String value, Color color, IconData icon) {
    return Column(children: [
      Icon(icon, color: color, size: 28),
      const SizedBox(height: 6),
      Text(value,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: color)),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
    ]);
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          Icon(Icons.bar_chart_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No performance data yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600)),
        ]),
      ),
    );
  }
}
