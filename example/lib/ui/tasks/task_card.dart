import 'package:example/data/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/tasks.dart';
import '../utils.dart';

typedef OnChanged = void Function(Task);
typedef OnDeleted = void Function(Task);

// ignore: must_be_immutable
class TaskCard extends ConsumerStatefulWidget {
  Task task;
  final OnChanged? onChanged;
  final OnDeleted? onDeleted;

  TaskCard({super.key, required this.task, this.onChanged, this.onDeleted, });

  @override
  ConsumerState createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return buildRow();
  }

  Widget buildRow() {
    final repository = ref.watch(repositoryProvider);
    return Card(
      color: startGradientColor,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.task.name,
                  style: largeBlackText,
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: widget.task.done,
                      onChanged: (changed) async {
                        setState(
                          () {
                            widget.task = widget.task.copyWith(
                                done: !(true == widget.task.done),
                                doLater: false);
                          },
                        );
                        updateTask(widget.task, repository);
                      },
                    ),
                    const Text('Done'),
                    const SizedBox(
                      width: 8,
                    ),
                    Checkbox(
                      value: widget.task.doLater,
                      onChanged: (changed) async {
                        setState(
                          () {
                            widget.task = widget.task.copyWith(
                                doLater: !(true == widget.task.doLater),
                                done: false);
                          },
                        );
                        updateTask(widget.task, repository);
                      },
                    ),
                    const Text('Do Later'),
                    const SizedBox(
                      width: 8,
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            IconButton(
                onPressed: () async {
                  await repository.deleteTask(widget.task);
                  widget.onDeleted?.call(widget.task);
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                )),
          ],
        ),
      ),
    );
  }

  void updateTask(Task task, Repository repository) async {
    final result = await repository.updateTask(task);
    result.when(
        success: (updatedTask) => widget.task = updatedTask,
        failure: (Exception error) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.toString())));
        },
        errorMessage: (int code, String? message) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message ?? 'Problems Updating Task')));
        });
    widget.onChanged?.call(task);
  }
}
