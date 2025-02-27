import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/models/product.dart';
import 'package:shopify/models/status_page.dart';
import 'package:shopify/utils/formart_currency.dart';
import 'package:shopify/providers/user_data.dart';
import 'package:shopify/utils/navigation_helper.dart';
import 'package:shopify/widgets/status_page.dart';
import 'package:shopify/models/cart.dart';

class Cart extends ConsumerStatefulWidget {
  const Cart({super.key});

  @override
  ConsumerState<Cart> createState() => _CartState();
}

class _CartState extends ConsumerState<Cart> {
  Future<List<QueryDocumentSnapshot>> getAllProcFromCart(
      List<String> idProc) async {
    final List<QueryDocumentSnapshot> allProc = [];
    for (String i in idProc) {
      final proc = await FirebaseFirestore.instance
          .collection("products")
          .where(FieldPath.documentId, isEqualTo: i)
          .get();
      allProc.add(proc.docs[0]);
    }
    return allProc;
  }

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
          return Scaffold(
            appBar: AppBar(
              title:
                  Text("My Cart", style: Theme.of(context).textTheme.bodyLarge),
            ),
            body: Center(
              child: Text(
                "You have no orders in your cart!",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          );
        }

        List<CartModel> cartProduct = [];
        List<String> cartId = [];
        List<int> count = [];

        for (var doc in snapshot.data!.docs) {
          cartProduct.add(
            CartModel(
              colorSelectIndex: doc["color_select_index"],
              id: doc.id,
              idProc: doc["id"],
              purchaseQuantity: doc["purchase_quantity"],
            ),
          );
          cartId.add(doc["id"]);
          count.add(doc["purchase_quantity"]);
        }

        return FutureBuilder<List<QueryDocumentSnapshot>>(
          future: getAllProcFromCart(cartId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const StatusPage(type: StatusPageEnum.loading, err: "");
            } else if (snapshot.hasError) {
              return StatusPage(
                  type: StatusPageEnum.error, err: snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const StatusPage(type: StatusPageEnum.noData, err: "");
            }

            List<Product> products = snapshot.data!.map((doc) {
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
  late List<Product> proc;
  late List<int> count;
  bool _isLoading = false;
  void checkOut() {
    try {
      setState(() {
        _isLoading = true;
      });
      List<Product> productSelect = [];
      List<CartModel> cartProductSelect = [];
      List<int> countSelect = [];

      for (var i = 0; i < _isSelect.length; i++) {
        if (_isSelect[i]) {
          productSelect.add(proc[i]);
          cartProductSelect.add(cartProduct[i]);
          countSelect.add(count[i]);
        }
      }
      //  kiểm tra xem số lượng hàng có bị vượt quá
      Map<String, int> countMap = {};
      for (int i = 0; i < productSelect.length; i++) {
        countMap[cartProductSelect[i].idProc] =
            countMap[cartProductSelect[i].idProc] == null
                ? cartProductSelect[i].purchaseQuantity
                : countMap[cartProductSelect[i].idProc]! +
                    cartProductSelect[i].purchaseQuantity;
        if (countMap[cartProductSelect[i].idProc]! >
            productSelect[i].stockQuantity) {
          throw Exception(
              "You have exceeded the ${productSelect[i].name} quantity.");
        }
      }
      setState(() {
        _isLoading = false;
      });
      navigatorToCheckOut(
          context, productSelect, cartProductSelect, countSelect);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$e"),
          action: SnackBarAction(label: "Ok", onPressed: () {}),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    proc = widget.products;
    cartProduct = widget.cartProduct;
    count = widget.count;
    _isSelect = List.generate(widget.products.length, (index) => false);
  }

  void _resetTotal() {
    _totalProduct = 0;
    for (var i = 0; i < proc.length; i++) {
      if (_isSelect[i]) {
        _totalProduct += (proc[i].price * count[i]);
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            )
          : proc.isEmpty
              ? Center(
                  child: Text(
                    "You have no orders in your cart!",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              : ListView.builder(
                  itemCount: proc.length,
                  itemBuilder: (context, idx) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isSelect[idx] = !_isSelect[idx];
                                if (const ListEquality().equals(_isSelect,
                                    List.filled(proc.length, true))) {
                                  _isSelectAll = true;
                                } else {
                                  _isSelectAll = false;
                                }
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
                              proc[idx].linkImageMatch[
                                  cartProduct[idx].colorSelectIndex],
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
                                  proc[idx].name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "${formatCurrency(proc[idx].price)} đ",
                                  style: Theme.of(context).textTheme.bodySmall!,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: DropdownButton(
                                    elevation: 0,
                                    underline: Container(
                                        height: 0,
                                        color: Colors.deepPurpleAccent),
                                    value: cartProduct[idx]
                                        .colorSelectIndex, // Chỉ mục màu đã chọn
                                    items: [
                                      for (int i = 0;
                                          i < proc[idx].color.length;
                                          i++)
                                        DropdownMenuItem(
                                          value: i,
                                          child: Text(
                                            proc[idx]
                                                .color[i], // Hiển thị tên màu
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        )
                                    ],
                                    dropdownColor: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                    onChanged: (value) async {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      final checkInCart =
                                          await FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(ref.watch(userData)["uid"])
                                              .collection("cart")
                                              .where("id",
                                                  isEqualTo:
                                                      cartProduct[idx].idProc)
                                              .where("color_select_index",
                                                  isEqualTo: value!)
                                              .get();
                                      // nếu như màu đã tồn tại trong db
                                      if (checkInCart.docs.isNotEmpty) {
                                        for (var i = 0;
                                            i < cartProduct.length;
                                            i++) {
                                          if (cartProduct[i].idProc ==
                                                  cartProduct[idx].idProc &&
                                              cartProduct[i].colorSelectIndex ==
                                                  value) {
                                            if (cartProduct[i]
                                                        .purchaseQuantity +
                                                    cartProduct[idx]
                                                        .purchaseQuantity >
                                                proc[i].stockQuantity) {
                                              setState(() {
                                                _isLoading = false;
                                              });
                                              return;
                                            }
                                            cartProduct[i].purchaseQuantity +=
                                                cartProduct[idx]
                                                    .purchaseQuantity;
                                          }
                                        }
                                        FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(ref.watch(userData)["uid"])
                                            .collection("cart")
                                            .doc(checkInCart.docs[0].id)
                                            .update({
                                          "purchase_quantity": checkInCart
                                                      .docs[0]
                                                  ["purchase_quantity"] +
                                              cartProduct[idx].purchaseQuantity
                                        });
                                        FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(ref.watch(userData)["uid"])
                                            .collection("cart")
                                            .doc(cartProduct[idx].id)
                                            .delete();

                                        setState(() {
                                          _isLoading = false;
                                          proc.removeAt(idx);
                                          count.removeAt(idx);
                                          cartProduct.removeAt(idx).id;
                                          _isSelect.removeAt(idx);
                                          _resetTotal();
                                        });
                                        return;
                                      }
                                      // nếu màu chưa tồn tại trong db
                                      FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(ref.watch(userData)["uid"])
                                          .collection("cart")
                                          .doc(cartProduct[idx].id)
                                          .update(
                                              {"color_select_index": value});
                                      setState(() {
                                        _isLoading = false;
                                        cartProduct[idx].colorSelectIndex =
                                            value;
                                      });
                                    },
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (count[idx] - 1 == 0) {
                                          FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(ref.watch(userData)["uid"])
                                              .collection("cart")
                                              .doc(cartProduct[idx].id)
                                              .delete();
                                          setState(() {
                                            proc.removeAt(idx);
                                            count.removeAt(idx);
                                            cartProduct.removeAt(idx).id;
                                            _isSelect.removeAt(idx);
                                            _resetTotal();
                                          });
                                        } else {
                                          FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(ref.watch(userData)["uid"])
                                              .collection("cart")
                                              .doc(cartProduct[idx].id)
                                              .update({
                                            "purchase_quantity": count[idx] - 1
                                          });
                                          setState(() {
                                            count[idx] -= 1;
                                            _resetTotal();
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.remove),
                                    ),
                                    Text(
                                      count[idx].toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!,
                                    ),
                                    IconButton(
                                      style: IconButton.styleFrom(
                                        disabledBackgroundColor:
                                            Theme.of(context)
                                                .colorScheme
                                                .onTertiary
                                                .withOpacity(0.5),
                                      ),
                                      onPressed: proc[idx].stockQuantity <
                                              (count[idx] + 1)
                                          ? null
                                          : () {
                                              FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(ref
                                                      .watch(userData)["uid"])
                                                  .collection("cart")
                                                  .doc(cartProduct[idx].id)
                                                  .update({
                                                "purchase_quantity":
                                                    count[idx] + 1
                                              });
                                              setState(() {
                                                count[idx] += 1;
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
                            _isSelect = List.filled(proc.length, _isSelectAll);
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
                onPressed: checkOut,
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
