import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/tasks_notifier.dart';
import '../tasks/task_card.dart';

class Done extends ConsumerStatefulWidget {
  const Done({Key? key}) : super(key: key);

  @override
  ConsumerState<Done> createState() => _DoneState();
}

class _DoneState extends ConsumerState<Done> {

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
    final doneTasks = taskNotifier.filterDoneTasks(tasks);
    return ListView.builder(
      itemCount: doneTasks.length,
      itemBuilder: (BuildContext context, int index) {
        return TaskCard(
          key: ValueKey(doneTasks[index].id),
          task: doneTasks[index],
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
