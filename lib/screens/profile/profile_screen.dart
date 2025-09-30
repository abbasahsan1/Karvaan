import 'package:flutter/material.dart';
import 'package:karvaan/navigation/app_navigation.dart';
import 'package:karvaan/providers/user_provider.dart';
import 'package:karvaan/routes/app_routes.dart';
import 'package:karvaan/services/vehicle_service.dart';
import 'package:karvaan/theme/app_theme.dart';
import 'package:karvaan/widgets/custom_button.dart';
import 'package:karvaan/widgets/glass_container.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool _isEditing = false;
  bool _isLoading = false;
  String? _errorMessage;

  final VehicleService _vehicleService = VehicleService.instance;
  int _vehicleCount = 0;
  bool _loadingVehicles = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
      _loadVehicleCount();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    if (user == null) return;

    _nameController.text = user.name ?? '';
    _emailController.text = user.email;
    _phoneController.text = user.phone ?? '';
  }

  Future<void> _loadVehicleCount() async {
    if (!mounted) return;
    setState(() {
      _loadingVehicles = true;
    });

    try {
      final vehicles = await _vehicleService.getVehiclesForCurrentUser();
      if (!mounted) return;
      setState(() {
        _vehicleCount = vehicles.length;
        _loadingVehicles = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingVehicles = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (success) {
        setState(() {
          _isEditing = false;
        });
      } else {
        setState(() {
          _errorMessage = userProvider.error ?? 'Failed to update profile';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            borderRadius: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.exit_to_app_rounded, size: 42, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Logout',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to sign out of Karvaan?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.pop(context, false),
                        isOutlined: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Logout',
                        onPressed: () => Navigator.pop(context, true),
                        backgroundColor: AppTheme.accentRedColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;

    await Provider.of<UserProvider>(context, listen: false).logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userProvider.currentUser == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('You are not logged in.'),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Login',
                  onPressed: () async {
                    await Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                ),
              ],
            ),
          );
        }

        final bottomInset = MediaQuery.of(context).padding.bottom;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 72 + bottomInset),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.32),
                              blurRadius: 36,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_rounded, size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        userProvider.displayName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        userProvider.currentUser!.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                        child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your garage',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            _loadingVehicles
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(
                                    '$_vehicleCount ${_vehicleCount == 1 ? 'vehicle' : 'vehicles'} registered',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.white70,
                                        ),
                                  ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const AppNavigation(initialIndex: 1),
                            ),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 24),
                  GlassContainer(
                    padding: const EdgeInsets.all(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFE11D48)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Personal information',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                          ),
                          if (!_isEditing)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isEditing = true;
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                              ),
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Edit'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        enabled: false,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone_rounded),
                        ),
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 28),
                      if (_isEditing)
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Cancel',
                                onPressed: () {
                                  _loadUserData();
                                  setState(() {
                                    _isEditing = false;
                                    _errorMessage = null;
                                  });
                                },
                                isOutlined: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomButton(
                                text: 'Save',
                                onPressed: _saveProfile,
                                isLoading: _isLoading,
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomButton(
                              text: 'Change Password',
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.changePassword);
                              },
                              isOutlined: true,
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: 'Logout',
                              onPressed: _logout,
                              backgroundColor: AppTheme.accentRedColor,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
