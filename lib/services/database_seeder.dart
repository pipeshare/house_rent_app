import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedInitialData() async {
    await _seedCategories();
    await _seedProfessionals();
    await _seedProperties();
  }

  static Future<void> _seedCategories() async {
    final categories = [
      {'name': 'Apartments', 'icon': 'apartment'},
      {'name': 'Houses', 'icon': 'house'},
      {'name': 'Offices', 'icon': 'business_center'},
      {'name': 'Shops', 'icon': 'storefront'},
      {'name': 'Warehouses', 'icon': 'warehouse'},
      {'name': 'Land', 'icon': 'terrain'},
      {'name': 'Short Let', 'icon': 'night_shelter'},
      {'name': 'Student Housing', 'icon': 'school'},
      {'name': 'Commercial', 'icon': 'store_mall_directory'},
      {'name': 'Industrial', 'icon': 'factory'},
    ];

    for (final category in categories) {
      await _firestore.collection('categories').add({
        ...category,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    log('✅ Categories seeded successfully');
  }

  static Future<void> _seedProfessionals() async {
    final professionals = [
      {
        'name': 'Sussane Stokholm',
        'specialty': 'Architect',
        'imageUrl':
            'https://images.unsplash.com/photo-1494790108755-2616b612b786'
      },
      {
        'name': 'Design Masters Ltd',
        'specialty': 'Design Firm',
        'imageUrl': 'https://images.unsplash.com/photo-1560250097-0b93528c311a'
      },
      {
        'name': 'Elite Interiors',
        'specialty': 'Interior Designers',
        'imageUrl':
            'https://images.unsplash.com/photo-1580489944761-15a19d654956'
      },
      {
        'name': 'Build Right Contractors',
        'specialty': 'General Contractors',
        'imageUrl':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d'
      },
      {
        'name': 'Dream Homes Ltd',
        'specialty': 'Home Builders',
        'imageUrl':
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e'
      },
    ];

    for (final professional in professionals) {
      await _firestore.collection('professionals').add({
        ...professional,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    log('✅ Professionals seeded successfully');
  }

  static Future<void> _seedProperties() async {
    final properties = [
      {
        'title': 'Modern 2-Bedroom Apartment in Salama Park',
        'description':
            'Spacious apartment with stunning city views. Features include modern kitchen, en-suite bathrooms, balcony, and 24/7 security.',
        'category': 'Apartments',
        'location': 'Salama Park, Lusaka',
        'price': 9500,
        'images': [
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2',
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',
        ],
        'bedrooms': 2,
        'bathrooms': 2,
        'area': 85,
        'amenities': ['Parking', 'Security', 'Balcony', 'Fitted Kitchen'],
      },
      {
        'title': 'Luxury 4-Bedroom House in Woodlands',
        'description':
            'Beautiful executive home with swimming pool and large garden. Perfect for families with modern finishes throughout.',
        'category': 'Houses',
        'location': 'Woodlands, Lusaka',
        'price': 25000,
        'images': [
          'https://images.unsplash.com/photo-1518780664697-55e3ad937233',
          'https://images.unsplash.com/photo-1570129477492-45c003edd2be',
          'https://images.unsplash.com/photo-1613977257363-707ba9348227',
        ],
        'bedrooms': 4,
        'bathrooms': 3,
        'area': 250,
        'amenities': ['Swimming Pool', 'Garden', 'Parking', 'Security'],
      },
      {
        'title': 'Prime Office Space in CBD',
        'description':
            'Fully furnished office space in central business district. Ideal for startups and established businesses.',
        'category': 'Offices',
        'location': 'Central Business District, Lusaka',
        'price': 15000,
        'images': [
          'https://images.unsplash.com/photo-1497366754035-f200968a6e72',
          'https://images.unsplash.com/photo-1497366216548-37526070297c',
          'https://images.unsplash.com/photo-1551601651-2a8555f1a136',
        ],
        'bedrooms': 0,
        'bathrooms': 2,
        'area': 120,
        'amenities': ['Furnished', 'Internet', 'Parking', 'Meeting Rooms'],
      },
      {
        'title': 'Corner Shop in Northmead',
        'description':
            'Perfect location for retail business. High foot traffic and visibility in busy commercial area.',
        'category': 'Shops',
        'location': 'Northmead, Lusaka',
        'price': 8000,
        'images': [
          'https://images.unsplash.com/photo-1563013546-31d134b64ef9',
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8',
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8',
        ],
        'bedrooms': 0,
        'bathrooms': 1,
        'area': 45,
        'amenities': ['Storage Room', 'Toilet', 'Security Grill'],
      },
      {
        'title': '2-Acre Residential Plot in Chongwe',
        'description':
            'Prime land for residential development. All services available at plot boundary with clear title deeds.',
        'category': 'Land',
        'location': 'Chongwe, Lusaka',
        'price': 150000,
        'images': [
          'https://images.unsplash.com/photo-1500382017468-9049fed747ef',
          'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09',
          'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09',
        ],
        'bedrooms': 0,
        'bathrooms': 0,
        'area': 8000,
        'amenities': ['Serviced Plot', 'Title Deeds', 'Road Access'],
      },
      {
        'title': 'Cozy 1-Bedroom in Kamwala',
        'description':
            'Affordable living in convenient location. Perfect for singles or couples starting out.',
        'category': 'Apartments',
        'location': 'Kamwala, Lusaka',
        'price': 4500,
        'images': [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
          'https://images.unsplash.com/photo-1555854877-bab0e564b8d5',
          'https://images.unsplash.com/photo-1529408632839-a54952c491e5',
        ],
        'bedrooms': 1,
        'bathrooms': 1,
        'area': 55,
        'amenities': ['Security', 'Water', 'Electricity'],
      },
      {
        'title': 'Industrial Warehouse Space',
        'description':
            'Large warehouse space suitable for storage or light manufacturing with loading bay access.',
        'category': 'Warehouses',
        'location': 'Heavy Industrial Area, Lusaka',
        'price': 20000,
        'images': [
          'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d',
          'https://images.unsplash.com/photo-1581094794321-8410e6a536e1',
          'https://images.unsplash.com/photo-1581094794321-8410e6a536e1',
        ],
        'bedrooms': 0,
        'bathrooms': 1,
        'area': 500,
        'amenities': ['Loading Bay', 'Office Space', 'Security'],
      },
      {
        'title': 'Luxury Penthouse with Rooftop',
        'description':
            'Exclusive penthouse offering luxury living with private rooftop garden and panoramic city views.',
        'category': 'Apartments',
        'location': 'Longacres, Lusaka',
        'price': 35000,
        'images': [
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',
          'https://images.unsplash.com/photo-1513584684374-8bab748fbf90',
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',
        ],
        'bedrooms': 3,
        'bathrooms': 3,
        'area': 180,
        'amenities': ['Rooftop Garden', 'Pool', 'Gym', 'Concierge'],
      },
      {
        'title': '3-Bedroom Townhouse',
        'description':
            'Modern townhouse in gated community with shared amenities and secure parking.',
        'category': 'Houses',
        'location': 'Olympia Park, Lusaka',
        'price': 12000,
        'images': [
          'https://images.unsplash.com/photo-1513584684374-8bab748fbf90',
          'https://images.unsplash.com/photo-1570129477492-45c003edd2be',
          'https://images.unsplash.com/photo-1613977257363-707ba9348227',
        ],
        'bedrooms': 3,
        'bathrooms': 2,
        'area': 110,
        'amenities': ['Shared Pool', 'Security', 'Parking'],
      },
      {
        'title': 'Student Apartment Near UNZA',
        'description':
            'Furnished apartment perfect for students. Close to university and public transport.',
        'category': 'Student Housing',
        'location': 'Great East Road, Lusaka',
        'price': 3800,
        'images': [
          'https://images.unsplash.com/photo-1555854877-bab0e564b8d5',
          'https://images.unsplash.com/photo-1529408632839-a54952c491e5',
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
        ],
        'bedrooms': 1,
        'bathrooms': 1,
        'area': 40,
        'amenities': ['Furnished', 'Internet', 'Study Desk'],
      },
    ];

    for (final property in properties) {
      await _firestore.collection('posts').add({
        ...property,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': 'sample_user_${DateTime.now().millisecondsSinceEpoch}',
      });
    }
    log('✅ Properties seeded successfully');
  }
}
