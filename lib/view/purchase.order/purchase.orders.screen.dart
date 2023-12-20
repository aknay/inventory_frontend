import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/view/main/drawer.dart';
import 'package:inventory_frontend/view/purchase.order/purchase.order.list.view.dart';

class PurchaseOrdersScreen extends ConsumerWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(title: const Text("Purchase Orders")),
      body: const PurchaseOrderListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // context.goNamed(AppRoute.addSaleOrder.name);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
