import 'package:flutter/material.dart';
import 'package:lendly_app/features/profile/data/mock_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C), // Fondo gris oscuro
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Card principal blanco
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA), // Off-white
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Botón de regreso
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: Color(0xFF2C2C2C),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Avatar circular
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9C88FF), // Púrpura claro
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Nombre del usuario
                        Text(
                          MockUserData.userName,
                          style: const TextStyle(
                            color: Color(0xFF2C2C2C),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Email del usuario
                        Text(
                          MockUserData.userEmail,
                          style: const TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Línea separadora delgada
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: const Color(0xFFE0E0E0),
                        ),
                        const SizedBox(height: 32),
                        
                        // Opciones del menú
                        _buildMenuOption(
                          icon: Icons.person_outline,
                          text: 'Información personal',
                          onTap: () {
                            print('Información personal');
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        _buildMenuOption(
                          icon: Icons.settings_outlined,
                          text: 'Configuración',
                          onTap: () {
                            print('Configuración');
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        _buildMenuOption(
                          icon: Icons.message_outlined,
                          text: 'Mensajes',
                          onTap: () {
                            print('Mensajes');
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        _buildMenuOption(
                          icon: Icons.message_outlined,
                          text: 'Mensajes',
                          onTap: () {
                            print('Mensajes');
                          },
                        ),
                        
                        const Spacer(),
                        
                        // Botón de cerrar sesión
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              print('Cerrar sesión');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF555879), // Color exacto solicitado
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cerrar sesion',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Icono en contenedor redondeado
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2C2C2C),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Texto
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF2C2C2C),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              // Flecha hacia la derecha
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF9E9E9E),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
