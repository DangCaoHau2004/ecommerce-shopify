import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopify/models/product.dart';
import 'package:shopify/utils/formart_currency.dart';
import 'package:shopify/providers/user_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddToCart extends ConsumerStatefulWidget {
  const AddToCart({super.key, required this.product});
  final Product product;
  @override
  ConsumerState<AddToCart> createState() => _AddToCartState();
}

class _AddToCartState extends ConsumerState<AddToCart> {
  final _formKey = GlobalKey<FormState>();
  int indexColorSelect = 0;
  int count = 1;
  List<Widget> allColorButtonOfProduct(
      context, List<int> hex, double height, double width) {
    List<Widget> colors = [];
    if (hex.length == 1) {
      colors.add(
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).colorScheme.secondary, width: 0.2),
            color: Color(
              hex[0],
            ),
            shape: BoxShape.circle,
          ),
        ),
      );
      return colors;
    }
    for (var i = 0; i < hex.length; i++) {
      colors.add(
        Row(
          children: [
            TextButton(
              onPressed: () {
                setState(
                  () {
                    indexColorSelect = i;
                  },
                );
              },
              child: Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 0.2),
                  color: Color(
                    hex[i],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            if (i != hex.length - 1)
              const SizedBox(
                width: 4,
              ),
          ],
        ),
      );
    }
    return colors;
  }

  void _addToCard(context) async {
    String userId = ref.watch(userData)["uid"];

    final productInCart = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("cart")
        .doc(widget.product.id)
        .get();

    if (!productInCart.exists) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("cart")
          .doc(widget.product.id)
          .set({
        "purchase_quantity": count,
        "color_select_index": indexColorSelect,
      });
    } else {
      FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("cart")
          .doc(widget.product.id)
          .update(
        {"purchase_quantity": productInCart["purchase_quantity"] + count},
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        color: Theme.of(context).colorScheme.onTertiary,
      ),
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        bottom: 16.0 + keyboardSpace,
        top: 16.0,
        left: 16.0,
        right: 16.0,
      ),
      child: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      widget.product.linkImageMatch[indexColorSelect],
                      width: 100,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.sale == 0
                            ? "${formatCurrency(widget.product.price * count)} đ"
                            : "${formatCurrency(
                                (widget.product.price -
                                            ((widget.product.price *
                                                    widget.product.sale) /
                                                100))
                                        .floor() *
                                    count,
                              )} đ",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Row(
                        children: [
                          Text("Storage:",
                              style: Theme.of(context).textTheme.bodyMedium!),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            widget.product.stockQuantity.toString(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    "Color:",
                    style: Theme.of(context).textTheme.bodyMedium!,
                  ),
                  const Spacer(),
                  Text(
                    widget.product.color[indexColorSelect],
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.orange,
                        ),
                  )
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: allColorButtonOfProduct(
                    context, widget.product.colorCode, 24, 24),
              ),
              const SizedBox(
                height: 60,
              ),
              Row(
                children: [
                  Text(
                    "Quantity:",
                    style: Theme.of(context).textTheme.bodyMedium!,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          disabledBackgroundColor: Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withOpacity(0.5),
                        ),
                        onPressed: count == 1
                            ? null
                            : () {
                                setState(
                                  () {
                                    count -= 1;
                                  },
                                );
                              },
                        icon: const Icon(Icons.remove),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        count.toString(),
                        style: Theme.of(context).textTheme.bodySmall!,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          disabledBackgroundColor: Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withOpacity(0.5),
                        ),
                        onPressed:
                            widget.product.stockQuantity - (count + 1) < 0
                                ? null
                                : () {
                                    setState(() {
                                      count += 1;
                                    });
                                  },
                        icon: const Icon(Icons.add),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _addToCard(context);
                    },
                    child: Text(
                      "Add To Cart",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onTertiary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
