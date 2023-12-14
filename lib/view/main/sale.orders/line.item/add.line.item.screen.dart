import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';

class AddLineItemScreen extends ConsumerStatefulWidget {
  const AddLineItemScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddLineItemScreenState();
}

class _AddLineItemScreenState extends ConsumerState<AddLineItemScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Line Item")),
      body: Column(
        children: [TextButton(onPressed: () {

        context.goNamed(AppRoute.itemsSelection.name);


        }, child: Text("Select Item"))],
      ),
    );
  }
}
