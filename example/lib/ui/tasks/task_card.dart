import 'package:example/data/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supa_manager/supa_manager.dart';

import '../../data/models/tasks.dart';
import '../utils.dart';

typedef OnChanged = void Function(Task);
typedef OnDeleted = void Function(Task);

// ignore: must_be_immutable
class TaskCard extends ConsumerStatefulWidget {
  Task task;
  final OnChanged? onChanged;
  final OnDeleted? onDeleted;

  TaskCard({super.key, required this.task, this.onChanged, this.onDeleted});

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
      color: cardBackgroundColor,
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.task.name, style: largeBlackText),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: widget.task.done,
                            onChanged: (changed) async {
                              setState(() {
                                widget.task = widget.task.copyWith(
                                  done: !(true == widget.task.done),
                                  doLater: false,
                                );
                              });
                              updateTask(widget.task, repository);
                            },
                          ),
                          const Text('Done'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: widget.task.doLater,
                            onChanged: (changed) async {
                              setState(() {
                                widget.task = widget.task.copyWith(
                                  doLater: !(true == widget.task.doLater),
                                  done: false,
                                );
                              });
                              updateTask(widget.task, repository);
                            },
                          ),
                          const Text('Do Later'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                await repository.deleteTask(widget.task);
                widget.onDeleted?.call(widget.task);
              },
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void updateTask(Task task, Repository repository) async {
    final result = await repository.updateTask(task);
    switch (result) {
      case Success(data: final updatedTask):
        widget.task = updatedTask!;
      case Failure(error: final error):
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      case ErrorMessage(message: final message, code: _):
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? 'Problems getting data')),
        );
    }
    widget.onChanged?.call(task);
  }
}
