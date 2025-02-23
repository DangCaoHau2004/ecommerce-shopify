import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopify/models/product.dart';
import 'package:shopify/models/status_page.dart';
import 'package:shopify/utils/formart_currency.dart';
import 'package:shopify/providers/user_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(ref.watch(userData)["uid"])
            .collection("cart")
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
          List<CartModel> cartProduct = [];
          List<String> cartId = [];
          List<int> count = [];
          for (var i = 0; i < snapshot.data!.docs.length; i++) {
            cartProduct.add(
              CartModel(
                colorSelectIndex: snapshot.data!.docs[i]["color_select_index"],
                id: snapshot.data!.docs[i].id,
                purchaseQuantity: snapshot.data!.docs[i]["purchase_quantity"],
              ),
            );
            cartId.add(snapshot.data!.docs[i].id);
            count.add(snapshot.data!.docs[i]["purchase_quantity"]);
          }
          return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("products")
                  .where(
                    FieldPath.documentId,
                    whereIn: cartId,
                  )
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
                  return const StatusPageWithOutAppBar(
                    type: StatusPageEnum.noData,
                    err: "",
                  );
                }
                List<Product> product = [];
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
                      linkImageMatch: snapshot.data!.docs[i]
                          ["link_image_match"],
                      sale: snapshot.data!.docs[i]["sale"],
                      id: snapshot.data!.docs[i].id,
                    ),
                  );
                }
                // danh sách các phần tử đã được chọn

                // mặc định toàn bộ là false nhưng cần đếm số phần tử
                List<bool> _isSelect = List.filled(product.length, false);
                // danh sách số lượng

                // danh sách các id của product sau khi thêm click vào thêm
                // tổng giá của sản phẩm đã chọn
                int _totalProduct = 0;
                bool _isSelectAll = false;
                void _increaseCount(String uid) {}
                void _decreaseCount(String uid) {}

                // sửa lại giá trị mỗi khi có lượt tick
                void _resetTotal() {
                  for (var i = 0; i < product.length; i++) {
                    if (_isSelect[i]) {
                      _totalProduct += (product[i].price * count[i]);
                    }
                  }
                }

                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                      "My Cart",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  body: ListView.builder(
                    itemCount: product.length,
                    itemBuilder: (context, idx) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              alignment: Alignment.topLeft,
                              onPressed: () {
                                setState(
                                  () {
                                    _isSelect[idx] = !_isSelect[idx];
                                    _resetTotal();
                                  },
                                );
                                // _selectedproduct.add();
                              },
                              icon: _isSelect[idx]
                                  ? const Icon(Icons.check_box)
                                  : const Icon(
                                      Icons.check_box_outline_blank,
                                    ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                product[idx].linkImg[0],
                                width: width / 5,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product[idx].name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    "${formatCurrency(product[idx].price)} đ",
                                    style:
                                        Theme.of(context).textTheme.bodySmall!,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          if (count[idx] - 1 == 0) {
                                            product.removeAt(idx);
                                            count.removeAt(idx);
                                          }
                                          setState(
                                            () {
                                              count[idx] -= 1;
                                              _resetTotal();
                                            },
                                          );
                                        },
                                        icon: const Icon(Icons.remove),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        count[idx].toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(
                                            () {
                                              count[idx] += 1;
                                              _resetTotal();
                                            },
                                          );
                                        },
                                        icon: const Icon(Icons.add),
                                      )
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
                                      setState(
                                        () {
                                          _isSelectAll = !_isSelectAll;
                                          _isSelect =
                                              List.filled(10, _isSelectAll);
                                          _resetTotal();
                                        },
                                      );
                                    },
                                    icon: _isSelectAll
                                        ? const Icon(Icons.check_box)
                                        : const Icon(
                                            Icons.check_box_outline_blank),
                                  ),
                                  Text(
                                    "Select All",
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              if (_totalProduct != 0)
                                Row(
                                  children: [
                                    Text(
                                      "Total: ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!,
                                    ),
                                    Text(
                                      "${formatCurrency(_totalProduct)} đ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        if (_totalProduct != 0)
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Check Out",
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
                          )
                      ],
                    ),
                  ),
                );
              });
        });
  }
}
