import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopify/models/product.dart';
import 'package:shopify/utils/formart_currency.dart';
import 'package:shopify/utils/navigation_helper.dart';
import 'package:shopify/widgets/cart/add_to_cart.dart';
import 'package:shopify/widgets/main_screens/home_product_list.dart';
import 'package:shopify/widgets/main_screens/list_color.dart';
import 'package:shopify/models/status_page.dart';
import 'package:shopify/widgets/status_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/providers/user_data.dart';

class DetailProductScreen extends ConsumerStatefulWidget {
  const DetailProductScreen({super.key, required this.idProduct});
  final String idProduct;

  @override
  ConsumerState<DetailProductScreen> createState() =>
      _DetailProductScreenState();
}

class _DetailProductScreenState extends ConsumerState<DetailProductScreen> {
  bool _iconFav = false;
  bool _isLoading = false;
  void _changeFav() async {
    setState(() {
      _isLoading = true;
    });
    final tempFav = await FirebaseFirestore.instance
        .collection("users")
        .doc(ref.watch(userData)["uid"])
        .collection("favorite")
        .doc(widget.idProduct)
        .get();
    if (tempFav.exists) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(ref.watch(userData)["uid"])
          .collection("favorite")
          .doc(widget.idProduct)
          .delete();
    } else {
      FirebaseFirestore.instance
          .collection("users")
          .doc(ref.watch(userData)["uid"])
          .collection("favorite")
          .doc(widget.idProduct)
          .set({"create_at": DateTime.now()});
    }

    setState(() {
      _isLoading = false;
      _iconFav = !_iconFav;
    });
  }

  void _loadFav() async {
    _isLoading = true;
    final checkFav = await FirebaseFirestore.instance
        .collection("users")
        .doc(ref.read(userData)["uid"])
        .collection("favorite")
        .where(FieldPath.documentId, isEqualTo: widget.idProduct)
        .get();
    if (checkFav.docs.isNotEmpty) {
      _iconFav = true;
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _showModalAddToCart(Product product) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return AddToCart(
          product: product,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadFav();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Loading...",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Colors.orange,
          ),
        ),
      );
    }
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("products")
            .doc(widget.idProduct)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const StatusPage(
              type: StatusPageEnum.loading,
              err: "",
            );
          } else if (snapshot.hasError) {
            return StatusPage(
              type: StatusPageEnum.error,
              err: snapshot.error.toString(),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const StatusPage(
              type: StatusPageEnum.noData,
              err: "",
            );
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;

          final Product product = Product(
            createAt: data.containsKey("create_at")
                ? data["create_at"].toDate()
                : DateTime.now(),
            stockQuantity: data["stock_quantity"],
            description: data["description"],
            name: data["name"],
            rate: data["rate"],
            color: data["color"],
            price: data["price"],
            linkImg: data["link_img"],
            type: data["type"],
            weight: data["weight"],
            colorCode: data["color_code"] != null
                ? List<int>.from(data["color_code"])
                : [],
            linkImageMatch: data["link_image_match"],
            sale: data["sale"],
            id: widget.idProduct,
          );

          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  onPressed: () {
                    navigatorToCart(context);
                  },
                  icon: const Icon(Icons.shopping_cart),
                ),
                IconButton(
                  onPressed: _changeFav,
                  icon: _iconFav
                      ? const Icon(Icons.favorite)
                      : const Icon(Icons.favorite_border),
                ),
              ],
            ),
            body: ListView(
              children: [
                StartDetailProduct(
                  height: height,
                  width: width,
                  product: product,
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          Text(
                            product.rate.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection("products")
                                  .doc(widget.idProduct)
                                  .collection("reviews")
                                  .count()
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const StatusPageWithOutScaffold(
                                    type: StatusPageEnum.loading,
                                    err: "",
                                  );
                                }
                                if (snapshot.hasError) {
                                  return Text(
                                    "0 Reviews",
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  );
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return Text(
                                    "0 Reviews",
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  );
                                }
                                return Text(
                                  "${snapshot.data!.count} Reviews",
                                  style: Theme.of(context).textTheme.bodySmall,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          if (product.sale != 0)
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "${formatCurrency(product.price)} đ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Colors.grey.withOpacity(0.5),
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          if (product.sale != 0)
                            const SizedBox(
                              width: 10,
                            ),
                          Text(
                              product.sale == 0
                                  ? "${formatCurrency(product.price)} đ"
                                  : "${formatCurrency(
                                      product.price -
                                          ((product.price * product.sale) / 100)
                                              .floor(),
                                    )} đ",
                              style: Theme.of(context).textTheme.bodySmall!),
                          const SizedBox(
                            width: 10,
                          ),
                          if (product.sale != 0)
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                "Sale: ${product.sale}%",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiary),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.clip,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        "Description",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.clip,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        product.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.clip,
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Colors",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              overflow: TextOverflow.clip,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: allColorOfProduct(
                                  context, product.colorCode, 18, 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 80,
                      ),
                      Text(
                        "Reviews",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.clip,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection("products")
                              .doc(widget.idProduct)
                              .collection("reviews")
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const StatusPageWithOutScaffold(
                                type: StatusPageEnum.loading,
                                err: "",
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  "None",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            }
                            if (!snapshot.hasData || snapshot.data == null) {
                              return Center(
                                child: Text(
                                  "None",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            }
                            final reviews = snapshot.data!.docs;
                            return Column(
                              children: [
                                for (QueryDocumentSnapshot review in reviews)
                                  Row(
                                    children: [
                                      TextButton(
                                        style: Theme.of(context)
                                            .textButtonTheme
                                            .style!
                                            .copyWith(
                                              alignment: Alignment.centerLeft,
                                            ),
                                        onPressed: () {},
                                        child: const CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: AssetImage(
                                              "assets/images/user.png"),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                for (int idx = 0;
                                                    idx < review["rate"];
                                                    idx++)
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.amberAccent,
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              review["content"],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                              overflow: TextOverflow.clip,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            );
                          }),
                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Suggested Products",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                HomeProductList(
                  physic: true,
                  type: product.type,
                  idProductRemove: product.id,
                ),
              ],
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(16),
              height: height / 10,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary, // Màu sắc của border trên
                    width: 0.2, // Độ dày của border
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 8,
                    child: ElevatedButton(
                      onPressed: () {
                        _showModalAddToCart(product);
                      },
                      child: Text(
                        "Add to cart",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onTertiary,
                            ),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Text(""),
                  ),
                  Expanded(
                    flex: 8,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: Text(
                        "Buy now",
                        style: Theme.of(context).textTheme.bodyMedium!,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class StartDetailProduct extends StatefulWidget {
  const StartDetailProduct(
      {super.key,
      required this.product,
      required this.height,
      required this.width});
  final Product product;
  final double height;
  final double width;
  @override
  State<StartDetailProduct> createState() => _StartDetailProductState();
}

class _StartDetailProductState extends State<StartDetailProduct> {
  int _indexImg = 0;

  void _changeImg(int index) {
    setState(() {
      _indexImg = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InteractiveViewer(
          child: Image.network(
            widget.product.linkImg[_indexImg],
            width: double.infinity,
            fit: BoxFit.fitHeight,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: widget.height / 10,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: widget.product.linkImg.length,
              itemBuilder: (context, idx) {
                return Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        _changeImg(idx);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(
                          color: _indexImg == idx
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.product.linkImg[idx],
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    if (idx != widget.product.linkImg.length - 1)
                      const SizedBox(width: 8), // Khoảng cách giữa các ảnh
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
