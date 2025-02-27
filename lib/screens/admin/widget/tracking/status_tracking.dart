import 'package:flutter/material.dart';
import 'package:shopify/data/data_test.dart';
import 'package:shopify/models/product.dart';
import 'package:shopify/utils/formart_currency.dart';
import 'dart:math';

class StatusTracking extends StatefulWidget {
  const StatusTracking({super.key});
  @override
  State<StatusTracking> createState() => _StatusTrackingState();
}

class _StatusTrackingState extends State<StatusTracking> {
  List<Product> product = productTest.sublist(0, 4);

  Widget _buildImage(String linkImage, int sale, double width) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            linkImage,
            width: width / 5,
            fit: BoxFit.fitWidth,
          ),
        ),
        if (sale > 0)
          Positioned(
            top: width / 20,
            left: width / 25,
            child: Transform.rotate(
              angle: -pi / 4,
              child: Container(
                color: Theme.of(context).colorScheme.error,
                padding: const EdgeInsets.all(5),
                child: Text(
                  "$sale%",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.onTertiary),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductItem(Product product, double width) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildImage(product.linkImg[0], product.sale, width),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text("Cream", style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text(
                    "${formatCurrency(product.price)} đ",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              width: 0.2, color: Theme.of(context).colorScheme.secondary),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: product.length,
              itemBuilder: (context, index) =>
                  _buildProductItem(product[index], width),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Text(
                    "Total:",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text("39999", style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {},
                child: Text(
                  "View Details",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
