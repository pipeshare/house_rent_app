import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:house_rent_app/models/professional.dart';

class ProfessionalsScreen extends StatefulWidget {
  const ProfessionalsScreen({super.key});

  @override
  State<ProfessionalsScreen> createState() => _ProfessionalsScreenState();
}

class _ProfessionalsScreenState extends State<ProfessionalsScreen> {
  final List<Professional> _professionals = Professional.generate(20);
  ProfessionalSpecialty? _selectedSpecialty;

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedSpecialty == null
        ? _professionals
        : _professionals
            .where((p) => p.specialty == _selectedSpecialty)
            .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Professionals'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSpecialtyFilters(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (_, index) =>
                  _ProfessionalCard(pro: filtered[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search professionals',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtyFilters() {
    return SizedBox(
      height: 48,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip(
            label: 'All',
            selected: _selectedSpecialty == null,
            onTap: () => setState(() => _selectedSpecialty = null),
          ),
          ...ProfessionalSpecialty.values.map(
            (s) => _filterChip(
              label: s.displayName,
              selected: _selectedSpecialty == s,
              onTap: () => setState(() => _selectedSpecialty = s),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: Colors.black,
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class _ProfessionalCard extends StatelessWidget {
  final Professional pro;

  const _ProfessionalCard({required this.pro});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // TODO: Navigate to professional profile
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _avatar(),
            const SizedBox(width: 12),
            Expanded(child: _details()),
          ],
        ),
      ),
    );
  }

  Widget _avatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        pro.imageUrl,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // 🔒 prevents overflow
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                pro.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            if (pro.verified)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.verified,
                  size: 16,
                  color: Colors.blue,
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          pro.specialty.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            RatingBarIndicator(
              rating: pro.rating,
              itemBuilder: (_, __) =>
                  const Icon(Icons.star, color: Colors.amber),
              itemSize: 14,
            ),
            const SizedBox(width: 6),
            Text(
              '(${pro.rating.toStringAsFixed(1)})',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${pro.yearsExperience} yrs experience',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
