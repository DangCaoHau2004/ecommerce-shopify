import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shopify/models/product.dart';
import 'package:shopify/data/data_test.dart';
import 'dart:math';
import 'package:shopify/utils/formart_currency.dart';
import 'package:shopify/utils/navigation_helper.dart';
import 'package:shopify/widgets/main_screens/list_color.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});
  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  Widget imageProduct(String linkImage, int sale, double width, double height) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            linkImage,
            width: (width * 2) / 5,
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
                  "${sale}%",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Product> product = [];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    int length = (product.length / 2).ceil();
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: false,
          title: Text(
            "Favourite",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
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
        if (product.isEmpty)
          SliverToBoxAdapter(
            child: Container(
              height: height / 2,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  "You haven't favorited any items yet. Check out some of our featured products!",
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        if (product.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Container(
                  margin: const EdgeInsets.only(top: 30),
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: () {},
                    child: Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          imageProduct(product[index].linkImg[0],
                              product[index].sale, width, height),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  product[index].name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  "${formatCurrency(product[index].price)} đ",
                                  style: Theme.of(context).textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: allColorOfProduct(context,
                                      product[index].colorCode, 12, 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
