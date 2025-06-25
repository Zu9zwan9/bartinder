class BarBeerModel {
  final String barId;
  final String beerId;

  BarBeerModel({required this.barId, required this.beerId});

  factory BarBeerModel.fromMap(Map<String, dynamic> map) {
    return BarBeerModel(
      barId: map['bar_id'] as String,
      beerId: map['beer_id'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'bar_id': barId, 'beer_id': beerId};
  }
}
