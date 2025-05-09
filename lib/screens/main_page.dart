import 'package:flutter/material.dart';
import 'package:proyecto_aa/screens/fav_page.dart';
import 'package:proyecto_aa/screens/home_page.dart';
import 'package:proyecto_aa/screens/search_page.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selected = 0;

  final List<Widget> pages = const [
    HomePage(),
    SearchPage(),
    FavPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selected,
        children: pages,
      ),
      bottomNavigationBar: StylishBottomBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        option: DotBarOptions(
          dotStyle: DotStyle.tile,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.tertiary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        items: [
          BottomBarItem(
            icon: const Icon(Icons.house_rounded),
            title: const Text('Inicio'),
          ),
          BottomBarItem(
            icon: const Icon(Icons.search_rounded),
            title: const Text('Buscar'),
            selectedIcon: const Icon(Icons.saved_search_rounded),
          ),
          BottomBarItem(
            icon: const Icon(Icons.favorite_outline_rounded),
            title: const Text('Favoritos'),
            selectedIcon: const Icon(Icons.favorite_rounded),
          ),
        ],
        currentIndex: selected,
        onTap: (index) {
          setState(() {
            selected = index;
            //controller.jumpToPage(index);
          });
        },
      ),
    );
  }
}
