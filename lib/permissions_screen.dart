import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'theme.dart';
import 'main_screen.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _contacts = false;
  bool _photos = false;
  bool _notifications = false;
  bool _location = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentPermissions();
  }

  Future<void> _checkCurrentPermissions() async {
    final locationStatus = await Permission.location.isGranted;
    final photosStatus = await Permission.photos.isGranted;
    final contactsStatus = await Permission.contacts.isGranted;
    final notificationsStatus = await Permission.notification.isGranted;

    if (mounted) {
      setState(() {
        _location = locationStatus;
        _photos = photosStatus;
        _contacts = contactsStatus;
        _notifications = notificationsStatus;
      });
    }
  }

  Future<void> _requestLocation(bool enable) async {
    if (enable) {
      final status = await Permission.location.request();
      setState(() {
        _location = status.isGranted;
      });
    } else {
      setState(() {
        _location = false;
      });
    }
  }

  Future<void> _requestPhotos(bool enable) async {
    if (enable) {
      final status = await Permission.photos.request();
      await Permission.camera.request();
      setState(() {
        _photos = status.isGranted;
      });
    } else {
      setState(() {
        _photos = false;
      });
    }
  }

  Future<void> _requestContacts(bool enable) async {
    if (enable) {
      final status = await Permission.contacts.request();
      setState(() {
        _contacts = status.isGranted;
      });
    } else {
      setState(() {
        _contacts = false;
      });
    }
  }

  Future<void> _requestNotifications(bool enable) async {
    if (enable) {
      final status = await Permission.notification.request();
      setState(() {
        _notifications = status.isGranted;
      });
    } else {
      setState(() {
        _notifications = false;
      });
    }
  }

  void _continue() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }

  Widget _buildPermissionTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool?> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppTheme.lightLavender,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryPurple, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppTheme.primaryPurple,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.security, size: 60, color: AppTheme.primaryPurple),
              const SizedBox(height: 24),
              Text(
                'Unlock Froofly Details',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'To get the best experience, including personalized deal distances and notifications, please allow access:',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textGrey,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildPermissionTile(
                        'Location',
                        'To find nearby deals and challenges',
                        Icons.location_on,
                        _location,
                        (val) => _requestLocation(val!),
                      ),
                      _buildPermissionTile(
                        'Photos & Videos',
                        'To upload your challenge proofs',
                        Icons.photo_library,
                        _photos,
                        (val) => _requestPhotos(val!),
                      ),
                      _buildPermissionTile(
                        'Contacts',
                        'To share deals and invite friends',
                        Icons.contacts,
                        _contacts,
                        (val) => _requestContacts(val!),
                      ),
                      _buildPermissionTile(
                        'Notifications',
                        'To stay updated on new flash deals',
                        Icons.notifications,
                        _notifications,
                        (val) => _requestNotifications(val!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
