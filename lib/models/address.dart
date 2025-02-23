class Address {
  const Address({
    required this.createAt,
    required this.phoneNumber,
    required this.name,
    required this.defaultAddress,
    required this.address,
    required this.provine,
    required this.district,
    required this.ward,
  });
  final DateTime createAt;
  final String phoneNumber;
  final String name;
  final bool defaultAddress;
  final String address;
  final String provine;
  final String district;
  final String ward;
  Map<String, dynamic> getAddressData() {
    return {
      "create_at": createAt,
      "phone_number": phoneNumber,
      "name": name,
      "default": defaultAddress,
      "address": address,
      "provine": provine,
      "district": district,
      "ward": ward,
    };
  }
}
