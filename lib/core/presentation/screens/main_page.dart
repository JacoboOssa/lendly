// import 'package:flutter/material.dart';
// import 'package:lendly_app/features/publish/presentation/screens/home_screen.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:lendly_app/features/profile/presentation/bloc/get_current_user_bloc.dart';
// import 'package:lendly_app/features/profile/presentation/bloc/logout_bloc.dart';
// import 'package:lendly_app/features/profile/presentation/screens/profile_screen.dart';
// import 'package:lendly_app/main.dart';

// class MainPage extends StatefulWidget {
//   const MainPage({super.key});

//   @override
//   State<MainPage> createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   int _currentIndex = 0;
//   String? _userRole;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserRole();
//   }

//   Future<void> _loadUserRole() async {
//     try {
//       final userId = supabase.auth.currentUser?.id;
//       if (userId != null) {
//         final response = await supabase
//             .from('users_app')
//             .select('role')
//             .eq('id', userId)
//             .single();

//         if (mounted) {
//           setState(() {
//             _userRole = response['role'] as String?;
//           });
//         }
//       }
//     } catch (e) {
//       // Si hay error, simplemente no mostramos el botón
//       if (mounted) {
//         setState(() {
//           _userRole = null;
//         });
//       }
//     }
//   }

//   // Lista de pantallas para cada tab
//   final List<Widget> _screens = [
//     const HomeScreen(),
//     MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (_) => LogoutBloc()),
//         BlocProvider(create: (_) => GetCurrentUserBloc()),
//       ],
//       child: const ProfileScreen(),
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     // Determinar si el usuario es lender
//     final isLender = _userRole?.toLowerCase() == 'lender';

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: IndexedStack(index: _currentIndex, children: _screens),
//       bottomNavigationBar: Container(
//         height: 70,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildNavItem(icon: Icons.home, label: 'Inicio', index: 0),

//             // Botón de publicar solo para lenders
//             if (isLender)
//               InkWell(
//                 onTap: () => Navigator.pushNamed(context, '/publish'),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.add_circle,
//                         color: const AppColors.primary,
//                         size: 32,
//                       ),
//                       const SizedBox(height: 2),
//                       const Text(
//                         'Publicar',
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//             _buildNavItem(icon: Icons.person, label: 'Perfil', index: 1),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required IconData icon,
//     required String label,
//     required int index,
//   }) {
//     final isSelected = _currentIndex == index;
//     return InkWell(
//       onTap: () {
//         setState(() {
//           _currentIndex = index;
//         });
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               color: isSelected
//                   ? const AppColors.primary
//                   : const Color(0xFFBDBDBD),
//               size: 24,
//             ),
//             const SizedBox(height: 2),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 11,
//                 color: isSelected
//                     ? const AppColors.primary
//                     : const Color(0xFFBDBDBD),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
