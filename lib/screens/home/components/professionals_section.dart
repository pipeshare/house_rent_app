import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:house_rent_app/core/helpers.dart';
import 'package:house_rent_app/models/Professional.dart';

class ProfessionalsSection extends StatelessWidget {
  final List<Professional> professionals;

  const ProfessionalsSection({
    super.key,
    required this.professionals,
  });

  @override
  Widget build(BuildContext context) {
    if (professionals.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Text(
                'Find a Professional',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Text(
                'See more >',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Divider(height: 1),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: professionals.length,
            itemBuilder: (context, index) {
              return _buildProfessionalCard(professionals[index]);
            },
          ),
        ),
        const SizedBox(height: 4),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildProfessionalCard(Professional professional) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          const SizedBox(height: 15),
          // Profile Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              color: Colors.grey[200],
              border: Border.all(
                color:
                    professional.verified ? Colors.green : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: professional.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: professional.imageUrl,
                      fit: BoxFit.cover,
                      cacheManager: CustomCacheManager(),
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
            ),
          ),
          const SizedBox(height: 8),

          // Name
          Text(
            professional.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Company
          Text(
            professional.company,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Specialty
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getSpecialtyColor(professional.specialty),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              professional.specialty.displayName,
              style: const TextStyle(
                fontSize: 8,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 10, color: Colors.amber),
              const SizedBox(width: 2),
              Text(
                professional.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSpecialtyColor(ProfessionalSpecialty specialty) {
    switch (specialty) {
      case ProfessionalSpecialty.agent:
        return Colors.blue;
      case ProfessionalSpecialty.broker:
        return Colors.green;
      case ProfessionalSpecialty.lawyer:
        return Colors.purple;
      case ProfessionalSpecialty.inspector:
        return Colors.orange;
      case ProfessionalSpecialty.architect:
        return Colors.teal;
    }
  }
}
