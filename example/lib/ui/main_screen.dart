import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import 'categories/category_list.dart';
import 'dolater/do_later.dart';
import 'done/done.dart';
import 'tasks/tasks.dart';
import 'utils.dart';

const tasks = 'Tasks';
const done = 'Done';
const doLater = 'Do Later';
const categories = 'Categories';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  List<Widget> pageList = <Widget>[];

  @override
  void initState() {
    super.initState();
    pageList.add(const Tasks());
    pageList.add(const Done());
    pageList.add(const DoLater());
    pageList.add(const Categories());
  }

  @override
  Widget build(BuildContext context) {
    String title;
    switch (_selectedIndex) {
      case 0:
        title = tasks;
        break;
      case 1:
        title = done;
        break;
      case 2:
        title = doLater;
        break;
      default:
        title = categories;
        break;
    }
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: endGradientColor,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xFFBFDDF6),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: tasks),
          BottomNavigationBarItem(icon: Icon(Icons.done), label: done),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_late),
            label: doLater,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: categories,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      appBar: getAppBar(title),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: IndexedStack(index: _selectedIndex, children: pageList),
      ),
    );
  }

  PreferredSizeWidget? getAppBar(String title) {
    // if (kIsWeb || Platform.isWindows || Platform.isMacOS) {
    //   return null;
    // }
    return AppBar(
      elevation: 0,
      backgroundColor: endGradientColor,
      foregroundColor: Colors.white,
      actions: [
        TextButton(
          onPressed: () async {
            final auth = getSupaAuthManager(ref);
            auth.logout();
          },
          child: const Text('Log Out', style: TextStyle(color: Colors.white)),
        ),
      ],
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
    );
  }
}
