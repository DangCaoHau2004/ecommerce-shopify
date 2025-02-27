import 'package:flutter/material.dart';
import 'package:shopify/data/data_test.dart';
import 'package:shopify/models/product.dart';
import 'package:flutter/services.dart';

class DetailTrackingScreen extends StatefulWidget {
  const DetailTrackingScreen({super.key});
  @override
  State<DetailTrackingScreen> createState() => _DetailTrackingScreenState();
}

class _DetailTrackingScreenState extends State<DetailTrackingScreen> {
  final List<Product> product = productTest.sublist(0, 3);
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tracking Details",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            for (int i = 0; i < product.length; i++)
              Column(
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(height / 80),
                          child: Image.network(
                            product[i].linkImg[0],
                            height: height / 8,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product[i].name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              product[i].color[0],
                              style: Theme.of(context).textTheme.bodySmall!,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Text(
                                  "Id order:",
                                  style: Theme.of(context).textTheme.bodySmall!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "123456789",
                                  style: Theme.of(context).textTheme.bodySmall!,
                                  overflow: TextOverflow.clip,
                                ),
                                // copy
                                IconButton(
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: "your text"),
                                    );
                                  },
                                  icon: const Icon(Icons.copy),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            const SizedBox(
              height: 24,
            ),
            Row(
              children: [
                Text(
                  "Total:",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  "1000",
                  style: Theme.of(context).textTheme.bodySmall!,
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Text(
                  "Giao Hang Tiet Kiem:",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: "your text"),
                    );
                  },
                  icon: const Icon(Icons.copy),
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  "1000",
                  style: Theme.of(context).textTheme.bodySmall!,
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            const Divider(),
            const SizedBox(
              height: 24,
            ),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.orange,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "From to:",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Xã Phùng Xá Huyện Thạch Thất Thành Phố Hà Nội Việt Nam",
                        style: Theme.of(context).textTheme.bodySmall!,
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Icon(
                  Icons.local_shipping,
                  color: Colors.orange,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Send to:",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Xã Phùng Xá Huyện Thạch Thất Thành Phố Hà Nội Việt Nam",
                        style: Theme.of(context).textTheme.bodySmall!,
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Icon(
                  Icons.scale,
                  color: Colors.orange,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Weight:",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "30kg",
                        style: Theme.of(context).textTheme.bodySmall!,
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            const Divider(),
            const SizedBox(
              height: 24,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  color: Colors.orange,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Preparing The Order",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.clip,
                      ),
                      Text(
                        "Order is being prepared for delivery",
                        style: Theme.of(context).textTheme.bodySmall!,
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  color: Colors.orange,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Being Packaged",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.clip,
                      ),
                      Text(
                        "Waiting for the order to be sent to delivery service",
                        style: Theme.of(context).textTheme.bodySmall!,
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  color: Colors.orange,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Orders In Delivery",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.clip,
                      ),
                      Text(
                        "Order are being shipped to transit location",
                        style: Theme.of(context).textTheme.bodySmall!,
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  color: Colors.orange,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Towarts Destination",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.clip,
                      ),
                      Text(
                        "Order to destination address",
                        style: Theme.of(context).textTheme.bodySmall!,
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {},
          child: Text(
            "Cancel Order",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ),
    );
  }
}
