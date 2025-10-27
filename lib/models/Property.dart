class Property {
  final String id;
  final String title;
  final String location;
  final List<String> images;
  final int beds;
  final int baths;
  final int size;
  final double price;
  final bool rent;
  final String tag;

  const Property({
    required this.id,
    required this.title,
    required this.location,
    required this.images,
    required this.beds,
    required this.baths,
    required this.size,
    required this.price,
    required this.rent,
    required this.tag,
  });

  static Property mock(int i, {bool rent = true}) {
    final city =
        ['Salama Park', 'Ibex Hill', 'Woodlands', 'Olympia', 'Roma'][i % 5];
    return Property(
      id: 'prop_$i',
      title: [
        'Modern 2-bed Apartment',
        'Cozy Family House',
        'Prime Office Space',
        'Stylish Studio'
      ][i % 4],
      location: '$city, Lusaka',
      images: [
        'https://images.unsplash.com/photo-1505692794403-34d4982d1e9d?w=1200',
        'https://images.unsplash.com/photo-1499914485622-a88fac536970?w=1200',
        'https://images.unsplash.com/photo-1479839672679-a46483c0e7c8?w=1200',
      ],
      beds: [2, 3, 1, 4][i % 4],
      baths: [1, 2, 1, 3][i % 4],
      size: [78, 120, 45, 210][i % 4],
      price: rent
          ? [9500, 12500, 8000, 17500][i % 4].toDouble()
          : [130000, 220000, 98000, 350000][i % 4].toDouble(),
      rent: rent,
      tag: ['New', 'Hot', 'Reduced', 'Popular'][i % 4],
    );
  }
}
