import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/device_model.dart';
import '../models/location_model.dart';

class SupabaseService with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  
  List<DeviceModel> _devices = [];
  List<DeviceModel> get devices => _devices;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get isAuthenticated => _client.auth.currentSession != null;
  String? get userEmail => _client.auth.currentUser?.email;

  RealtimeChannel? _realtimeChannel;

  // Stream controller to broadcast incoming real-time locations to listener widgets
  final _locationStreamController = StreamController<LocationModel>.broadcast();
  Stream<LocationModel> get locationStream => _locationStreamController.stream;

  Future<String?> signUp(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _client.auth.signUp(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      debugPrint('Error signing up: ${e.message}');
      return e.message;
    } catch (e) {
      debugPrint('Error signing up: $e');
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      await fetchDevices();
      return null;
    } on AuthException catch (e) {
      debugPrint('Error signing in: ${e.message}');
      return e.message;
    } catch (e) {
      debugPrint('Error signing in: $e');
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      _devices.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  Future<void> fetchDevices() async {
    if (!isAuthenticated) return;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _client
          .from('devices')
          .select()
          .order('name', ascending: true);
      
      _devices = (response as List)
          .map((data) => DeviceModel.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching devices: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DeviceModel?> registerDevice(String name) async {
    try {
      final response = await _client
          .from('devices')
          .insert({'name': name, 'status': 'offline'})
          .select()
          .single();
      
      final newDevice = DeviceModel.fromJson(response);
      _devices.add(newDevice);
      notifyListeners();
      return newDevice;
    } catch (e) {
      debugPrint('Error registering device: $e');
      return null;
    }
  }

  // Initiates a new Trip session directly via Database
  Future<String?> startTrip(String deviceId, String tripName) async {
    try {
      final response = await _client.from('trips').insert({
        'device_id': deviceId,
        'name': tripName,
        'status': 'active',
      }).select().single();
      
      final tripId = response['id'] as String;

      // Set device status to tracking
      await _client
          .from('devices')
          .update({'status': 'tracking'})
          .eq('id', deviceId);

      return tripId;
    } catch (e) {
      debugPrint('Error starting trip directly: $e');
      return null;
    }
  }

  // Concludes Trip session directly via Database
  Future<bool> endTrip(String tripId) async {
    try {
      // Fetch the trip to get device_id
      final tripResponse = await _client
          .from('trips')
          .select('device_id')
          .eq('id', tripId)
          .single();
      
      final deviceId = tripResponse['device_id'] as String;

      // Complete the trip
      await _client
          .from('trips')
          .update({
            'status': 'completed',
            'end_time': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', tripId);

      // Revert device status back to online
      await _client
          .from('devices')
          .update({'status': 'online'})
          .eq('id', deviceId);

      return true;
    } catch (e) {
      debugPrint('Error ending trip directly: $e');
      return false;
    }
  }

  // Inserts single coordinate directly to Database
  Future<void> sendLocation({
    required String tripId,
    required String deviceId,
    required double latitude,
    required double longitude,
    required double speed,
  }) async {
    try {
      await _client.from('locations').insert({
        'trip_id': tripId,
        'device_id': deviceId,
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed,
      });
    } catch (e) {
      debugPrint('Error posting location telemetry: $e');
    }
  }

  // Fetch location logs for a past trip (used to render static route maps)
  Future<List<LocationModel>> fetchTripLocations(String tripId) async {
    try {
      final response = await _client
          .from('locations')
          .select()
          .eq('trip_id', tripId)
          .order('created_at', ascending: true);
      
      return (response as List)
          .map((data) => LocationModel.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching historical trip locations: $e');
      return [];
    }
  }

  // Subscribe to REALTIME location updates for a specific active trip
  void subscribeToLiveTrip(String tripId) {
    unsubscribeFromLiveTrip();

    _realtimeChannel = _client.channel('public:locations')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'locations',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'trip_id',
          value: tripId,
        ),
        callback: (payload) {
          final newRecord = payload.newRecord;
          final loc = LocationModel.fromJson(newRecord);
          _locationStreamController.add(loc);
        },
      )
      .subscribe();
  }

  void unsubscribeFromLiveTrip() {
    if (_realtimeChannel != null) {
      _client.removeChannel(_realtimeChannel!);
      _realtimeChannel = null;
    }
  }

  @override
  void dispose() {
    unsubscribeFromLiveTrip();
    _locationStreamController.close();
    super.dispose();
  }
}
