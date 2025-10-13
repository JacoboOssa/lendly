import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C), // Fondo gris oscuro
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header "Login" en la parte superior izquierda
              const Text(
                'Login',
                style: TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              
              // Card principal blanco
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Título "Inicia sesión"
                        const Text(
                          'Inicia sesión',
                          style: TextStyle(
                            color: Color(0xFF2C2C2C),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Campo de email
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5), // Beige claro
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: 'Correo electronico',
                              hintStyle: TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Campo de contraseña
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5), // Beige claro
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Contraseña',
                              hintStyle: TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Botón Continuar
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              // Lógica de login
                              print('Email: ${_emailController.text}');
                              print('Password: ${_passwordController.text}');
                              // Navegar a la pantalla de profile
                              Navigator.pushNamed(context, '/profile');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF98A1BC), // Color exacto solicitado
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
                        const SizedBox(height: 16),
                        
                        // Link para crear cuenta
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(text: '¿No tienes cuenta aun? '),
                              TextSpan(
                                text: 'Crea una',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C2C2C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Botones de redes sociales
                        _buildSocialButton(
                          icon: Icons.apple,
                          text: 'Continua con Apple',
                          onTap: () {
                            print('Login with Apple');
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        _buildSocialButton(
                          icon: Icons.g_mobiledata,
                          text: 'Continua con Google',
                          onTap: () {
                            print('Login with Google');
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        _buildSocialButton(
                          icon: Icons.facebook,
                          text: 'Continua con Facebook',
                          onTap: () {
                            print('Login with Facebook');
                          },
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

  Widget _buildSocialButton({
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
          color: const Color(0xFFF5F5F5), // Beige claro
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              icon,
              color: icon == Icons.apple 
                  ? Colors.black 
                  : icon == Icons.g_mobiledata 
                      ? const Color(0xFF4285F4) 
                      : const Color(0xFF1877F2),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFF2C2C2C),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
