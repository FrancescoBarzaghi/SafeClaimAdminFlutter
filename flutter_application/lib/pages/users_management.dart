import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/user_category.dart';
import '../services/user_api_service.dart';

/// Pagina di esempio per visualizzare gli utenti online e per categoria
class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage>
    with SingleTickerProviderStateMixin {
  final UserApiService _apiService = UserApiService();

  List<User> _onlineUsers = [];
  List<User> _categoryUsers = [];
  List<UserCategory> _categories = [];
  String _selectedCategory = 'admin';
  bool _isLoading = true;
  String? _error;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Carica gli utenti online e le categorie in parallelo
      final results = await Future.wait([
        _apiService.getOnlineUsers(),
        _apiService.getUserCategories(),
      ]);

      setState(() {
        _onlineUsers = results[0] as List<User>;
        _categories = results[1] as List<UserCategory>;
        _isLoading = false;
      });

      // Carica gli utenti della prima categoria
      if (_categories.isNotEmpty) {
        _loadCategoryUsers(_categories.first.id);
      }
    } catch (e) {
      setState(() {
        _error = 'Errore nel caricamento dei dati: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCategoryUsers(String category) async {
    setState(() {
      _selectedCategory = category;
      _isLoading = true;
    });

    try {
      final users = await _apiService.getUsersByCategory(category);
      setState(() {
        _categoryUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Errore nel caricamento degli utenti: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Utenti'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Online', icon: Icon(Icons.circle, size: 12)),
            Tab(text: 'Per Categoria', icon: Icon(Icons.category)),
          ],
        ),
      ),
      body: _error != null
          ? _buildErrorWidget()
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Utenti Online
                _buildOnlineUsersTab(),
                // Tab 2: Utenti per Categoria
                _buildCategoryUsersTab(),
              ],
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialData,
            child: const Text('Riprova'),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineUsersTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_onlineUsers.isEmpty) {
      return const Center(
        child: Text('Nessun utente online'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Carta riepilogativa
          Card(
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.people, color: Colors.white, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'Utenti Online',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_onlineUsers.length} utenti',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Lista utenti
          ...List.generate(
            _onlineUsers.length,
            (index) => _buildUserCard(_onlineUsers[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryUsersTab() {
    if (_categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Selezione categoria
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category.id == _selectedCategory;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(
                    '${category.name}\n(${category.userCount})',
                    textAlign: TextAlign.center,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      _loadCategoryUsers(category.id);
                    }
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: Colors.blue.shade400,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 16),
        // Lista utenti della categoria
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _categoryUsers.isEmpty
                  ? const Center(
                      child: Text('Nessun utente in questa categoria'),
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          _loadCategoryUsers(_selectedCategory),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _categoryUsers.length,
                        itemBuilder: (context, index) =>
                            _buildUserCard(_categoryUsers[index]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(user.category),
          child: Text(
            user.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user.email,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: user.isOnline ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  user.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 11,
                    color: user.isOnline ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Chip(
          label: Text(user.category),
          backgroundColor: _getCategoryColor(user.category).withOpacity(0.2),
          labelStyle: TextStyle(
            color: _getCategoryColor(user.category),
            fontSize: 11,
          ),
        ),
        onTap: () {
          _showUserDetails(user);
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'moderator':
        return Colors.orange;
      case 'premium':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email:', user.email),
            _buildDetailRow('Categoria:', user.category),
            _buildDetailRow('Stato:', user.isOnline ? 'Online' : 'Offline'),
            _buildDetailRow(
              'Ultimo accesso:',
              _formatDateTime(user.lastSeen),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Pochi secondi fa';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minuti fa';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ore fa';
    } else {
      return '${difference.inDays} giorni fa';
    }
  }
}
