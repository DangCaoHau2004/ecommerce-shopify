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
      required this.applicableProductType,
      required this.id});
  final String code;
  final String content;
  final String type;
  final String discountType;
  final int discountValue;
  final int minOrderAmount;
  final int usageLimit;
  final int usedCount;
  final DateTime startDate;
  final DateTime endDate;
  final String id;
  final bool active;
  final String applicableProductType;
// có 2 trường hợp xóa code 1 là sau khi đã hết hạn, 2 là ko tồn tại
// ko xóa code sau khi đã sử dụng
// chỉ có thể add code cho user sau khi đã active và code còn hiệu lực
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
