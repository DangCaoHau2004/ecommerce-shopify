import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopify/models/product.dart';
import 'package:shopify/screens/admin/widget/product/edit_product.dart';
import 'package:shopify/utils/formart_currency.dart';
import 'package:shopify/widgets/main_screens/list_color.dart';
import 'package:shopify/models/status_page.dart';
import 'package:shopify/widgets/status_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailProductAdminScreen extends ConsumerStatefulWidget {
  const DetailProductAdminScreen({super.key, required this.idProduct});
  final String idProduct;

  @override
  ConsumerState<DetailProductAdminScreen> createState() =>
      _DetailProductAdminScreenState();
}

class _DetailProductAdminScreenState
    extends ConsumerState<DetailProductAdminScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void editProduct(Product product) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return EditProduct(
          idProduct: widget.idProduct,
          product: product,
        );
      },
    );
  }

  void removeProduct() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection("products")
          .doc(widget.idProduct)
          .delete();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Success"),
          action: SnackBarAction(label: "Ok", onPressed: () {}),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$e"),
          action: SnackBarAction(label: "Ok", onPressed: () {}),
        ),
      );
    }
    setState(() {
      _isLoading = true;
    });
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
        final Product product = Product(
          createAt: snapshot.data!["create_at"].toDate(),
          stockQuantity: snapshot.data!["stock_quantity"],
          description: snapshot.data!["description"],
          name: snapshot.data!["name"],
          rate: snapshot.data!["rate"],
          color: snapshot.data!["color"],
          price: snapshot.data!["price"],
          linkImg: snapshot.data!["link_img"],
          type: snapshot.data!["type"],
          weight: snapshot.data!["weight"],
          colorCode: List<int>.from(snapshot.data!["color_code"]),
          linkImageMatch: snapshot.data!["link_image_match"],
          sale: snapshot.data!["sale"],
          id: widget.idProduct,
        );

        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () {
                  editProduct(product);
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: removeProduct,
                icon: const Icon(Icons.delete),
              )
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
                          child: Text(
                            "133 Reviews",
                            style: Theme.of(context).textTheme.bodySmall,
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
                                        decoration: TextDecoration.lineThrough,
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
                      height: 16,
                    ),
                    Text(
                      "Type",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.clip,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      product.type,
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
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
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
                    Row(
                      children: [
                        TextButton(
                          style:
                              Theme.of(context).textButtonTheme.style!.copyWith(
                                    alignment: Alignment.centerLeft,
                                  ),
                          onPressed: () {},
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Image.asset(
                              "assets/images/user.png",
                              height: height / 30,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  for (int idx = 0; idx < 5; idx++)
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
                                "Đép",
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.clip,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
