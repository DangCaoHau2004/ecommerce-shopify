import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shopify/models/product.dart';
import 'package:shopify/data/data_test.dart';
import 'dart:math';
import 'package:shopify/utils/formart_currency.dart';
import 'package:shopify/widgets/main_screens/list_color.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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

  final _formSearchKey = GlobalKey<FormState>();
  List<Product> product = [];
  void _searchElement() {
    if (_formSearchKey.currentState!.validate()) {
      _formSearchKey.currentState!.save();
      final searchProduct = productTest.where((proc) {
        return proc.name.toLowerCase().contains(_enterSearch.toLowerCase());
      }).toList();
      setState(() {
        product = searchProduct;
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
                  _searchElement();
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
