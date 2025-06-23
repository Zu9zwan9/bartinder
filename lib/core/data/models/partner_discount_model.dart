class PartnerDiscountModel {
  final String id;
  final String userId;
  final String barId;
  final bool redeemed;
  final int? discount;
  final DateTime? validUntil;

  PartnerDiscountModel({
    required this.id,
    required this.userId,
    required this.barId,
    required this.redeemed,
    this.discount,
    this.validUntil,
  });

  factory PartnerDiscountModel.fromMap(Map<String, dynamic> map) {
    return PartnerDiscountModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      barId: map['bar_id'] as String,
      redeemed: map['redeemed'] as bool,
      discount: map['discount'] as int?,
      validUntil: map['valid_until'] != null
          ? DateTime.parse(map['valid_until'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'bar_id': barId,
      'redeemed': redeemed,
      'discount': discount,
      'valid_until': validUntil?.toIso8601String(),
    };
  }
}
