import 'package:flutter/material.dart';
import 'package:reloc/views/home/community_screen.dart';
import 'package:reloc/views/home/movers_screen.dart';
import 'package:reloc/views/home/residents_screen.dart';
import 'package:reloc/views/home/profile_screen.dart';
import 'package:reloc/views/home/post_as_screen.dart'; // ✅ Added import
import 'package:reloc/views/shared/notification.dart';
import 'package:reloc/core/constants/app_colors.dart' as core_colors;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    CommunityScreen(), // Community = Home Feed
    MoversScreen(),
    ResidentsScreen(),
    ProfileScreen(),
  ];

  void _navigateToCommunity() {
    setState(() => _currentIndex = 0);
  }

  Future<bool> _onWillPop() async => false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: core_colors.AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: core_colors.AppColors.navBar,
          elevation: 0,
          title: Row(
            children: [
              GestureDetector(
                onTap: _navigateToCommunity,
                child: ClipOval(
                  child: Image.asset(
                    'assets/Appicons/logo.png',
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.search, color: core_colors.AppColors.primary),
                onPressed: () {
                  // TODO: Implement SearchScreen or remove this button if not needed
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (_) => const SearchScreen()),
                  // );
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: core_colors.AppColors.primary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        body: _tabs[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: core_colors.AppColors.navBar,
          selectedItemColor: core_colors.AppColors.primary,
          unselectedItemColor: Colors.white60,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Community', // This is your home screen
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              label: 'Movers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.apartment_outlined),
              label: 'Residents',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
        floatingActionButton: _currentIndex == 0
            ? Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16, right: 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PostAsScreen()),
                      );
                    },
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text(
                      'Post As',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: core_colors.AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
