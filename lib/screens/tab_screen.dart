import 'package:flutter/material.dart';
import 'package:music_player/screens/download_screen.dart';
import 'package:music_player/screens/home_screen.dart';
import 'package:music_player/screens/search_screen.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({super.key});
  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> bodyWidgets = [const HomeScreen(), const DownloadScreen()];
    return Scaffold(
      appBar: appBar(context),
      body: bodyWidgets[_selectedIndex],
      bottomNavigationBar: navigationBar(),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: Text(
        "MPX",
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: [
        IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchScreen()));
            },
            icon: const Icon(Icons.search))
      ],
    );
  }

  BottomNavigationBar navigationBar() {
    return BottomNavigationBar(
      elevation: 3,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.download),
          label: 'Download',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.red,
      onTap: _onItemTapped,
    );
  }
}
