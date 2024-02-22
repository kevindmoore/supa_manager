
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/tasks_notifier.dart';
import '../tasks/task_card.dart';

class DoLater extends ConsumerStatefulWidget {
  const DoLater({super.key});

  @override
  ConsumerState<DoLater> createState() => _DoLaterState();
}

class _DoLaterState extends ConsumerState<DoLater> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: getTasks(),
    );
  }

  Widget getTasks() {
    final tasks = ref.watch(taskNotifierProvider);
    final taskNotifier = ref.read(taskNotifierProvider.notifier);
    final doLaterTasks = taskNotifier.filterDoLaterTasks(tasks);
    return ListView.builder(
      itemCount: doLaterTasks.length,
      itemBuilder: (BuildContext context, int index) {
        return TaskCard(
          key: ValueKey(doLaterTasks[index].id),
          task: doLaterTasks[index],
          onChanged: (task) {
            setState(
              () {
                taskNotifier.replaceTask(task);
              },
            );
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
