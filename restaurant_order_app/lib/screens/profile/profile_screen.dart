import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/common/gradient_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock user data - in real app this would come from a bloc/provider
    final userData = {
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'phone': '+1 234 567 8900',
      'memberSince': 'November 2023',
      'ordersCount': '12',
    };

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Profile Header with Gradient
          SliverToBoxAdapter(
            child: GradientHeader(
              title: 'My Profile',
              leftIcon: Icons.arrow_back,
              rightIcon: Icons.settings,
              onLeftIconPressed: () => context.go('/home'),
              onRightIconPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon')),
                );
              },
              bottomChild: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // User Info
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: 80),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    userData['name'] ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData['email'] ?? 'email@example.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (userData['phone'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        userData['phone']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Stats cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        context: context,
                        icon: Icons.receipt_long,
                        title: 'Orders',
                        value: userData['ordersCount'] ?? '0',
                      ),
                      _buildStatCard(
                        context: context,
                        icon: Icons.calendar_today,
                        title: 'Member Since',
                        value: userData['memberSince'] ?? 'New',
                        isTextValue: true,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Section
                  _buildSectionHeader(context, title: 'Account'),
                  const SizedBox(height: 16),
                  _buildSettingsItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Change your personal information',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit Profile coming soon')),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.location_on_outlined,
                    title: 'Saved Addresses',
                    subtitle: 'Manage your delivery addresses',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved Addresses coming soon')),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.credit_card_outlined,
                    title: 'Payment Methods',
                    subtitle: 'Manage your payment options',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Payment Methods coming soon')),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Orders & Favorites Section
                  _buildSectionHeader(context, title: 'My Activity'),
                  const SizedBox(height: 16),
                  _buildSettingsItem(
                    context,
                    icon: Icons.receipt_long_outlined,
                    title: 'Order History',
                    subtitle: 'View your past orders',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order History coming soon')),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.favorite_border_outlined,
                    title: 'Favorite Restaurants',
                    subtitle: 'View your saved restaurants',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Favorites coming soon')),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Preferences Section
                  _buildSectionHeader(context, title: 'Preferences'),
                  const SizedBox(height: 16),
                  _buildSettingsItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage your notification settings',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications coming soon')),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.language_outlined,
                    title: 'Language',
                    subtitle: 'Change app language',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Language settings coming soon')),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Support Section
                  _buildSectionHeader(context, title: 'Support'),
                  const SizedBox(height: 16),
                  _buildSettingsItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    subtitle: 'Get help with your orders',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help Center coming soon')),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'About Us',
                    subtitle: 'Learn more about our restaurant',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('About Us coming soon')),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Logout button
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Log Out'),
                      onPressed: () {
                        // Show logout confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Log Out'),
                            content: const Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // In a real app, dispatch logout action to auth bloc
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Logged out successfully')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Log Out'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    bool isTextValue = false,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            color: AppTheme.primaryColor,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isTextValue ? 14 : 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.primaryColor,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
} 