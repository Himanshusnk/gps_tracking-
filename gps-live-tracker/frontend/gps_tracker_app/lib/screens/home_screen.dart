import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';
import '../services/supabase_service.dart';
import '../widgets/device_card.dart';
import '../widgets/custom_button.dart';
import 'tracker_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _deviceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupabaseService>().fetchDevices();
    });
  }

  void _showRegisterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBgDark,
          title: const Text('Register New Device'),
          content: TextField(
            controller: _deviceController,
            decoration: const InputDecoration(
              hintText: 'Enter device name (e.g. Drone-03)',
              hintStyle: TextStyle(color: AppTheme.textSecondaryDark),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryAccent),
              onPressed: () async {
                final name = _deviceController.text.trim();
                if (name.isNotEmpty) {
                  final navigator = Navigator.of(context);
                  await context.read<SupabaseService>().registerDevice(name);
                  _deviceController.clear();
                  navigator.pop();
                }
              },
              child: const Text('Register', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final supabaseService = context.watch<SupabaseService>();

    if (!supabaseService.isAuthenticated) {
      return const _AuthView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Live Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppTheme.secondaryAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            tooltip: 'Sign Out',
            onPressed: () async {
              await context.read<SupabaseService>().signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Telemetry Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  supabaseService.userEmail ?? '',
                  style: const TextStyle(fontSize: 12, color: AppTheme.secondaryAccent),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a registered device to begin tracking or simulator runs.',
              style: TextStyle(color: AppTheme.textSecondaryDark),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: supabaseService.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : supabaseService.devices.isEmpty
                      ? const Center(
                          child: Text(
                            'No devices registered yet.',
                            style: TextStyle(color: AppTheme.textSecondaryDark),
                          ),
                        )
                      : ListView.builder(
                          itemCount: supabaseService.devices.length,
                          itemBuilder: (context, index) {
                            final device = supabaseService.devices[index];
                            return DeviceCard(
                              device: device,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TrackerScreen(device: device),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Register New Device',
              icon: Icons.add,
              onPressed: _showRegisterDialog,
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthView extends StatefulWidget {
  const _AuthView();

  @override
  State<_AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<_AuthView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('last_entered_email');
      if (savedEmail != null && mounted) {
        _emailController.text = savedEmail;
      }
    } catch (e) {
      debugPrint('Error loading saved email: $e');
    }
  }

  Future<void> _saveEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_entered_email', email);
    } catch (e) {
      debugPrint('Error saving email: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Validate email syntax constraint
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
    );
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    // Enforce password length constraint
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters long')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final service = context.read<SupabaseService>();
    String? errorMessage;

    if (_isSignUp) {
      errorMessage = await service.signUp(email, password);
      if (mounted && errorMessage == null) {
        _saveEmail(email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please sign in.')),
        );
        setState(() {
          _isSignUp = false;
        });
      }
    } else {
      errorMessage = await service.signIn(email, password);
      if (errorMessage == null) {
        _saveEmail(email);
      }
    }

    if (mounted && errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              color: AppTheme.cardBgDark,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Icon(
                        Icons.security,
                        color: AppTheme.secondaryAccent,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        _isSignUp ? 'Create Account' : 'Sign In',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Secure telemetry workspace',
                        style: TextStyle(
                          color: AppTheme.textSecondaryDark,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppTheme.textSecondaryDark,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: _isSignUp ? 'Sign Up' : 'Sign In',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isSignUp = !_isSignUp;
                          });
                        },
                        child: Text(
                          _isSignUp
                              ? 'Already have an account? Sign In'
                              : 'Don\'t have an account? Sign Up',
                          style: const TextStyle(color: AppTheme.secondaryAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
