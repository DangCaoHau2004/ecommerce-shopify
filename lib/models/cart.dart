class CartModel {
  const CartModel(
      {required this.colorSelectIndex,
      required this.purchaseQuantity,
      required this.id});
  final int purchaseQuantity;
  final int colorSelectIndex;
  final String id;
  Map<String, dynamic> getCart() {
    return {
      "purchase_quantity": purchaseQuantity,
      "color_select_index": colorSelectIndex,
      "id": id,
    };
  }
}
