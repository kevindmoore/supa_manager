import 'package:example/data/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/categories.dart';
import '../dialog/new_item.dart';
import '../utils.dart';

class Categories extends ConsumerStatefulWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  ConsumerState<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends ConsumerState<Categories> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Stack(
        children: [
          getCategories(),
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
      builder: (context) => NewItemDialog(
        title: title,
        callBack: callBack,
      ),
    );
  }

  Widget getCategories() {
    return FutureBuilder<List<Category>>(
      future: getCategoryData(),
      builder: (context, AsyncSnapshot<List<Category>> snapshot) {
        final categories = snapshot.data ?? <Category>[];
        return ListView.builder(
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
    result.when(
        success: (data) {
          return data;
        },
        failure: (Exception error) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.toString())));
        },
        errorMessage: (int code, String? message) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message ?? 'Problems getting data')));
        });
    return <Category>[];
  }

  Widget buildCategoryRow(Category category) {
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
            Text(
              category.name,
              style: largeWhiteText,
            ),
            const Spacer(),
            IconButton(
                onPressed: () async {
                  await repository.deleteCategory(category);
                  setState(() {});
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
}
