import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopify/models/product.dart';
import 'package:shopify/models/status_page.dart';
import 'package:shopify/providers/user_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/utils/formart_currency.dart';
import 'package:shopify/utils/navigation_helper.dart';
import 'package:shopify/widgets/status_page.dart';

class StatusTracking extends ConsumerStatefulWidget {
  const StatusTracking({super.key, required this.type});
  final String type;

  @override
  ConsumerState<StatusTracking> createState() => _StatusTrackingState();
}

class _StatusTrackingState extends ConsumerState<StatusTracking> {
  Widget _buildImage(String linkImage, double width) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        linkImage,
        width: width / 5,
        fit: BoxFit.fitWidth,
      ),
    );
  }

  Widget _buildProductItem(ProductInOrder product, double width) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildImage(product.linkImageMatch, width),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        product.color,
                        style: Theme.of(context).textTheme.bodySmall!,
                      ),
                      const Spacer(),
                      Text(
                        "x${product.purchaseQuantity}",
                        style: Theme.of(context).textTheme.bodySmall!,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final userId = ref.read(userData)["uid"];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("uid_order", isEqualTo: userId)
            .where("shipping_status", isEqualTo: widget.type)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const StatusPageWithOutScaffold(
              type: StatusPageEnum.loading,
              err: "",
            );
          } else if (snapshot.hasError) {
            return StatusPageWithOutScaffold(
              type: StatusPageEnum.error,
              err: snapshot.error.toString(),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const StatusPageWithOutScaffold(
              type: StatusPageEnum.noData,
              err: "",
            );
          }
          final allOrders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: allOrders.length,
            itemBuilder: (context, idx) {
              final orderData = allOrders[idx];
              final int total = allOrders[idx]["total_price"];
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("orders")
                    .doc(orderData.id)
                    .collection("product")
                    .snapshots(),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const StatusPageWithOutScaffold(
                      type: StatusPageEnum.loading,
                      err: "",
                    );
                  } else if (productSnapshot.hasError) {
                    return StatusPageWithOutScaffold(
                      type: StatusPageEnum.error,
                      err: productSnapshot.error.toString(),
                    );
                  } else if (!productSnapshot.hasData ||
                      productSnapshot.data!.docs.isEmpty) {
                    return const StatusPageWithOutScaffold(
                      type: StatusPageEnum.noData,
                      err: "",
                    );
                  }

                  final products = productSnapshot.data!.docs.map((doc) {
                    return ProductInOrder(
                      name: doc["name"],
                      color: doc["color"],
                      purchaseQuantity: doc["purchase_quantity"],
                      colorCode: doc["color_code"] is int
                          ? doc["color_code"]
                          : int.tryParse(doc["color_code"].toString()) ?? 0,
                      id: doc.id,
                      idProduct: doc["id_product"],
                      linkImageMatch: doc["link_img_match"],
                    );
                  }).toList();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 0.2,
                          color: Theme.of(context).colorScheme.secondary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: products.length,
                          itemBuilder: (context, index) =>
                              _buildProductItem(products[index], width),
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Text(
                              "Shipping status:",
                              style: Theme.of(context).textTheme.bodySmall!,
                            ),
                            const Spacer(),
                            Text(
                              widget.type,
                              style: Theme.of(context).textTheme.bodySmall!,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total:",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  "${formatCurrency(total)} đ",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                navigatorToDetailTracking(
                                    context, orderData.id);
                              },
                              child: Text(
                                "View Details",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
