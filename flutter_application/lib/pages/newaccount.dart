import 'package:flutter/material.dart';
import 'elenco.dart';

class NewAccountPage extends StatefulWidget {
  const NewAccountPage({super.key});

  @override
  State<NewAccountPage> createState() => _NewAccountPageState();
}

class _NewAccountPageState extends State<NewAccountPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  String searchQuery = "";

  bool admin = false;
  bool soccorso = false;
  bool officina = true;
  bool perito = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      /// APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E66F5),
        foregroundColor: Colors.white,
        leading: const BackButton(),
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Creazione Account",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text(
              "Creazione Account e Utenti",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),

      /// BODY
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              /// TITOLO
              Row(
                children: const [
                  Icon(Icons.shield_outlined, color: Color(0xFF2563EB)),
                  SizedBox(width: 8),
                  Text(
                    "Crea Nuovo Account",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// USERNAME
              _label("Username"),
              _textField(
                hint: "es. mario.rossi",
                controller: usernameController,
              ),

              const SizedBox(height: 20),

              /// EMAIL
              _label("Email"),
              _textField(
                hint: "email@esempio.it",
                controller: emailController,
              ),

              const SizedBox(height: 20),

              /// PASSWORD
              _label("Password"),
              _textField(
                hint: "Inserisci password",
                controller: passwordController,
                isPassword: true,
              ),

              const SizedBox(height: 30),

              /// RUOLI
              _label("Ruoli"),
              const SizedBox(height: 12),

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

              /// BOTTONE CREA
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      print("Username: ${usernameController.text}");
                      print("Email: ${emailController.text}");
                      print("Password: ${passwordController.text}");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    "Crea Account",
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
    );
  }

  /// LABEL CON *
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          children: const [
            TextSpan(
              text: " *",
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  /// TEXT FIELD MODERNO
  Widget _textField({
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscurePassword : false,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Campo obbligatorio";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,

        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFF2563EB), width: 2),
        ),

        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),

        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),

        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              )
            : null,
      ),
    );
  }

  /// CHECKBOX RUOLI MODERNE
  Widget _roleTile(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        activeColor: const Color(0xFF2563EB),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}