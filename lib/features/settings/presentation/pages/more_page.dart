import 'package:flutter/material.dart';
import '../../../../core/widgets/index.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import 'settings_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                const SizedBox(height: 20),
                HeaderSection(
                  userName: 'Allyn Ralf Ledesma',
                  hasNotification: true,
                  onProfileTap: () {
                    // TODO: Navigate to profile page
                  },
                  onNotificationTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 29),

                // Menu Grid - 2 columns, 3 rows (centered)
                Center(
                  child: Wrap(
                    spacing: 18, // Horizontal spacing between cards
                    runSpacing: 14, // Vertical spacing between rows
                    alignment: WrapAlignment.center,
                    children: [
                      // Row 1
                      MenuCard(
                        data: MenuCardData(
                          title: 'Profile',
                          subtitle: 'Name, Basic Details',
                          icon: Icons.person_outline,
                          onTap: () {
                            // TODO: Navigate to Profile
                            print('Profile tapped');
                          },
                        ),
                      ),
                      MenuCard(
                        data: MenuCardData(
                          title: 'Appearance',
                          subtitle: 'Widgets, Themes',
                          icon: Icons.palette_outlined,
                          onTap: () {
                            // TODO: Navigate to Appearance
                            print('Appearance tapped');
                          },
                        ),
                      ),

                      // Row 2
                      MenuCard(
                        data: MenuCardData(
                          title: 'General',
                          subtitle: 'Currency, clear data\nand more',
                          icon: Icons.more_horiz,
                          onTap: () {
                            // TODO: Navigate to General
                            print('General tapped');
                          },
                        ),
                      ),
                      MenuCard(
                        data: MenuCardData(
                          title: 'Settings',
                          subtitle: 'Account settings,\nalerts & notifications',
                          icon: Icons.settings_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsPage(),
                              ),
                            );
                          },
                        ),
                      ),

                      // Row 3
                      MenuCard(
                        data: MenuCardData(
                          title: 'Data',
                          subtitle:
                              'Data management,\nexport and import\nfeatures',
                          icon: Icons.insert_chart_outlined,
                          onTap: () {
                            // TODO: Navigate to Data
                            print('Data tapped');
                          },
                        ),
                      ),
                      MenuCard(
                        data: MenuCardData(
                          title: 'Privacy',
                          subtitle: 'Privacy preferences',
                          icon: Icons.lock_outline,
                          onTap: () {
                            // TODO: Navigate to Privacy
                            print('Privacy tapped');
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
