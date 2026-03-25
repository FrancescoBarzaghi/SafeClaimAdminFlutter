import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart'; // dashboard

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool rememberMe = false;
  bool hidePassword = true;
  bool isLoading = false;

  // FUNZIONE DI LOGIN SIMULATA (SENZA SERVER)
  Future<void> _loginAdmin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // 1. Controllo campi vuoti
    if (email.isEmpty || password.isEmpty) {
      _mostraErrore("Inserisci email e password");
      return;
    }

    setState(() {
      isLoading = true; // Mostriamo la rotellina di caricamento
    });

    try {
      // 2. Simuliamo il tempo di attesa di un server vero (1.5 secondi)
      await Future.delayed(const Duration(milliseconds: 1500));

      // 3. Controllo manuale delle credenziali (le stesse del tuo auth.py)
      if (email == "admin@safeclaim.it" && password == "admin123") {
        
        // Login effettuato con successo! Creiamo un token finto.
        final String fintoToken = "token_simulato_admin_999";
        
        final prefs = await SharedPreferences.getInstance();

        // Controllo della spunta "Ricordami"
        if (rememberMe) {
          await prefs.setString('admin_token', fintoToken);
        } else {
          await prefs.remove('admin_token');
        }

        if (!mounted) return;

        // Naviga alla Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardPage(),
          ),
        );
      } else {
        // Credenziali sbagliate
        _mostraErrore("Credenziali non valide. Riprova.");
      }
    } catch (e) {
      _mostraErrore("Si è verificato un errore imprevisto.");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Fermiamo la rotellina
        });
      }
    }
  }

  void _mostraErrore(String messaggio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(messaggio),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 145, 218),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 380,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 25,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Accedi',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Inserisci le tue credenziali',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // EMAIL
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'admin@safeclaim.it',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // PASSWORD
                TextField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // RICORDAMI E PASSWORD DIMENTICATA
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value!;
                        });
                      },
                    ),
                    const Text('Ricordami'),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Password dimenticata?'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // BOTTONE LOGIN
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 17, 76, 204),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading ? null : _loginAdmin,
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Accedi',
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