import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:shopify/data/data_test.dart';
import 'package:shopify/models/product.dart';
import 'package:shopify/utils/navigation_helper.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Product> product = productTest.sublist(0, 6);
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(
            "Notification",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          floating: true,
          pinned: false,
          actions: [
            IconButton(
              onPressed: () {
                navigatorToCart(context);
              },
              icon: const Icon(Icons.shopping_cart, color: Colors.orange),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.chat, color: Colors.orange),
            ),
          ],
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.8,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    borderRadius: BorderRadius.circular(width / 30),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(width / 30),
                        child: Image.network(
                          product[index].linkImg[0],
                          height: height / 10,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "AAaAAAAAAAAA",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              "dákdlaksjdaskldjaslkdjaskldjaslkdjlkasaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaajdkasjdkasjkdsajdjlaskdjkasjdlkasdjaslkdasjldkjasdlkasjdkasjl",
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.clip,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: product.length,
          ),
        ),
      ],
    );
  }
}
