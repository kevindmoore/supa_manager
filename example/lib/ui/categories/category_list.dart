import 'dart:developer';

import 'package:example/data/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supa_manager/supa_manager.dart';

import '../../data/models/categories.dart';
import '../dialog/new_item.dart';
import '../utils.dart';

class Categories extends ConsumerStatefulWidget {
  const Categories({super.key});

  @override
  ConsumerState<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends ConsumerState<Categories> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: appBackgroundColor),
      child: Stack(
        children: [
          getCategories(),
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton(
              heroTag: UniqueKey(),
              key: UniqueKey(),
              backgroundColor: actionColor,
              child: const Icon(Icons.add, color: Colors.black),
              onPressed: () {
                showNewDialog('New Category', (String? name) async {
                  if (name != null) {
                    await ref
                        .read(repositoryProvider)
                        .addCategory(Category(name: name));
                    setState(() {});
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void showNewDialog(String title, NameCallBack callBack) {
    showDialog(
      context: context,
      builder: (context) => NewItemDialog(title: title, callBack: callBack),
    );
  }

  Widget getCategories() {
    return FutureBuilder<List<Category>>(
      future: getCategoryData(),
      builder: (context, AsyncSnapshot<List<Category>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final categories = snapshot.data ?? <Category>[];
        if (categories.isEmpty) {
          return const Center(child: Text('No categories yet'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: categories.length,
          itemBuilder: (BuildContext context, int index) {
            return buildCategoryRow(categories[index]);
          },
        );
      },
    );
  }

  Future<List<Category>> getCategoryData() async {
    final repository = ref.watch(repositoryProvider);
    final result = await repository.readAllCategories();
    switch (result) {
      case Success(data: final data):
        return data;
      case Failure(error: final error):
        log('Problems getting categories', error: error);
        if (!mounted) return <Category>[];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      case ErrorMessage(message: final message, code: _):
        log('Problems getting categories: $message');
        if (!mounted) return <Category>[];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? 'Problems getting data')),
        );
    }
    return <Category>[];
  }

  Widget buildCategoryRow(Category category) {
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
          children: [
            Expanded(child: Text(category.name, style: largeBlackText)),
            IconButton(
              onPressed: () async {
                await repository.deleteCategory(category);
                setState(() {});
              },
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
