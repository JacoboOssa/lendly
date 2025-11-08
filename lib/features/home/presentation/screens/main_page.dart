import 'package:flutter/material.dart';
import 'package:lendly_app/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/profile/presentation/bloc/get_current_user_bloc.dart';
import 'package:lendly_app/features/profile/presentation/bloc/logout_bloc.dart';
import 'package:lendly_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:lendly_app/features/home/presentation/bloc/get_user_role_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Disparar el evento para cargar el rol del usuario
    context.read<GetUserRoleBloc>().add(GetUserRole());
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Lista de pantallas para cada tab
  final List<Widget> _screens = [
    const HomeScreen(),
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LogoutBloc()),
        BlocProvider(create: (_) => GetCurrentUserBloc()),
      ],
      child: const ProfileScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GetUserRoleBloc, GetUserRoleState>(
      listener: (context, state) {
        // No necesitamos listener por ahora
      },
      builder: (context, state) {
        // Determinar si el usuario es lender
        final isLender =
            state is GetUserRoleSuccess && state.role.toLowerCase() == 'lender';

        return Scaffold(
          backgroundColor: Colors.white,
          body: IndexedStack(index: _currentIndex, children: _screens),
          bottomNavigationBar: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(icon: Icons.home, label: 'Inicio', index: 0),

                // Botón de publicar solo para lenders
                if (isLender)
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/publish'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle,
                            color: const Color(0xFF98A1BC),
                            size: 32,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Publicar',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF98A1BC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                _buildNavItem(icon: Icons.person, label: 'Perfil', index: 1),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabChanged(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF5B5670)
                  : const Color(0xFFBDBDBD),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? const Color(0xFF5B5670)
                    : const Color(0xFFBDBDBD),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
