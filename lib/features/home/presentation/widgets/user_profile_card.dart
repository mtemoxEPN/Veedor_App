import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';

class UserProfileCard extends StatelessWidget {
  final UserEntity user;

  const UserProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    String getInitials() {
      if (user.nombres.isEmpty) return '??';
      final names = user.nombres.trim().split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return names[0].substring(0, names[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    String getRoleText() {
      switch (user.rol) {
        case 'provincial':
          return 'Coordinador Provincial';
        case 'recinto':
          return 'Coordinador de Recinto';
        case 'veedor':
        default:
          return 'Veedor';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHigh.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              getInitials(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.nombres} ${user.apellidos}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.badge_outlined, 'C.I.: ${user.cedula}'),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.manage_accounts_outlined, getRoleText()),
                const SizedBox(height: 6),
                if (user.rol == 'provincial')
                  _buildInfoRow(Icons.map_outlined, 'Provincia: Pichincha')
                else if (user.recintoId != null)
                  _buildInfoRow(Icons.business_outlined, 'Recinto Asignado'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
