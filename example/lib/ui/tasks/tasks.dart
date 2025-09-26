import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supa_manager/supa_manager.dart';

import '../../data/models/tasks.dart';
import '../../data/repository.dart';
import '../../data/tasks_notifier.dart';
import '../dialog/new_item.dart';
import '../utils.dart';
import 'task_card.dart';

class Tasks extends ConsumerStatefulWidget {
  const Tasks({super.key});

  @override
  ConsumerState<Tasks> createState() => _TasksState();
}

class _TasksState extends ConsumerState<Tasks> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    ref.read(taskNotifierProvider.notifier).initialize();
  }

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
              heroTag: UniqueKey(),
              key: UniqueKey(),
              backgroundColor: startGradientColor,
              child: const Icon(
                Icons.add,
                color: Colors.black,
              ),
              onPressed: () {
                showNewDialog('New Task', (String? name) async {
                  if (name != null) {
                    final task = await addTask(name);
                    if (task != null) {
                      setState(() {
                        ref.read(taskNotifierProvider.notifier).addTask(task);
                      });
                    }
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Task?> addTask(String name) async {
    final repository = ref.read(repositoryProvider);
    final result =
        await repository.addTask(Task(name: name, done: false, doLater: false));
    switch (result) {
      case Success(data: final task):
        ref.read(taskNotifierProvider.notifier).addTask(task!);
        return task;
      case Failure(error: final error):
        debugPrint('addTask: $error');
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.toString())));
        }
      case ErrorMessage(message: final message, code: _):
        debugPrint('addTask: $message');
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
              SnackBar(content: Text(message ?? 'Problems getting data')));
        }
    }
    return null;
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
    // log('getTasks: _currentTasks.length = ${_currentTasks.length}');
    final tasks = ref.watch(taskNotifierProvider);
    final taskNotifier = ref.read(taskNotifierProvider.notifier);
    final todaysTasks = taskNotifier.filterTodayTasks(tasks);
    return ListView.builder(
      key: _listKey,
      itemCount: todaysTasks.length,
      itemBuilder: (BuildContext context, int index) {
        return TaskCard(
          key: ValueKey(todaysTasks[index].id),
          task: todaysTasks[index],
          onChanged: (task) {
            setState(() {
              taskNotifier.replaceTask(task);
            });
          },
          onDeleted: (task) {
            setState(() {});
            taskNotifier.removeTask(task);
          },
        );
      },
    );
  }
}
