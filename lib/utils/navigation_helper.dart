import 'package:flutter/material.dart';
import 'package:shopify/models/cart.dart';
import 'package:shopify/models/product.dart';
import 'package:shopify/screens/client/rate.dart';
import 'package:shopify/screens/client/setting.dart';
import 'package:shopify/screens/client/tracking/detail_tracking.dart';
import 'package:shopify/screens/client/tracking/tabview_tracking.dart';
import 'package:shopify/screens/chat/chat.dart';
import 'package:shopify/screens/client/address/add_new_address.dart';
import 'package:shopify/screens/client/address/all_address.dart';
import 'package:shopify/screens/client/cart.dart';
import 'package:shopify/screens/client/check_out.dart';
import 'package:shopify/screens/client/coupon.dart';
import 'package:shopify/screens/detail_product.dart';
import 'package:shopify/widgets/login_singup/forget_password.dart';
import 'package:shopify/widgets/select_coupon.dart';

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

void navigatorToSetting(context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const SettingScreen(),
    ),
  );
}

void navigatorToRate(context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const RateScreen(),
    ),
  );
}

void navigatorToCheckOut(context, List<Product> productSelect,
    List<CartModel> cartProductSelect, List<int> count) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => CheckOutScreen(
        productSelect: productSelect,
        cartProductSelect: cartProductSelect,
        count: count,
      ),
    ),
  );
}

Future<String> navigatorToAllAdress(context) async {
  final idSelect = await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const AllAddressScreen(),
    ),
  );
  return idSelect.toString();
}

Future<Map<String, String>> navigatorToSelectCoupon(context) async {
  final data = await Navigator.of(context).push<Map<String, String>>(
    MaterialPageRoute(
      builder: (context) => const SelectCoupon(),
    ),
  );
  return data!;
}

void navigatorToCoupon(
  context,
) {
  Navigator.of(context).push<String>(
    MaterialPageRoute(
      builder: (context) => const CouponScreen(),
    ),
  );
}

void navigatorToAddNewAdress(
  context,
) {
  Navigator.of(context).push<String>(
    MaterialPageRoute(
      builder: (context) => const AddNewAddress(),
    ),
  );
}

void navigatorToTabviewTrackingScreen(context, int index) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => TabviewTrackingScreen(tab: index),
    ),
  );
}

void navigatorToDetailTracking(context, String idOrder) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => DetailTrackingScreen(idOrder: idOrder),
    ),
  );
}
