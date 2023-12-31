import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/view/items/item.list.view.dart';
import 'package:inventory_frontend/view/main/drawer.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';

class ItemsScreen extends ConsumerWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Items")),
      body: const ItemListView(isToSelectItemVariation: false),
      drawer: const DrawerWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.goNamed(AppRoute.addItem.name);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
