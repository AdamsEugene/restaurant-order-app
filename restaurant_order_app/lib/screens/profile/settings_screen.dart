import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mock settings state
  bool _notificationsEnabled = true;
  bool _emailUpdates = true;
  bool _locationServices = true;
  bool _darkMode = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('App Preferences'),
            _buildSettingsSection([
              _buildSwitchTile(
                title: 'Dark Mode', 
                value: _darkMode,
                icon: Icons.dark_mode_outlined,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                  // In a real app, would trigger theme change
                },
              ),
              _buildDropdownTile(
                title: 'Language',
                value: _selectedLanguage,
                icon: Icons.language_outlined,
                options: const ['English', 'Spanish', 'French', 'German', 'Chinese'],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLanguage = value;
                    });
                  }
                },
              ),
              _buildDropdownTile(
                title: 'Currency',
                value: _selectedCurrency,
                icon: Icons.currency_exchange_outlined,
                options: const ['USD', 'EUR', 'GBP', 'JPY', 'CAD'],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCurrency = value;
                    });
                  }
                },
              ),
            ]),
            
            _buildSectionHeader('Notifications'),
            _buildSettingsSection([
              _buildSwitchTile(
                title: 'Push Notifications', 
                value: _notificationsEnabled,
                icon: Icons.notifications_outlined,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              _buildSwitchTile(
                title: 'Email Updates', 
                value: _emailUpdates,
                icon: Icons.email_outlined,
                onChanged: (value) {
                  setState(() {
                    _emailUpdates = value;
                  });
                },
              ),
            ]),
            
            _buildSectionHeader('Privacy'),
            _buildSettingsSection([
              _buildSwitchTile(
                title: 'Location Services', 
                value: _locationServices,
                icon: Icons.location_on_outlined,
                onChanged: (value) {
                  setState(() {
                    _locationServices = value;
                  });
                },
              ),
              _buildTile(
                title: 'Privacy Policy',
                icon: Icons.privacy_tip_outlined,
                onTap: () {
                  Navigator.pushNamed(context, '/privacy-policy');
                },
              ),
              _buildTile(
                title: 'Terms of Service',
                icon: Icons.description_outlined,
                onTap: () {
                  Navigator.pushNamed(context, '/terms');
                },
              ),
              _buildTile(
                title: 'Data Management',
                icon: Icons.storage_outlined,
                onTap: () {
                  _showDataManagementDialog();
                },
              ),
            ]),
            
            _buildSectionHeader('Support'),
            _buildSettingsSection([
              _buildTile(
                title: 'Help Center',
                icon: Icons.help_outline,
                onTap: () {
                  Navigator.pushNamed(context, '/help');
                },
              ),
              _buildTile(
                title: 'Contact Us',
                icon: Icons.headset_mic_outlined,
                onTap: () {
                  Navigator.pushNamed(context, '/contact');
                },
              ),
              _buildTile(
                title: 'Report an Issue',
                icon: Icons.report_problem_outlined,
                onTap: () {
                  Navigator.pushNamed(context, '/report-issue');
                },
              ),
            ]),
            
            _buildSectionHeader('About'),
            _buildSettingsSection([
              _buildTile(
                title: 'App Version',
                icon: Icons.info_outline,
                trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
                onTap: () {
                  // Show version details
                },
              ),
              _buildTile(
                title: 'Rate the App',
                icon: Icons.star_outline,
                onTap: () {
                  // Open app store
                },
              ),
            ]),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildSettingsSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildTile({
    required String title,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(title),
      trailing: Switch(
        value: value,
        activeColor: AppTheme.primaryColor,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required IconData icon,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        style: TextStyle(color: Colors.grey.shade800),
        onChanged: onChanged,
        items: options.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  void _showDataManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataManagementOption(
              'Clear Search History',
              Icons.history,
              () {
                Navigator.pop(context);
                _showActionConfirmDialog(
                  'Clear Search History',
                  'Are you sure you want to clear your search history?',
                );
              },
            ),
            _buildDataManagementOption(
              'Clear Cache',
              Icons.cached,
              () {
                Navigator.pop(context);
                _showActionConfirmDialog(
                  'Clear Cache',
                  'Are you sure you want to clear the app cache?',
                );
              },
            ),
            _buildDataManagementOption(
              'Download My Data',
              Icons.download,
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your data request is being processed'),
                  ),
                );
              },
            ),
            _buildDataManagementOption(
              'Delete Account',
              Icons.delete_forever,
              () {
                Navigator.pop(context);
                _showActionConfirmDialog(
                  'Delete Account',
                  'Are you sure you want to delete your account? This action cannot be undone.',
                  isDestructive: true,
                );
              },
              isDestructive: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementOption(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppTheme.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showActionConfirmDialog(
    String title,
    String message, {
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? Colors.red : null,
            ),
            onPressed: () {
              Navigator.pop(context);
              // Perform action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title completed'),
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
} 