import 'dart:convert';
import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../services/api_service.dart';

class NewAccountPage extends StatefulWidget {
  const NewAccountPage({super.key});

  @override
  State<NewAccountPage> createState() => _NewAccountPageState();
}

class _NewAccountPageState extends State<NewAccountPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomeController =
      TextEditingController();

  final TextEditingController cognomeController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();
      
  final TextEditingController telefonoController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool obscurePassword = true;

  bool admin = false;
  bool soccorso = false;
  bool officina = true;
  bool perito = false;

  bool loading = false;
  
  final ApiService _apiService = ApiService();

  /// CREAZIONE ACCOUNT - Usa ApiService con endpoint HTTPS
  Future<void> createAccount() async {
    setState(() {
      loading = true;
    });

    try {
      final response = await _apiService.post(
        '/create_account',
        {
          "nome": nomeController.text.trim(),
          "cognome": cognomeController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "telefono": telefonoController.text.trim(),
          "roles": {
            "admin": admin,
            "soccorso": soccorso,
            "officina": officina,
            "perito": perito,
          }
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data["message"] ??
                  "Account creato correttamente"),
              backgroundColor: Colors.green,
            ),
          );
        }

        /// RESET CAMPI
        nomeController.clear();
        cognomeController.clear();
        emailController.clear();
        telefonoController.clear();
        passwordController.clear();

        setState(() {
          admin = false;
          soccorso = false;
          officina = true;
          perito = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data["message"] ??
                  "Errore creazione account"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Errore connessione server: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Errore createAccount: $e');
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafeClaimColors.background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: SafeClaimColors.primary,
        foregroundColor: Colors.white,
        leading: const BackButton(),
        title: const Text("Creazione Account"),
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 20),

              _label("Nome"),
              _textField(
                hint: "es. mario.rossi",
                controller: nomeController,
              ),

              const SizedBox(height: 20),

              _label("Cognome"),
              _textField(
                hint: "es. mario.rossi",
                controller: cognomeController,
              ),

              const SizedBox(height: 20),

              _label("Email"),
              _textField(hint: "email@esempio.it", controller: emailController),

              const SizedBox(height: 20),

              _label("Password"),
              _textField(
                hint: "Inserisci password",
                controller: passwordController,
                isPassword: true,
              ),

              const SizedBox(height: 20),

              _label("Telefono"),
              _textField(
                hint: "es. mario.rossi",
                controller: telefonoController,
              ),

              const SizedBox(height: 30),

              _label("Ruoli"),

              const SizedBox(height: 10),

              _roleTile("Admin", admin, (v) {
                setState(() => admin = v);
              }),

              _roleTile("Soccorso", soccorso, (v) {
                setState(() => soccorso = v);
              }),

              _roleTile("Officina", officina, (v) {
                setState(() => officina = v);
              }),

              _roleTile("Perito", perito, (v) {
                setState(() => perito = v);
              }),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () {
                          if (_formKey.currentState!
                              .validate()) {
                            createAccount();
                          }
                        },

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),

                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Crea Account",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.white,
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

  /// LABEL
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  /// TEXT FIELD
  Widget _textField({
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,

      obscureText:
          isPassword ? obscurePassword : false,

      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return "Campo obbligatorio";
        }

        return null;
      },

      decoration: InputDecoration(
        hintText: hint,

        filled: true,
        fillColor: Colors.grey.shade100,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),

        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    obscurePassword =
                        !obscurePassword;
                  });
                },
              )
            : null,
      ),
    );
  }

  /// CHECKBOX
  Widget _roleTile(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
      ),

      child: CheckboxListTile(
        value: value,
        onChanged: (v) =>
            onChanged(v ?? false),

        title: Text(label),

        activeColor:
            const Color(0xFF2563EB),

        controlAffinity:
            ListTileControlAffinity.leading,
      ),
    );
  }
}
