import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_theme.dart';
import '../utils/helpers.dart';
import 'map_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final SupabaseClient _client = Supabase.instance.client;
  List<dynamic> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTripHistory();
  }

  Future<void> _fetchTripHistory() async {
    try {
      final response = await _client
          .from('trips')
          .select('*, devices(name)')
          .order('start_time', ascending: false);
      
      setState(() {
        _trips = response as List;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading trip history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History Records'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trips.isEmpty
              ? const Center(
                  child: Text(
                    'No trips recorded yet.',
                    style: TextStyle(color: AppTheme.textSecondaryDark),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: _trips.length,
                    itemBuilder: (context, index) {
                      final trip = _trips[index];
                      final deviceName = trip['devices'] != null
                          ? trip['devices']['name'] as String
                          : 'Unknown Device';
                      
                      final start = DateTime.parse(trip['start_time'] as String);
                      final end = trip['end_time'] != null
                          ? DateTime.parse(trip['end_time'] as String)
                          : null;

                      final isCompleted = trip['status'] == 'completed';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBgDark,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.route_outlined,
                              color: isCompleted ? AppTheme.secondaryAccent : AppTheme.successColor,
                            ),
                          ),
                          title: Text(
                            trip['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Device: $deviceName'),
                              Text('Started: ${Helpers.formatDateTime(start)}'),
                              if (isCompleted && end != null)
                                Text('Duration: ${Helpers.formatDuration(start, end)}')
                              else
                                const Text(
                                  'Ongoing Trip',
                                  style: TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapScreen(
                                  tripId: trip['id'] as String,
                                  deviceName: deviceName,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
