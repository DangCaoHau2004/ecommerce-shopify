import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/models/product.dart';
import 'package:shopify/models/status_page.dart';
import 'package:shopify/utils/formart_currency.dart';
import 'package:shopify/providers/user_data.dart';
import 'package:shopify/widgets/status_page.dart';
import 'package:shopify/models/cart.dart';

class Cart extends ConsumerStatefulWidget {
  const Cart({super.key});

  @override
  ConsumerState<Cart> createState() => _CartState();
}

class _CartState extends ConsumerState<Cart> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection("users")
          .doc(ref.watch(userData)["uid"])
          .collection("cart")
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const StatusPage(type: StatusPageEnum.loading, err: "");
        } else if (snapshot.hasError) {
          return StatusPage(
              type: StatusPageEnum.error, err: snapshot.error.toString());
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const StatusPage(type: StatusPageEnum.noData, err: "");
        }

        List<CartModel> cartProduct = [];
        List<String> cartId = [];
        List<int> count = [];

        for (var doc in snapshot.data!.docs) {
          cartProduct.add(
            CartModel(
              colorSelectIndex: doc["color_select_index"],
              id: doc.id,
              purchaseQuantity: doc["purchase_quantity"],
            ),
          );
          cartId.add(doc.id);
          count.add(doc["purchase_quantity"]);
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("products")
              .where(FieldPath.documentId, whereIn: cartId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const StatusPage(type: StatusPageEnum.loading, err: "");
            } else if (snapshot.hasError) {
              return StatusPage(
                  type: StatusPageEnum.error, err: snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const StatusPage(type: StatusPageEnum.noData, err: "");
            }

            List<Product> products = snapshot.data!.docs.map((doc) {
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

            return CartList(
              products: products,
              count: count,
              cartProduct: cartProduct,
            );
          },
        );
      },
    );
  }
}

class CartList extends ConsumerStatefulWidget {
  final List<Product> products;
  final List<int> count;
  final List<CartModel> cartProduct;
  const CartList({
    super.key,
    required this.products,
    required this.count,
    required this.cartProduct,
  });

  @override
  ConsumerState<CartList> createState() => _CartListState();
}

class _CartListState extends ConsumerState<CartList> {
  List<bool> _isSelect = [];
  int _totalProduct = 0;
  bool _isSelectAll = false;
  late List<CartModel> cartProduct;
  @override
  void initState() {
    super.initState();
    cartProduct = widget.cartProduct;
    _isSelect = List.filled(widget.products.length, false);
  }

  void _resetTotal() {
    _totalProduct = 0;
    for (var i = 0; i < widget.products.length; i++) {
      if (_isSelect[i]) {
        _totalProduct += (widget.products[i].price * widget.count[i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Cart", style: Theme.of(context).textTheme.bodyLarge),
      ),
      body: ListView.builder(
        itemCount: widget.products.length,
        itemBuilder: (context, idx) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSelect[idx] = !_isSelect[idx];
                      _resetTotal();
                    });
                  },
                  icon: _isSelect[idx]
                      ? const Icon(Icons.check_box)
                      : const Icon(Icons.check_box_outline_blank),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    widget.products[idx]
                        .linkImageMatch[cartProduct[idx].colorSelectIndex],
                    width: width / 5,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.products[idx].name,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${formatCurrency(widget.products[idx].price)} đ",
                        style: Theme.of(context).textTheme.bodySmall!,
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: DropdownButton(
                          elevation: 0,
                          underline: Container(
                              height: 0, color: Colors.deepPurpleAccent),
                          value: cartProduct[idx]
                              .colorSelectIndex, // Chỉ mục màu đã chọn
                          items: [
                            for (int i = 0;
                                i < widget.products[idx].color.length;
                                i++)
                              DropdownMenuItem(
                                value: i,
                                child: Text(
                                  widget.products[idx]
                                      .color[i], // Hiển thị tên màu
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              )
                          ],
                          dropdownColor:
                              Theme.of(context).colorScheme.onTertiary,
                          onChanged: (value) {
                            FirebaseFirestore.instance
                                .collection("users")
                                .doc(ref.watch(userData)["uid"])
                                .collection("cart")
                                .doc(widget.products[idx].id)
                                .update({"color_select_index": value!});
                            setState(() {
                              cartProduct[idx].colorSelectIndex = value;
                            });
                          },
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (widget.count[idx] - 1 == 0) {
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(ref.watch(userData)["uid"])
                                    .collection("cart")
                                    .doc(widget.products[idx].id)
                                    .delete();
                                setState(() {
                                  widget.products.removeAt(idx);
                                  widget.count.removeAt(idx);
                                  _isSelect.removeAt(idx);
                                  _resetTotal();
                                });
                              } else {
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(ref.watch(userData)["uid"])
                                    .collection("cart")
                                    .doc(widget.products[idx].id)
                                    .update({
                                  "purchase_quantity": widget.count[idx] - 1
                                });
                                setState(() {
                                  widget.count[idx] -= 1;
                                  _resetTotal();
                                });
                              }
                            },
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            widget.count[idx].toString(),
                            style: Theme.of(context).textTheme.bodySmall!,
                          ),
                          IconButton(
                            style: IconButton.styleFrom(
                              disabledBackgroundColor: Theme.of(context)
                                  .colorScheme
                                  .onTertiary
                                  .withOpacity(0.5),
                            ),
                            onPressed: widget.products[idx].stockQuantity <
                                    (widget.count[idx] + 1)
                                ? null
                                : () {
                                    FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(ref.watch(userData)["uid"])
                                        .collection("cart")
                                        .doc(widget.products[idx].id)
                                        .update({
                                      "purchase_quantity": widget.count[idx] + 1
                                    });
                                    setState(() {
                                      widget.count[idx] += 1;
                                      _resetTotal();
                                    });
                                  },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        height: _totalProduct == 0 ? height / 10 : height / 8,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isSelectAll = !_isSelectAll;
                            _isSelect = List.filled(
                                widget.products.length, _isSelectAll);
                            _resetTotal();
                          });
                        },
                        icon: _isSelectAll
                            ? const Icon(Icons.check_box)
                            : const Icon(Icons.check_box_outline_blank),
                      ),
                      Text("Select All",
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  if (_totalProduct != 0)
                    Text(
                      "Total: ${formatCurrency(_totalProduct)} đ",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
            if (_totalProduct != 0)
              ElevatedButton(
                onPressed: () {},
                child: Text(
                  "Check Out",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
