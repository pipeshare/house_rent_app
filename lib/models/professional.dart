import 'dart:math';

enum ProfessionalSpecialty {
  architect,
  agent,
  lawyer,
  contractor,
  broker,
  inspector
}

extension ProfessionalSpecialtyExtension on ProfessionalSpecialty {
  String get displayName {
    switch (this) {
      case ProfessionalSpecialty.architect:
        return 'Architect';
      case ProfessionalSpecialty.agent:
        return 'Agent';
      case ProfessionalSpecialty.lawyer:
        return 'Lawyer';
      case ProfessionalSpecialty.inspector:
        return 'Inspector';
      case ProfessionalSpecialty.broker:
        return 'Broker';
      case ProfessionalSpecialty.contractor:
        return 'Contractor';
    }
  }
}

class Professional {
  final String id;
  final String name;
  final String company;
  final ProfessionalSpecialty specialty;
  final double rating; // 0-5
  final bool verified;
  final String imageUrl;
  final int yearsExperience;
  final String phone;

  Professional({
    required this.id,
    required this.name,
    required this.company,
    required this.specialty,
    required this.rating,
    required this.verified,
    required this.imageUrl,
    required this.yearsExperience,
    required this.phone,
  });

  static final _rand = Random();
  static final List<String> _avatars = [
    'https://i.pravatar.cc/150?img=3',
    'https://i.pravatar.cc/150?img=5',
    'https://i.pravatar.cc/150?img=7',
    'https://i.pravatar.cc/150?img=12',
    'https://i.pravatar.cc/150?img=15',
  ];

  static Professional mock([int idx = 0]) {
    final specs = ProfessionalSpecialty.values;
    final spec = specs[_rand.nextInt(specs.length)];
    final name = [
      'Alex',
      'Sam',
      'Jordan',
      'Taylor',
      'Riley',
      'Morgan'
    ][_rand.nextInt(6)];
    final surname = [
      'Mwamba',
      'Kabwe',
      'Mwila',
      'Phiri',
      'Zimba',
      'Chanda'
    ][_rand.nextInt(6)];
    return Professional(
      id: 'pro-${DateTime.now().microsecondsSinceEpoch}-$idx',
      name: '$name $surname',
      company: [
        'BlueWorks',
        'HomeRight',
        'Zed Group',
        'UrbanX',
        'NestPro'
      ][_rand.nextInt(5)],
      specialty: spec,
      rating: (3.0 + _rand.nextDouble() * 2.0),
      verified: _rand.nextBool() && _rand.nextBool(),
      imageUrl: _avatars[_rand.nextInt(_avatars.length)],
      yearsExperience: _rand.nextInt(15) + 1,
      phone: '+26097${1000000 + _rand.nextInt(8999999)}',
    );
  }

  static List<Professional> generate(int count) =>
      List.generate(count, (i) => Professional.mock(i));
}
