class Coupon {
  const Coupon(
      {required this.code,
      required this.content,
      required this.type,
      required this.discountType,
      required this.discountValue,
      required this.minOrderAmount,
      required this.usageLimit,
      required this.usedCount,
      required this.startDate,
      required this.endDate,
      required this.active,
      required this.applicableProductType});
  final String code;
  final String content;
  final String type;
  final String discountType;
  final int discountValue;
  final int minOrderAmount;
  final int usageLimit;
  final int usedCount;
  final String startDate;
  final String endDate;
  final bool active;
  final String applicableProductType;

  Map<String, dynamic> getCouponData() {
    return {
      "code": code,
      "conten": content,
      "type": type,
      "discount_type": discountType,
      "discount_value": discountValue,
      "min_order_amount": minOrderAmount,
      "usage_limit": usageLimit,
      "used_count": usedCount,
      "start_date": startDate,
      "end_date": endDate,
      "active": active,
      "applicable_product_type": applicableProductType,
    };
  }
}
