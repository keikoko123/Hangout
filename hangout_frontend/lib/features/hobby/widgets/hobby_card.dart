import 'package:flutter/material.dart';
import 'package:hangout_frontend/features/hobbyEvenbt/pages/hobby_event_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HobbyCard extends StatelessWidget {
  final String icon;
  final String headerText;
  final String descriptionText;
  final String category;
  final String costLevel;
  final String indoorOutdoor;
  final String socialLevel;
  final int popularity;
  final double? mbtiMatchScore;
  final String id;
  // final List<String> equipment;

  const HobbyCard({
    super.key,
    required this.icon,
    required this.headerText,
    required this.descriptionText,
    required this.category,
    required this.costLevel,
    required this.indoorOutdoor,
    required this.socialLevel,
    required this.popularity,
    this.mbtiMatchScore,
    required this.id,
    // required this.equipment,
  });

  Future<void> _getHobbyEvents(BuildContext context) async {
    try {
      Navigator.of(context).push(
        HobbyEventPage.route(hobbyId: id),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _getHobbyEvents(context),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _getCategoryColor(category),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    icon,
                    style: const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headerText,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        '$popularity%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (mbtiMatchScore != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getMbtiMatchColor(mbtiMatchScore!),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.psychology,
                            size: 16, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          '${mbtiMatchScore!.toInt()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 15),
            Text(
              descriptionText,
              style: const TextStyle(
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoBadge(
                  icon: Icons.paid,
                  label: _formatCostLevel(costLevel),
                ),
                _buildInfoBadge(
                  icon: _getIndoorOutdoorIcon(indoorOutdoor),
                  label: _formatIndoorOutdoor(indoorOutdoor),
                ),
                _buildInfoBadge(
                  icon: _getSocialLevelIcon(socialLevel),
                  label: _formatSocialLevel(socialLevel),
                ),
              ],
            ),
            // if (equipment.isNotEmpty) ...[
            //   const SizedBox(height: 15),
            //   const Text(
            //     "Equipment:",
            //     style: TextStyle(
            //       fontWeight: FontWeight.bold,
            //       fontSize: 14,
            //     ),
            //   ),
            //   const SizedBox(height: 5),
            //   Wrap(
            //     spacing: 8,
            //     children: equipment
            //         .take(3)
            //         .map((e) => Chip(
            //               label: Text(
            //                 e,
            //                 style: const TextStyle(fontSize: 12),
            //               ),
            //               backgroundColor: Colors.white.withOpacity(0.3),
            //               visualDensity: VisualDensity.compact,
            //             ))
            //         .toList(),
            //   ),
            //   if (equipment.length > 3)
            //     Text(
            //       "+${equipment.length - 3} more",
            //       style: TextStyle(
            //         fontSize: 12,
            //         color: Colors.black.withOpacity(0.7),
            //         fontStyle: FontStyle.italic,
            //       ),
            //     ),
            // ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCostLevel(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return 'Low Cost';
      case 'medium':
        return 'Medium Cost';
      case 'high':
        return 'High Cost';
      default:
        return level;
    }
  }

  String _formatIndoorOutdoor(String type) {
    switch (type.toLowerCase()) {
      case 'indoor':
        return 'Indoor';
      case 'outdoor':
        return 'Outdoor';
      case 'both':
        return 'In/Outdoor';
      default:
        return type;
    }
  }

  String _formatSocialLevel(String level) {
    switch (level.toLowerCase()) {
      case 'solo':
        return 'Solo';
      case 'group':
        return 'Group';
      case 'either':
        return 'Solo/Group';
      default:
        return level;
    }
  }

  IconData _getIndoorOutdoorIcon(String type) {
    switch (type.toLowerCase()) {
      case 'indoor':
        return Icons.home;
      case 'outdoor':
        return Icons.nature_people;
      case 'both':
        return Icons.compare_arrows;
      default:
        return Icons.help_outline;
    }
  }

  IconData _getSocialLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'solo':
        return Icons.person;
      case 'group':
        return Icons.groups;
      case 'either':
        return Icons.people_alt_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'visual arts':
        return Colors.red[200]!;
      case 'sport':
        return Colors.blue[200]!;
      case 'performance':
        return Colors.purple[200]!;
      case 'gaming':
        return Colors.green[200]!;
      case 'creation':
        return Colors.yellow[200]!;
      case 'relaxation':
        return Colors.teal[200]!;
      default:
        return Colors.grey[300]!;
    }
  }

  Color _getMbtiMatchColor(double score) {
    if (score >= 75) {
      return Colors.green[600]!;
    } else if (score >= 50) {
      return Colors.blue[600]!;
    } else if (score >= 25) {
      return Colors.orange[600]!;
    } else {
      return Colors.red[600]!;
    }
  }
}
