class CartModel {
  CartModel(
      {required this.colorSelectIndex,
      required this.purchaseQuantity,
      required this.id});
  int purchaseQuantity;
  int colorSelectIndex;
  final String id;
  Map<String, dynamic> getCart() {
    return {
      "purchase_quantity": purchaseQuantity,
      "color_select_index": colorSelectIndex,
      "id": id,
    };
  }
}
