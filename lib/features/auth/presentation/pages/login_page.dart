import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'change_password_page.dart';
import '../../../home/presentation/pages/home_router_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _cedulaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingreso - Veedor Electoral')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is AuthRequiresPasswordChange) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => HomeRouterPage(user: state.user)),
            );
          } else if (state is AuthRecoveryEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _cedulaController,
                    decoration: const InputDecoration(labelText: 'Cédula', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Ingrese su cédula' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? 'Ingrese su contraseña' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                              LoginRequestedEvent(
                                _cedulaController.text,
                                _passwordController.text,
                              ),
                            );
                      }
                    },
                    child: const Text('Iniciar Sesión'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      _showRecoverPasswordDialog(context);
                    },
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRecoverPasswordDialog(BuildContext context) {
    final cedulaRecoveryController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Recuperar Contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ingresa tu cédula y enviaremos un enlace de recuperación a tu correo electrónico.'),
              const SizedBox(height: 16),
              TextField(
                controller: cedulaRecoveryController,
                decoration: const InputDecoration(labelText: 'Cédula', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (cedulaRecoveryController.text.isNotEmpty) {
                  context.read<AuthBloc>().add(RecoverPasswordRequestedEvent(cedulaRecoveryController.text));
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Enviar Enlace'),
            )
          ],
        );
      },
    );
  }
}
