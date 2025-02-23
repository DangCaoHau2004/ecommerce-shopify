import 'package:flutter/material.dart';
import 'package:shopify/screens/chat/chat.dart';
import 'package:shopify/screens/client/cart.dart';
import 'package:shopify/screens/detail_product.dart';
import 'package:shopify/widgets/login_singup/forget_password.dart';

void navigatorToForgetPassword(context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => const ForgetPassword()),
  );
}

void navigatorToDetailProduct(context, String idProduct) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => DetailProductScreen(idProduct: idProduct),
    ),
  );
}

void navigatorToChat(context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const ChatScreen(),
    ),
  );
}

void navigatorToCart(context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const Cart(),
    ),
  );
}
