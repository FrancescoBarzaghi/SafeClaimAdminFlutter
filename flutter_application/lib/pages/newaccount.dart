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
  bool officina = false;
  bool perito = false;
  bool assicuratore = false;

  bool loading = false;
  
  final ApiService _apiService = ApiService();

  /// CREAZIONE ACCOUNT - Usa ApiService con endpoint HTTPS
  Future<void> createAccount() async {
    setState(() {
      loading = true;
    });

    try {
      final selectedRoles = <String>[
        if (admin) 'admin',
        if (soccorso) 'soccorso',
        if (officina) 'officina',
        if (perito) 'perito',
        if (assicuratore) 'assicuratore',
      ];

      final response = await _apiService.post(
        '/v1/utenti',
        {
          "nome": nomeController.text.trim(),
          "cognome": cognomeController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "telefono": telefonoController.text.trim(),
          "ruolo": selectedRoles,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
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
          officina = false;
          perito = false;
          assicuratore = false;
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
                hint: "Mario",
                controller: nomeController,
              ),

              const SizedBox(height: 20),

              _label("Cognome"),
              _textField(
                hint: "Rossi",
                controller: cognomeController,
              ),

              const SizedBox(height: 20),

              _label("Email"),
              _textField(hint: "esempio@email.it", controller: emailController),

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
                hint: "3331234567",
                controller: telefonoController,
                optional: true,
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

              _roleTile("Assicuratore", assicuratore, (v) {
                setState(() => assicuratore = v);
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
    bool optional = false,
  }) {
    return TextFormField(
      controller: controller,

      obscureText:
          isPassword ? obscurePassword : false,

      validator: optional
      ? null
      : (value) {
        if (value == null || value.trim().isEmpty) {
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
