import 'package:flutter/material.dart';
import 'elenco.dart';

class NewAccountPage extends StatefulWidget {
  const NewAccountPage({super.key});

  @override
  State<NewAccountPage> createState() => _NewAccountPageState();
}

class _NewAccountPageState extends State<NewAccountPage> {
  bool obscurePassword = true;
  String searchQuery = "";

  bool admin = false;
  bool soccorso = false;
  bool officina = true;
  bool perito = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF1E66F5), // blu intenso
        foregroundColor: Colors.white, // testo bianco
        leading: const BackButton(),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Creazione Account",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Creazione Account e Utenti",
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),

      ),

      /// BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (searchQuery.isNotEmpty) ..._buildSearchResults(),
            const SizedBox(height: 8),

            /// TITOLO PAGINA
            Row(
              children: const [
                Icon(Icons.shield_outlined, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Crea Nuovo Account",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// USERNAME
            _label("Username"),
            _textField(
              hint: "es. mario.rossi",
              errorText: "Username è obbligatorio",
            ),

            const SizedBox(height: 16),

            /// EMAIL
            _label("Email"),
            _textField(
              hint: "email@esempio.it",
              errorText: "Email è obbligatoria",
            ),

            const SizedBox(height: 16),

            /// PASSWORD
            _label("Password"),
            TextField(
              obscureText: obscurePassword,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                errorText: "Password è obbligatoria",
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// RUOLI
            _label("Ruoli"),
            const SizedBox(height: 8),

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

            const SizedBox(height: 24),

            /// BOTTONE CREA
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // per ora non fa nulla
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Crea",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // testo bianco
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------- COMPONENTI UI ----------

  Widget _label(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
        children: const [
          TextSpan(
            text: " *",
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required String hint,
    required String errorText,
  }) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _roleTile(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        title: Text(label),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  List<Widget> _buildSearchResults() {
    final filtered = mockUsers.where((u) {
      final s = searchQuery.toLowerCase();
      return u.name.toLowerCase().contains(s) ||
          u.email.toLowerCase().contains(s) ||
          u.phone.contains(searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.info, color: Colors.orange),
              SizedBox(width: 8),
              Text("Nessun utente trovato", style: TextStyle(color: Colors.orange)),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ];
    }

    return [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Utenti trovati:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...filtered.take(5).map((u) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(u.email, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
      const SizedBox(height: 16),
    ];
  }
}
