import 'package:flutter/material.dart';
import 'package:reloc/views/home/community_screen.dart';
import 'package:reloc/views/home/movers_screen.dart';
import 'package:reloc/views/home/residents_screen.dart';
import 'package:reloc/views/home/profile_screen.dart';
import 'package:reloc/views/home/post_as_screen.dart';
import 'package:reloc/views/shared/notifications_screen.dart';
import 'package:reloc/core/constants/app_colors.dart' as core_colors;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // 👈 Added focus node
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;
  late Animation<double> _fadeAnimation;

  final List<Widget> _tabs = const [
    CommunityScreen(),
    MoversScreen(),
    ResidentsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Collapse search bar if focus is lost
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && _isSearching) {
        _toggleSearch();
      }
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCommunity() {
    setState(() => _currentIndex = 0);
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });

    if (_isSearching) {
      _searchAnimationController.forward();
      _searchFocusNode.requestFocus();
    } else {
      _searchAnimationController.reverse();
      _searchController.clear();
      _searchFocusNode.unfocus();
    }
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
          toolbarHeight: 48.0,
          title: AnimatedBuilder(
            animation: _searchAnimationController,
            builder: (context, child) {
              return _isSearching
                  ? _buildSearchField()
                  : _buildHeaderContent();
            },
          ),
          actions: _isSearching
              ? [
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: _toggleSearch,
                        ),
                      );
                    },
                  )
                ]
              : null,
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
              label: 'Community',
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
                  padding:
                      const EdgeInsets.only(bottom: 16, right: 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PostAsScreen()),
                      );
                    },
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text(
                      'Post As',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: core_colors.AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              )
            : null,
        floatingActionButtonLocation:
            FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Row(
      children: [
        GestureDetector(
          onTap: _navigateToCommunity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/Appicons/logo.png',
                height: 35,
                width: 35,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const Spacer(),
        _buildProfessionalSearchButton(),
        const SizedBox(width: 6),
        _buildNotificationButton(),
        const SizedBox(width: 6),
        _buildProfileButton(),
      ],
    );
  }

  Widget _buildProfessionalSearchButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            core_colors.AppColors.primary.withOpacity(0.1),
            core_colors.AppColors.primary.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: core_colors.AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: core_colors.AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
      child: InkWell(
        onTap: _toggleSearch,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search,
                color: core_colors.AppColors.primary,
                size: 18,
              ),
              SizedBox(width: 4),
              Text(
                'Search',
                style: TextStyle(
                  color: core_colors.AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const NotificationsScreen()),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Stack(
              children: [
                const Icon(
                  Icons.notifications_none,
                  color: core_colors.AppColors.primary,
                  size: 18,
                ),
                // Notification badge
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _currentIndex = 3); // Navigate to Profile tab
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: const Icon(
              Icons.person_outline,
              color: core_colors.AppColors.primary,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return FadeTransition(
      opacity: _searchAnimation,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: core_colors.AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode, // 👈 focus handled
          autofocus: true,
          cursorColor: core_colors.AppColors.primary,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: "Search posts, users, or topics...",
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: core_colors.AppColors.primary,
              size: 20,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear,
                        color: Colors.white70, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onChanged: (query) {
            setState(() {}); // refresh clear button
            debugPrint("Searching for: $query"); // hook with backend later
          },
          onSubmitted: (query) {
            debugPrint("Search submitted: $query");
          },
        ),
      ),
    );
  }
}
