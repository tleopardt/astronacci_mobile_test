import 'package:astronacci_mobile_test/services/user.dart';
import 'package:astronacci_mobile_test/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class User {
  final String username;
  final String birthDate;
  final String phone;
  final String email;
  final String? dirImage;

  User({
    required this.username,
    required this.birthDate,
    required this.phone,
    required this.email,
    this.dirImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final firstName = json['first_name'] ?? '';
    final lastName = json['last_name'] ?? '';

    return User(
      username: '$firstName $lastName'.trim(),
      birthDate: json['birth_date'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      dirImage: json['dir_image'],
    );
  }
}

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<User> _allUsers = [];

  List<User> _filteredUsers = [];

  int _currentPage = 0;
  final int _usersPerPage = 5;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    loadAllData();
    _allUsers;
    _filteredUsers = List.from(_allUsers);
  }

  Future<void> loadAllData() async {
    final response = await UserEndpoints.getListUser();

    if (response != null && response.statusCode == 201) {
      _allUsers = (response.data as List)
        .map((userJson) => User.fromJson(userJson))
        .toList();

      setState(() {
        _filteredUsers = List.from(_allUsers);
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response?.data['error'])),
      );
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredUsers = _allUsers
          .where((user) => user.username.toLowerCase().contains(_searchQuery))
          .toList();
      _currentPage = 0;
    });
  }

  void _nextPage() {
    if ((_currentPage + 1) * _usersPerPage < _filteredUsers.length) {
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  void _showUserDetailModal(User user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width, 
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                user.dirImage != null && user.dirImage != ''
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage('${dotenv.env['API_DIRECTORY'] ?? ''}${user.dirImage}'),
                      )
                    : CircleAvatar(
                        radius: 50,
                        backgroundColor: generateRandomColor(user.username),
                        child: Text(
                          getInitials(user.username),
                          style: const TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                const SizedBox(height: 16),

                Text(user.username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                
                const SizedBox(height: 8),

                Text('Email: ${user.email}'),
                Text('Birth Date: ${formatBirthDate(user.birthDate.split(' ').first)}'),
                Text('Phone: ${user.phone != '' ? user.phone : '-' }'),

                const SizedBox(height: 16),
              ],
            )
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int start = _currentPage * _usersPerPage;
    final int end = (_currentPage + 1) * _usersPerPage;
    final List<User> paginatedUsers = _filteredUsers.sublist(
      start,
      end > _filteredUsers.length ? _filteredUsers.length : end,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text("User List")
        )
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterUsers,
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: paginatedUsers.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final user = paginatedUsers[index];

                return ListTile(
                  onTap: () => _showUserDetailModal(user),
                  leading: user.dirImage != '' && user.dirImage != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage('http://localhost:8000${user.dirImage}'),
                        )

                      : CircleAvatar(
                          backgroundColor: generateRandomColor(user.username),
                          child: Text(
                            getInitials(user.username),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                  title: Text(user.username),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _previousPage,
                  child: const Text('Previous'),
                ),
                Text('${(_currentPage + 1).toString()} / ${(_allUsers.length / 5).ceil()}'),
                ElevatedButton(
                  onPressed: _nextPage,
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}
