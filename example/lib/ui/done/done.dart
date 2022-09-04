import 'package:example/data/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/tasks.dart';
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
    final repository = ref.watch(repositoryProvider);

    return FutureBuilder<List<Task>>(
      future: repository.getDoneTasks(),
      builder: (context, AsyncSnapshot<List<Task>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (BuildContext context, int index) {
              return TaskCard(
                key: ValueKey(tasks[index].id),
                task: tasks[index],
                onChanged: () {
                  // setState(
                  //       () {
                  //   },
                  // );
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