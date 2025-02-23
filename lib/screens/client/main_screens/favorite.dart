import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopify/models/product.dart';
import 'dart:math';
import 'package:shopify/utils/formart_currency.dart';
import 'package:shopify/utils/navigation_helper.dart';
import 'package:shopify/widgets/main_screens/list_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/providers/user_data.dart';
import 'package:shopify/models/status_page.dart';
import 'package:shopify/widgets/status_page.dart';

class FavoriteScreen extends ConsumerStatefulWidget {
  const FavoriteScreen({super.key});
  @override
  ConsumerState<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends ConsumerState<FavoriteScreen> {
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(ref.watch(userData)["uid"])
          .collection("favorite")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const StatusPageWithOutAppBar(
              type: StatusPageEnum.loading, err: "");
        } else if (snapshot.hasError) {
          return StatusPageWithOutAppBar(
            type: StatusPageEnum.error,
            err: snapshot.error.toString(),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                    onPressed: () {
                      navigatorToChat(context);
                    },
                    icon: const Icon(Icons.chat, color: Colors.orange),
                  ),
                ],
              ),
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
            ],
          );
        }
        List<String> idFavProduct = snapshot.data!.docs.map((item) {
          return item.id;
        }).toList();
        return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("products")
                .where(FieldPath.documentId, whereIn: idFavProduct)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const StatusPageWithOutAppBar(
                    type: StatusPageEnum.loading, err: "");
              } else if (snapshot.hasError) {
                return StatusPageWithOutAppBar(
                  type: StatusPageEnum.error,
                  err: snapshot.error.toString(),
                );
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                          icon: const Icon(Icons.shopping_cart,
                              color: Colors.orange),
                        ),
                        IconButton(
                          onPressed: () {
                            navigatorToChat(context);
                          },
                          icon: const Icon(Icons.chat, color: Colors.orange),
                        ),
                      ],
                    ),
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
                  ],
                );
              }
              List<Product> product = snapshot.data!.docs.map((doc) {
                return Product(
                  createAt: doc["create_at"].toDate(),
                  stockQuantity: doc["stock_quantity"],
                  description: doc["description"],
                  name: doc["name"],
                  rate: doc["rate"],
                  color: doc["color"],
                  price: doc["price"],
                  linkImg: doc["link_img"],
                  type: doc["type"],
                  weight: doc["weight"] as double,
                  colorCode: List<int>.from(doc["color_code"]),
                  linkImageMatch: doc["link_image_match"],
                  sale: doc["sale"],
                  id: doc.id,
                );
              }).toList();

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
                        icon: const Icon(Icons.shopping_cart,
                            color: Colors.orange),
                      ),
                      IconButton(
                        onPressed: () {
                          navigatorToChat(context);
                        },
                        icon: const Icon(Icons.chat, color: Colors.orange),
                      ),
                    ],
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(top: 30),
                          padding: const EdgeInsets.all(16),
                          child: TextButton(
                            onPressed: () {
                              navigatorToDetailProduct(
                                  context, product[index].id);
                            },
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          product[index].name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Text(
                                          "${formatCurrency(product[index].price)} đ",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
            });
      },
    );
  }
}
