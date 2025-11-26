import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/features/profile/presentation/bloc/logout_bloc.dart';
import 'package:lendly_app/features/profile/presentation/bloc/get_current_user_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Llama al bloc para obtener el usuario apenas se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetCurrentUserBloc>().add(GetCurrentUser());
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            // Escuchar cuando el logout sea exitoso
            BlocListener<LogoutBloc, LogoutState>(
              listener: (context, state) {
                if (state is LogoutSuccess) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
          child: BlocBuilder<GetCurrentUserBloc, GetCurrentUserState>(
            builder: (context, userState) {
              if (userState is GetCurrentUserError) {
                return Center(
                  child: Text(
                    'Error: ${userState.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (userState is GetCurrentUserSuccess) {
                final AppUser user = userState.user;

                return _buildProfile(context, user);
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, AppUser user) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
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
                          onTap: () => Navigator.pop(context),
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
                      child: Center(
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nombre y correo reales
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Color(0xFF2C2C2C),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email,
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

                    if (user.role.toLowerCase() == 'lender') ...[
                      const SizedBox(height: 16),
                      _buildMenuOption(
                        icon: Icons.inventory_2_outlined,
                        text: 'Gestionar mis productos',
                        onTap: () {
                          Navigator.pushNamed(context, '/manage-products');
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuOption(
                        icon: Icons.inbox_outlined,
                        text: 'Solicitudes recibidas',
                        onTap: () {
                          Navigator.pushNamed(context, '/offers-received');
                        },
                      ),
                    ],
                    if (user.role.toLowerCase() == 'borrower') ...[
                      const SizedBox(height: 16),
                      _buildMenuOption(
                        icon: Icons.send_outlined,
                        text: 'Mis solicitudes',
                        onTap: () {
                          Navigator.pushNamed(context, '/offers-sent');
                        },
                      ),
                    ],

                    // const SizedBox(height: 16),
                    // _buildMenuOption(
                    //   icon: Icons.inventory_2_outlined,
                    //   text: 'Gestionar disponibilidad',
                    //   onTap: () {
                    //     Navigator.pushNamed(context, '/manage-availability');
                    //   },
                    // ),
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

                    // Botón de logout
                    BlocBuilder<LogoutBloc, LogoutState>(
                      builder: (context, logoutState) {
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: logoutState is LogoutLoading
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
                            child: logoutState is LogoutLoading
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
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
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
