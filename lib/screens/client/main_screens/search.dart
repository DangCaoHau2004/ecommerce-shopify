import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopify/models/product.dart';
import 'package:shopify/models/status_page.dart';
import 'dart:math';
import 'package:shopify/utils/formart_currency.dart';
import 'package:shopify/widgets/main_screens/list_color.dart';
import 'package:shopify/widgets/status_page.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection("products").get(),
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
          List<Product> allProc = [];
          for (var i = 0; i < snapshot.data!.docs.length; i++) {
            allProc.add(
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
                colorCode: List<int>.from(snapshot.data!.docs[i]["color_code"]),
                linkImageMatch: snapshot.data!.docs[i]["link_image_match"],
                sale: snapshot.data!.docs[i]["sale"],
                id: snapshot.data!.docs[i].id,
              ),
            );
          }
          return Search(allProduct: allProc);
        });
  }
}

class Search extends StatefulWidget {
  const Search({super.key, required this.allProduct});
  final List<Product> allProduct;
  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
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

  List<Product> productsearch = [];

  final _formSearchKey = GlobalKey<FormState>();
  void _searchElement(List<Product> proc) {
    if (_formSearchKey.currentState!.validate()) {
      _formSearchKey.currentState!.save();
      final searchProduct = proc.where((proc) {
        return proc.name.toLowerCase().contains(_enterSearch.toLowerCase());
      }).toList();
      setState(() {
        productsearch = searchProduct;
      });
    }
  }

  String _enterSearch = "";
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: false,
          title: Text(
            "Search",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart, color: Colors.orange),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.chat, color: Colors.orange),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child:
              // Thanh tìm kiếm
              Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.only(bottom: 30),
            child: Form(
              key: _formSearchKey,
              child: TextFormField(
                onChanged: (value) {
                  _searchElement(widget.allProduct);
                },
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
                      _searchElement(widget.allProduct);
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
          ),
        ),
        if (productsearch.isNotEmpty)
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
                          imageProduct(productsearch[index].linkImg[0],
                              productsearch[index].sale, width, height),
                          const SizedBox(
                            height: 16,
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  productsearch[index].name,
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
                                  "${formatCurrency(productsearch[index].price)} đ",
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
                                      productsearch[index].colorCode, 12, 12),
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
              childCount: productsearch.length,
            ),
          ),
      ],
    );
  }
}
