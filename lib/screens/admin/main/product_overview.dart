import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopify/models/product.dart';
import 'package:shopify/screens/admin/widget/product/detail_product_admin.dart';
import 'package:shopify/utils/formart_currency.dart';
import 'dart:math';
import 'package:shopify/widgets/main_screens/list_color.dart';
import 'package:shopify/widgets/status_page.dart';
import 'package:shopify/models/status_page.dart';

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({super.key});
  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
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

  final _formSearch = GlobalKey<FormState>();
  void _searchElement() {
    if (_formSearch.currentState!.validate()) {
      _formSearch.currentState!.save();
    }
  }

  String _enterSearch = "";
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("products").snapshots(),
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
          final List<Product> product = [];
          if (_enterSearch.isEmpty) {
            for (var i = 0; i < snapshot.data!.docs.length; i++) {
              product.add(
                Product(
                  createAt: snapshot.data!.docs[i]["create_at"].toDate(),
                  stockQuantity: snapshot.data!.docs[i]["stock_quantity"],
                  description: snapshot.data!.docs[i]["description"],
                  name: snapshot.data!.docs[i]["name"],
                  rate: snapshot.data!.docs[i]["rate"],
                  color: snapshot.data!.docs[i]["color"],
                  price: snapshot.data!.docs[i]["price"],
                  linkImg: snapshot.data!.docs[i]["link_img"],
                  type: snapshot.data!.docs[i]["type"],
                  weight: snapshot.data!.docs[i]["weight"] as double,
                  colorCode:
                      List<int>.from(snapshot.data!.docs[i]["color_code"]),
                  linkImageMatch: snapshot.data!.docs[i]["link_image_match"],
                  sale: snapshot.data!.docs[i]["sale"],
                  id: snapshot.data!.docs[i].id,
                ),
              );
            }
          } else {
            for (var i = 0; i < snapshot.data!.docs.length; i++) {
              if (snapshot.data!.docs[i]["name"]
                  .toString()
                  .toLowerCase()
                  .contains(_enterSearch.toLowerCase())) {
                product.add(
                  Product(
                    createAt: snapshot.data!.docs[i]["create_at"].toDate(),
                    stockQuantity: snapshot.data!.docs[i]["stock_quantity"],
                    description: snapshot.data!.docs[i]["description"],
                    name: snapshot.data!.docs[i]["name"],
                    rate: snapshot.data!.docs[i]["rate"],
                    color: snapshot.data!.docs[i]["color"],
                    price: snapshot.data!.docs[i]["price"],
                    linkImg: snapshot.data!.docs[i]["link_img"],
                    type: snapshot.data!.docs[i]["type"],
                    weight: snapshot.data!.docs[i]["weight"] as double,
                    colorCode:
                        List<int>.from(snapshot.data!.docs[i]["color_code"]),
                    linkImageMatch: snapshot.data!.docs[i]["link_image_match"],
                    sale: snapshot.data!.docs[i]["sale"],
                    id: snapshot.data!.docs[i].id,
                  ),
                );
              }
            }
          }

          int length = (product.length / 2).ceil();
          return Container(
            margin: const EdgeInsets.only(top: 40),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Form(
                  key: _formSearch,
                  child: TextFormField(
                    initialValue: _enterSearch,
                    style: Theme.of(context).textTheme.bodySmall,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      hintText: "Product Name...",
                      hintStyle: Theme.of(context).textTheme.bodySmall,
                      suffixIcon: IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          _searchElement();
                        },
                        icon: const Icon(
                          Icons.search,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return "Please enter corectly!";
                      }

                      return null;
                    },
                    onSaved: (value) {
                      setState(() {
                        _enterSearch = value!.trim();
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: length,
                  itemBuilder: (context, idx) {
                    int firstIndex = idx * 2;
                    int secondIndex = idx * 2 + 1;
                    return Column(
                      children: [
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return DetailProductAdminScreen(
                                          idProduct: product[firstIndex].id);
                                    },
                                  ),
                                );
                              },
                              child: Card(
                                child: Column(
                                  children: [
                                    imageProduct(
                                        product[firstIndex].linkImg[0],
                                        product[firstIndex].sale,
                                        width,
                                        height),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      width: (width * 2) / 5,
                                      child: Text(
                                        product[firstIndex].name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      width: (width * 2) / 5,
                                      child: Text(
                                        product[firstIndex].sale == 0
                                            ? "${formatCurrency(product[firstIndex].price)} đ"
                                            : "${formatCurrency(product[firstIndex].price - ((product[firstIndex].price * product[firstIndex].sale) / 100).floor())} đ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      width: (width * 2) / 5,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: allColorOfProduct(
                                            context,
                                            product[firstIndex].colorCode,
                                            12,
                                            12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (secondIndex < product.length)
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return DetailProductAdminScreen(
                                            idProduct: product[secondIndex].id);
                                      },
                                    ),
                                  );
                                },
                                child: Card(
                                  child: Column(
                                    children: [
                                      imageProduct(
                                        product[secondIndex].linkImg[0],
                                        product[secondIndex].sale,
                                        width,
                                        height,
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        width: (width * 2) / 5,
                                        child: Text(
                                          product[secondIndex].name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        width: (width * 2) / 5,
                                        child: Text(
                                          product[secondIndex].sale == 0
                                              ? "${formatCurrency(product[secondIndex].price)} đ"
                                              : "${formatCurrency(product[secondIndex].price - ((product[secondIndex].price * product[secondIndex].sale) / 100).floor())} đ",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        width: (width * 2) / 5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: allColorOfProduct(
                                              context,
                                              product[secondIndex].colorCode,
                                              12,
                                              12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        });
  }
}
