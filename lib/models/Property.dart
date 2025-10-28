import 'dart:math';

enum PropertyType { apartment, house, office, studio, land }

class Property {
  final String id;
  final String title;
  final String location; // city or neighborhood
  final String address; // more specific location
  final List<String> images;
  final int beds;
  final int baths;
  final double area; // in sqm
  final double price;
  final bool rent; // true = rent, false = sale
  final bool featured;
  final bool available;
  final PropertyType type;
  final String tag; // e.g. "Hot", "New", "Reduced"

  const Property({
    required this.id,
    required this.title,
    required this.location,
    required this.address,
    required this.images,
    required this.beds,
    required this.baths,
    required this.area,
    required this.price,
    required this.rent,
    required this.featured,
    required this.available,
    required this.type,
    required this.tag,
  });

  // ---- MOCK GENERATOR ---- //
  static final _rand = Random();

  static final _sampleImages = [
    'https://images.unsplash.com/photo-1505692794403-34d4982d1e9d?w=1200',
    'https://images.unsplash.com/photo-1499914485622-a88fac536970?w=1200',
    'https://images.unsplash.com/photo-1479839672679-a46483c0e7c8?w=1200',
    'https://picsum.photos/400/300?image=1025',
    'https://picsum.photos/400/300?image=1005',
  ];

  static final _cities = [
    'Salama Park',
    'Ibex Hill',
    'Woodlands',
    'Olympia',
    'Roma'
  ];

  static final _tags = ['New', 'Hot', 'Reduced', 'Popular'];

  static Property mock(int i, {bool rent = true}) {
    final type = PropertyType.values[_rand.nextInt(PropertyType.values.length)];
    final city = _cities[i % _cities.length];

    return Property(
      id: 'prop_${DateTime.now().millisecondsSinceEpoch}_$i',
      title: [
        'Modern 2-Bed Apartment',
        'Cozy Family House',
        'Prime Office Space',
        'Stylish Studio',
        'Luxury Villa'
      ][i % 5],
      location: '$city, Lusaka',
      address: 'Plot ${_rand.nextInt(500)}, $city',
      images: List.generate(
          3, (_) => _sampleImages[_rand.nextInt(_sampleImages.length)]),
      beds: [1, 2, 3, 4][_rand.nextInt(4)],
      baths: [1, 2, 3][_rand.nextInt(3)],
      area: 40 + _rand.nextDouble() * 160,
      price: rent
          ? [9500, 12500, 8000, 17500][_rand.nextInt(4)].toDouble()
          : [130000, 220000, 98000, 350000][_rand.nextInt(4)].toDouble(),
      rent: rent,
      featured: _rand.nextBool(),
      available: _rand.nextBool(),
      type: type,
      tag: _tags[_rand.nextInt(_tags.length)],
    );
  }

  static List<Property> generate(int count, {bool rent = true}) =>
      List.generate(count, (i) => Property.mock(i, rent: rent));
}
