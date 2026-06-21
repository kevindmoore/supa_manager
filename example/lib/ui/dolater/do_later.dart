import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/tasks_notifier.dart';
import '../tasks/task_card.dart';
import '../utils.dart';

class DoLater extends ConsumerStatefulWidget {
  const DoLater({super.key});

  @override
  ConsumerState<DoLater> createState() => _DoLaterState();
}

class _DoLaterState extends ConsumerState<DoLater> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: appBackgroundColor),
      child: getTasks(),
    );
  }

  Widget getTasks() {
    final tasks = ref.watch(taskNotifierProvider);
    final taskNotifier = ref.read(taskNotifierProvider.notifier);
    final doLaterTasks = taskNotifier.filterDoLaterTasks(tasks);
    if (doLaterTasks.isEmpty) {
      return const Center(child: Text('No do later tasks yet'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: doLaterTasks.length,
      itemBuilder: (BuildContext context, int index) {
        return TaskCard(
          key: ValueKey(doLaterTasks[index].id),
          task: doLaterTasks[index],
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
