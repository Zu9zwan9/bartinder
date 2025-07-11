import '../../domain/entities/bar.dart';

/// Provides mock bar data for development and testing
class MockBarDataSource {
  /// Returns a list of mock bars
  List<Bar> getBars() {
    return [
      Bar(
        id: '1',
        name: 'Bierkraft',
        address: '123 Beer St, Downtown',
        latitude: 50.450001,
        longitude: 30.523333,
        distance: 1.2,
        photoUrl: 'https://images.unsplash.com/photo-1546726747-421c6d69c929',
        description: 'Craft beer paradise with over 50 taps and great food.',
        beerTypes: ['IPA', 'Stout', 'Lager', 'Sour'],
        hasDiscount: true,
        discountPercentage: 10,
        plannedVisitorsCount: 5,
        crowdLevel: 'High',
        usersHeadingThere: ['1', '3', '5'],
        events: [
          Event(
            id: '101',
            name: 'IPA Tasting Night',
            description:
                'Sample our new collection of IPAs from local breweries',
            startTime: DateTime.now().add(const Duration(hours: 2)),
            endTime: DateTime.now().add(const Duration(hours: 5)),
          ),
        ],
      ),
      Bar(
        id: '2',
        name: 'Bierhaus',
        address: '456 Ale Ave, Midtown',
        latitude: 50.447853,
        longitude: 30.524506,
        distance: 0.5,
        photoUrl:
            'https://images.unsplash.com/photo-1514933651103-005eec06c04b',
        description:
            'Authentic German beer hall with traditional food and music.',
        beerTypes: ['Pilsner', 'Hefeweizen', 'Dunkel', 'Bock'],
        hasDiscount: true,
        discountPercentage: 15,
        plannedVisitorsCount: 8,
        crowdLevel: 'Medium',
        usersHeadingThere: ['2', '4'],
        events: [
          Event(
            id: '201',
            name: 'Oktoberfest Celebration',
            description: 'Traditional German music, food, and beer specials',
            startTime: DateTime.now().add(const Duration(days: 1)),
            endTime: DateTime.now().add(const Duration(days: 1, hours: 8)),
          ),
        ],
      ),
      Bar(
        id: '3',
        name: 'The Pilsner Pub',
        address: '789 Hops Blvd, Uptown',
        latitude: 50.444029,
        longitude: 30.505902,
        distance: 2.0,
        photoUrl:
            'https://images.unsplash.com/photo-1485686531765-ba63b07845a7',
        description:
            'Specializing in Czech and German pilsners with beer-paired menu.',
        beerTypes: ['Pilsner', 'Lager', 'Kölsch'],
        hasDiscount: false,
        plannedVisitorsCount: 3,
        crowdLevel: 'Low',
        usersHeadingThere: [],
        events: [],
      ),
      Bar(
        id: '4',
        name: 'Dark Horse Brewery',
        address: '101 Malt Road, Eastside',
        latitude: 50.439541,
        longitude: 30.516233,
        distance: 1.8,
        photoUrl: 'https://images.unsplash.com/photo-1559526324-593bc073d938',
        description:
            'Local brewery specializing in dark beers and seasonal specialties.',
        beerTypes: ['Stout', 'Porter', 'Brown Ale', 'Black IPA'],
        hasDiscount: true,
        discountPercentage: 20,
        plannedVisitorsCount: 12,
        crowdLevel: 'High',
        usersHeadingThere: ['1', '2', '3', '5'],
        events: [
          Event(
            id: '401',
            name: 'Stout Showcase',
            description: 'Featuring our award-winning imperial stouts',
            startTime: DateTime.now().add(const Duration(hours: 1)),
            endTime: DateTime.now().add(const Duration(hours: 4)),
          ),
          Event(
            id: '402',
            name: 'Brewery Tour',
            description: 'Behind-the-scenes look at our brewing process',
            startTime: DateTime.now().add(const Duration(days: 2)),
            endTime: DateTime.now().add(const Duration(days: 2, hours: 2)),
          ),
        ],
      ),
      Bar(
        id: '5',
        name: 'Wheat & Hops',
        address: '202 Barley Lane, Westside',
        latitude: 50.435959,
        longitude: 30.508778,
        distance: 3.2,
        photoUrl: 'https://images.unsplash.com/photo-1555658636-6e4a36218be7',
        description: 'Cozy spot with board games and a focus on wheat beers.',
        beerTypes: [
          'Hefeweizen',
          'Witbier',
          'American Wheat',
          'Berliner Weisse',
        ],
        hasDiscount: false,
        plannedVisitorsCount: 4,
        crowdLevel: 'Medium',
        usersHeadingThere: ['4'],
        events: [
          Event(
            id: '501',
            name: 'Board Game Night',
            description: 'Bring friends for games and beer specials',
            startTime: DateTime.now().add(const Duration(days: 1, hours: 18)),
            endTime: DateTime.now().add(const Duration(days: 1, hours: 22)),
          ),
        ],
      ),
    ];
  }
}
