import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/data/purchase.order/purchase.order.service.dart';
import 'package:inventory_frontend/domain/purchase.order/entities.dart';
import 'package:inventory_frontend/view/common.widgets/async_value_widget.dart';
import 'package:inventory_frontend/view/purchase.order/purchase.order.list.controller.dart';

final purchaseOrderProvider = FutureProvider.family<PurchaseOrder, String>((ref, id) async {
  final saleOrderOrError = await ref.watch(purchaseOrderServiceProvider).getPurchaseOrder(purchaseOrderId: id);
  if (saleOrderOrError.isLeft()) {
    throw AssertionError("cannot item");
  }
  return saleOrderOrError.toIterable().first;
});

enum PurchaseOrderAction {
  delivered,
  delete,
}

class PurchaseOrderScreen extends ConsumerWidget {
  const PurchaseOrderScreen({super.key, required this.isToSelectItemVariation, required this.pruchaseOrderId});

  final String pruchaseOrderId;
  final bool isToSelectItemVariation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleOrderAsync = ref.watch(purchaseOrderProvider(pruchaseOrderId));
    return ScaffoldAsyncValueWidget<PurchaseOrder>(
      value: saleOrderAsync,
      data: (job) => PageContents(po: job),
    );
  }
}

class PageContents extends ConsumerWidget {
  const PageContents({super.key, required this.po});
  final PurchaseOrder po;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popupMenuItems = po.orderStatus == PurchaseOrderStatus.issued
        ? [
            const PopupMenuItem(
              value: PurchaseOrderAction.delivered,
              child: Text('Convert to Received'),
            ),
            const PopupMenuItem(
              value: PurchaseOrderAction.delete,
              child: Text('Delete'),
            ),
          ]
        : [
            const PopupMenuItem(
              value: PurchaseOrderAction.delete,
              child: Text('Delete'),
            ),
          ];

    return Scaffold(
        appBar: AppBar(
          title: Text(po.purchaseOrderNumber!),
          actions: [
            PopupMenuButton<PurchaseOrderAction>(
                onSelected: (PurchaseOrderAction value) async {
                  switch (value) {
                    case PurchaseOrderAction.delivered:
                      //TODO need to get a date from users
                      final now = DateTime.now();
                      final isSuccess =
                          await ref.read(purchaseOrderListControllerProvider.notifier).convertToReceived(po, now);
                      if (isSuccess) {
                        ref.invalidate(purchaseOrderProvider(po.id!));
                      }
                    case PurchaseOrderAction.delete:
                    // TODO: Handle this case.
                  }
                },
                itemBuilder: (BuildContext context) => popupMenuItems)
          ],
        ),
        body: Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    const Text("Total Amount"),
                    Text("${po.currencyCodeEnum.name} ${po.totalInDouble}"),
                  ],
                ),
                const Spacer(),
                Text(po.status.toUpperCase())
              ],
            ),
            Expanded(child: _getListView(po.lineItems))
          ],
        ));
  }

  ListView _getListView(List<LineItem> lineItems) {
    return ListView(
      children: lineItems
          .map((e) => ListTile(
                title: Text(e.itemVariation.name),
                subtitle:
                    Row(children: [Text(e.quantity.toString()), const Text(" X "), Text(e.rateInDouble.toString())]),
                // onTap: () {},
              ))
          .toList(),
    );
  }
}
