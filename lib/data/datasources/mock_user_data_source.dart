import '../../domain/entities/user.dart';

/// Provides mock user data for development and testing
class MockUserDataSource {
  /// Returns a list of mock user profiles
  List<User> getUsers() {
    return [
      const User(
        id: '1',
        name: 'Olena',
        age: 28,
        photoUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
        favoriteBeer: 'NEIPA & Gose',
        bio: 'Down for a pint tonight. Got some smoked cheese, too.',
        lastCheckedInLocation: 'Bierkraft',
        lastCheckedInDistance: 1.2,
        beerPreferences: ['IPA', 'Sour', 'Craft'],
      ),
      const User(
        id: '2',
        name: 'Ihor',
        age: 32,
        photoUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
        favoriteBeer: 'Belgian Tripel',
        bio: 'Beer enthusiast with a passion for local breweries.',
        lastCheckedInLocation: 'Bierhaus',
        lastCheckedInDistance: 0.5,
        beerPreferences: ['Belgian', 'Tripel', 'Wheat'],
      ),
      const User(
        id: '3',
        name: 'Natalia',
        age: 26,
        photoUrl: 'https://randomuser.me/api/portraits/women/3.jpg',
        favoriteBeer: 'Pilsner',
        bio: 'Looking for beer buddies to explore new pubs.',
        lastCheckedInLocation: 'The Pilsner Pub',
        lastCheckedInDistance: 2.0,
        beerPreferences: ['Lager', 'Pilsner', 'Light'],
      ),
      const User(
        id: '4',
        name: 'Taras',
        age: 30,
        photoUrl: 'https://randomuser.me/api/portraits/men/4.jpg',
        favoriteBeer: 'Imperial Stout',
        bio: 'Craft beer collector. Let\'s share a flight!',
        lastCheckedInLocation: 'Dark Horse Brewery',
        lastCheckedInDistance: 1.8,
        beerPreferences: ['Stout', 'Porter', 'Dark'],
      ),
      const User(
        id: '5',
        name: 'Oksana',
        age: 29,
        photoUrl: 'https://randomuser.me/api/portraits/women/5.jpg',
        favoriteBeer: 'Hefeweizen',
        bio: 'Beer and board games - perfect evening!',
        lastCheckedInLocation: 'Wheat & Hops',
        lastCheckedInDistance: 3.2,
        beerPreferences: ['Wheat', 'Hefeweizen', 'German'],
      ),
    ];
  }
}
