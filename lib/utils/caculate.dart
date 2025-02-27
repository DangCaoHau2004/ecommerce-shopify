import 'package:shopify/models/coupon.dart';

int caculateTotalPriceAfterDiscount(
    {required int originalPrice, required Coupon coupon}) {
  if (coupon.discountType == "fixed") {
    if (coupon.minOrderAmount > originalPrice) {
      return originalPrice;
    }
    return (originalPrice - coupon.discountValue);
  }
  if (coupon.discountType == "percent") {
    if (coupon.minOrderAmount > originalPrice) {
      return originalPrice;
    }
    return (originalPrice - (originalPrice * coupon.discountValue) / 100)
        .round();
  }
  return originalPrice;
}

int caculateDisCount({required int originalPrice, required Coupon coupon}) {
  if (coupon.discountType == "fixed") {
    if (coupon.minOrderAmount > originalPrice) {
      return 0;
    }
    return (coupon.discountValue);
  }
  if (coupon.discountType == "percent") {
    if (coupon.minOrderAmount > originalPrice) {
      return 0;
    }
    return ((originalPrice * coupon.discountValue) / 100).round();
  }
  return 0;
}
