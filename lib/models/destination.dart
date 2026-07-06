class Destination {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final int price;
  final String description;
  final List<String> categories;

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.price,
    required this.description,
    required this.categories,
  });
}

// Global list for destinations to be used by admin screen and other parts
List<Destination> globalDestinations = [
  Destination(
    id: '1',
    name: 'Air Terjun Dlundung',
    location: 'Kab. Mojokerto',
    imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=500&q=80',
    rating: 4.8,
    price: 15000,
    description: 'Wisata alam air terjun yang indah dan menyejukkan.',
    categories: ['Alam'],
  ),
];