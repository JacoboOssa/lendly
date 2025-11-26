import 'package:flutter/material.dart';
import 'package:lendly_app/core/utils/app_colors.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  final Function(String) onUserTypeSelected;

  const UserTypeSelectionScreen({super.key, required this.onUserTypeSelected});

  @override
  State<UserTypeSelectionScreen> createState() =>
      _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  String? selectedUserType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Título principal
        const Text(
          'Regístrate para',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 16),
        // Logo de Lendly
        Image.asset('assets/lendlymorado.png', height: 60, fit: BoxFit.contain),
        const SizedBox(height: 24),

        // Pregunta descriptiva
        const Text(
          '¿Quieres publicar tus objetos o alquilar objetos de otros?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF6D6D6D)),
        ),
        const SizedBox(height: 40),

        // Tarjetas de selección
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tarjeta de Propietario
            _buildUserTypeCard(
              title: 'Soy un propietario',
              description: 'Quiero publicar mis objetos',
              avatars: [Icons.home_work, Icons.inventory, Icons.attach_money],
              isSelected: selectedUserType == 'lender',
              onTap: () => setState(() => selectedUserType = 'lender'),
            ),
            const SizedBox(height: 20),

            // Tarjeta de Arrendatario
            _buildUserTypeCard(
              title: 'Soy un arrendatario',
              description: 'Quiero alquilar objetos de otros',
              avatars: [Icons.person, Icons.shopping_bag, Icons.search],
              isSelected: selectedUserType == 'borrower',
              onTap: () => setState(() => selectedUserType = 'borrower'),
            ),
          ],
        ),

        const SizedBox(height: 40),

        // Botón continuar
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedUserType != null
                  ? AppColors.primary
                  : Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: selectedUserType != null ? _continueToNextStep : null,
            child: const Text(
              'Continuar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeCard({
    required String title,
    required String description,
    required List<IconData> avatars,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Iconos de avatar
            Row(
              children: avatars
                  .map(
                    (icon) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(width: 16),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6D6D6D),
                    ),
                  ),
                ],
              ),
            ),

            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected
                    ? AppColors.primary
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _continueToNextStep() {
    if (selectedUserType != null) {
      widget.onUserTypeSelected(selectedUserType!);
    }
  }
}
