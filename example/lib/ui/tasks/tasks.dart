import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/tasks.dart';
import '../../data/repository.dart';
import '../dialog/new_item.dart';
import '../utils.dart';
import 'task_card.dart';

class Tasks extends ConsumerStatefulWidget {
  const Tasks({Key? key}) : super(key: key);

  @override
  ConsumerState<Tasks> createState() => _TasksState();
}

class _TasksState extends ConsumerState<Tasks> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Stack(
        children: [
          getTasks(),
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton(
              backgroundColor: startGradientColor,
              child: const Icon(
                Icons.add,
                color: Colors.black,
              ),
              onPressed: () {
                showNewDialog('New Task', (String? name) async {
                  if (name != null) {
                    await addTask(name);
                    // setState(() {
                    // });
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future addTask(String name) async {
    final repository = ref.read(repositoryProvider);
    await repository.addTask(Task(name: name));
  }


  void showNewDialog(String title, NameCallBack callBack) {
    showDialog(
      context: context,
      builder: (context) => NewItemDialog(
        title: title,
        callBack: callBack,
      ),
    );
  }

  Widget getTasks() {
    final repository = ref.watch(repositoryProvider);

    return FutureBuilder<List<Task>>(
      future: repository.getTodaysTasks(),
      builder: (context, AsyncSnapshot<List<Task>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final tasks = snapshot.data!;
          return AnimatedList(
            key: _listKey,
            initialItemCount: tasks.length,
            itemBuilder: (BuildContext context, int index, animation) {
              return TaskCard(
                key: ValueKey(tasks[index].id),
                task: tasks[index],
                onChanged: () {
                  // setState(() {});
                },
              );
            },
          );
        } else {
          return Container();
        }
      },
    );
  }
}
