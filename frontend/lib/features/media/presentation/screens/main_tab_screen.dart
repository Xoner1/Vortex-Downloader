import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';

import 'home_screen.dart';
import 'library_screen.dart';
import 'downloads_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const LibraryScreen(),
    const DownloadsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Needed for floating transparent nav bar
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: BottomNavigationBar(
              backgroundColor: const Color(0xFF1C1C1E).withOpacity(0.7), // Glassmorphism
              selectedItemColor: const Color(0xFF0A84FF),
              unselectedItemColor: Colors.white54,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.search),
                  label: 'Discover',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.music_albums),
                  label: 'Library',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.cloud_download),
                  label: 'Downloads',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
