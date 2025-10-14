import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/profile/data/mock_data.dart';
import 'package:lendly_app/features/profile/presentation/bloc/logout_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<LogoutBloc, LogoutState>(
          builder: (context, state) {
            if (state is LogoutSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, '/login');
              });
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
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

                            // Avatar
                            Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                color: Color(0xFF9C88FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'MS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Nombre y correo
                            Text(
                              MockUserData.userName,
                              style: const TextStyle(
                                color: Color(0xFF2C2C2C),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              MockUserData.userEmail,
                              style: const TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 32),

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
                              onTap: () {},
                            ),
                            const SizedBox(height: 16),
                            _buildMenuOption(
                              icon: Icons.settings_outlined,
                              text: 'Configuración',
                              onTap: () {},
                            ),
                            const SizedBox(height: 16),
                            _buildMenuOption(
                              icon: Icons.message_outlined,
                              text: 'Mensajes',
                              onTap: () {},
                            ),
                            const SizedBox(height: 16),
                            _buildMenuOption(
                              icon: Icons.star_outline,
                              text: 'Califícanos',
                              onTap: () {},
                            ),
                            const SizedBox(height: 16),
                            _buildMenuOption(
                              icon: Icons.info_outline,
                              text: 'Acerca de',
                              onTap: () {},
                            ),
                            const SizedBox(height: 40),

                            // Botón de cerrar sesión
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: state is LogoutLoading
                                    ? null
                                    : () {
                                        context.read<LogoutBloc>().add(
                                          SubmitLogoutEvent(),
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF555879),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: state is LogoutLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Cerrar sesión',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),

                            if (state is LogoutError)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  state.message,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: const Color(0xFF2C2C2C), size: 20),
              ),
              const SizedBox(width: 12),
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
