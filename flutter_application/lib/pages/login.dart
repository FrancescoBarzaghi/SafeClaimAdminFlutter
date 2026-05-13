import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../services/auth_service.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  final AuthService _authService = AuthService();

  // Controller per recuperare il testo inserito dall'utente
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _mostraErrore("Per favore, inserisci sia l'email che la password.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Chiamata al nuovo metodo login nel tuo AuthService
      bool success = await _authService.login(email, password);

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      } else {
        _mostraErrore("Credenziali non valide. Riprova.");
      }
    } catch (e) {
      // MODIFICA QUI: Rimuoviamo la dicitura "Exception: " per mostrare un messaggio pulito all'utente
      // Così se non è admin vedrà esattamente: "Accesso negato: non hai i permessi di amministratore."
      _mostraErrore(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _mostraErrore(String messaggio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(messaggio),
        backgroundColor: SafeClaimColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafeClaimColors.background,
      body: Center(
        child: SingleChildScrollView(
          // Aggiunto per evitare overflow con la tastiera
          child: Container(
            width: 380,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            decoration: BoxDecoration(
              color: SafeClaimColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: SafeClaimColors.primaryLight),
              boxShadow: [
                BoxShadow(
                  color: SafeClaimColors.foreground.withValues(alpha: 0.10),
                  blurRadius: 25,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'SafeClaim Admin',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: SafeClaimColors.foreground,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Inserisci le tue credenziali per accedere',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: SafeClaimColors.textMuted,
                  ),
                ),
                const SizedBox(height: 30),

                // CAMPO EMAIL
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email o Username',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 20),

                // CAMPO PASSWORD
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 30),

                // BOTTONE ACCEDI
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'ACCEDI ORA',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
