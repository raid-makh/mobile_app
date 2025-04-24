import "package:flutter/material.dart";

// 🔽 Shared Bottom Navigation Bar
Widget buildNavBar(BuildContext context, String currentRoute) {
  return BottomNavigationBar(
    currentIndex: _getSelectedIndex(currentRoute),
    onTap: (index) {
      String route;
      switch (index) {
        case 0:
          route = '/library';
          break;
        case 1:
          route = '/search';
          break;
        case 2:
          route = '/settings';
          break;
        default:
          return;
      }
      if (route != currentRoute) {
        Navigator.pushReplacementNamed(context, route);
      }
    },
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.grey,
    showUnselectedLabels: true,
    items: [
      BottomNavigationBarItem(
          icon: Icon(Icons.library_books), label: "Library"),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
    ],
  );
}

int _getSelectedIndex(String route) {
  switch (route) {
    case '/library':
      return 0;
    case '/search':
      return 1;
    case '/settings':
      return 2;
    default:
      return 0;
  }
}
