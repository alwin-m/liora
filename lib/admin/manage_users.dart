/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Users")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final u = users[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(u['name']),
                subtitle: Text(u['email']),
                trailing: Text(u['role']),
              );
            },
          );
        },
      ),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String sortOption = 'recent'; // default
  String searchQuery = '';

  // 🔥 Build query based on sort option
  Query getUserQuery() {
    final usersRef = FirebaseFirestore.instance.collection('users');

    switch (sortOption) {
      case 'az':
        return usersRef.orderBy('name', descending: false);
      case 'za':
        return usersRef.orderBy('name', descending: true);
      case 'oldest':
        return usersRef.orderBy('createdAt', descending: false);
      case 'recent':
      default:
        return usersRef.orderBy('createdAt', descending: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌈 Gradient AppBar
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFa1c4fd), Color(0xFFc2e9fb)], // pastel blue gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("Manage Users"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (value) {
              setState(() => sortOption = value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'recent', child: Text('Recently Joined')),
              PopupMenuItem(value: 'oldest', child: Text('Date Joined')),
              PopupMenuItem(value: 'az', child: Text('Name A–Z')),
              PopupMenuItem(value: 'za', child: Text('Name Z–A')),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search users...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() => searchQuery = val.toLowerCase());
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getUserQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                final users = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery) || email.contains(searchQuery);
                }).toList();

                if (users.isEmpty) {
                  return const Center(child: Text("No matching users"));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {}); // re-trigger stream
                  },
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final doc = users[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final String name = data['name'] ?? 'No Name';
                      final String email = data['email'] ?? 'No Email';
                      final String role = data['role'] ?? 'user';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserDetailScreen(
                                name: name,
                                email: email,
                                role: role,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: doc.id,
                          child: Card(
                            elevation: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [Colors.white.withOpacity(0.9), Colors.blue.shade50],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: role == 'admin'
                                      ? Colors.redAccent
                                      : Colors.blueAccent,
                                  child: const Icon(Icons.person, color: Colors.white),
                                ),
                                title: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  email,
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                trailing: Chip(
                                  label: Text(role.toUpperCase()),
                                  backgroundColor: role == 'admin'
                                      ? Colors.redAccent.withOpacity(0.2)
                                      : Colors.greenAccent.withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: role == 'admin' ? Colors.redAccent : Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 🌟 Detail Screen with Hero Animation
class UserDetailScreen extends StatelessWidget {
  final String name;
  final String email;
  final String role;

  const UserDetailScreen({
    super.key,
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Details")),
      body: Center(
        child: Hero(
          tag: name,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor:
                        role == 'admin' ? Colors.redAccent : Colors.blueAccent,
                    child: const Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(email, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  Chip(
                    label: Text(role.toUpperCase()),
                    backgroundColor: role == 'admin'
                        ? Colors.redAccent.withOpacity(0.2)
                        : Colors.greenAccent.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: role == 'admin' ? Colors.redAccent : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String sortOption = 'recent';
  String searchQuery = '';

  Query getUserQuery() {
    final usersRef = FirebaseFirestore.instance.collection('users');

    switch (sortOption) {
      case 'az':
        return usersRef.orderBy('name', descending: false);
      case 'za':
        return usersRef.orderBy('name', descending: true);
      case 'oldest':
        return usersRef.orderBy('createdAt', descending: false);
      case 'recent':
      default:
        return usersRef.orderBy('createdAt', descending: true);
    }
  }

  Future<void> deleteUser(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌈 Gradient AppBar with rounded bottom
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFfbc2eb), Color(0xFFa6c1ee)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("Manage Users"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (value) => setState(() => sortOption = value),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'recent', child: Text('Recently Joined')),
              PopupMenuItem(value: 'oldest', child: Text('Date Joined')),
              PopupMenuItem(value: 'az', child: Text('Name A–Z')),
              PopupMenuItem(value: 'za', child: Text('Name Z–A')),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔍 Glassmorphism Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Search users...",
                  prefixIcon: Icon(Icons.search, color: Colors.pinkAccent),
                  border: InputBorder.none,
                ),
                onChanged: (val) =>
                    setState(() => searchQuery = val.toLowerCase()),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getUserQuery().snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['role'] == 'admin') return false;

                  final name = (data['name'] ?? '').toLowerCase();
                  final email = (data['email'] ?? '').toLowerCase();
                  return name.contains(searchQuery) ||
                      email.contains(searchQuery);
                }).toList();

                if (users.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final doc = users[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserDetailScreen(
                              uid: doc.id,
                              name: data['name'],
                              email: data['email'],
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: doc.id,
                        child: Card(
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.95),
                                  Colors.blue.shade50
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.pinkAccent,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(
                                data['name'] ?? 'No Name',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(data['email'] ?? 'No Email'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                splashRadius: 24,
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Delete User"),
                                      content: const Text(
                                          "Are you sure you want to delete this user?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text("Cancel"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red),
                                          child: const Text("Delete"),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await deleteUser(doc.id);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================= USER DETAIL + ORDERS =================

class UserDetailScreen extends StatelessWidget {
  final String uid;
  final String name;
  final String email;

  const UserDetailScreen({
    super.key,
    required this.uid,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌈 Gradient AppBar
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFa1c4fd), Color(0xFFc2e9fb)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("User Details"),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // USER INFO with Hero animation
              Hero(
                tag: uid,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.pinkAccent,
                          child: Icon(Icons.person,
                              color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 12),
                        Text(name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(email,
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                "Orders",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // USER ORDERS
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('orders')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Text("No orders found");
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                                              shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['productName'] ?? 'Product',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "₹${data['price']}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(
                                    data['status'] ?? 'Unknown',
                                    style: TextStyle(
                                      color: data['status'] == 'placed'
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: data['status'] == 'placed'
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2),
                                ),
                                Text(
                                  (data['createdAt'] as Timestamp)
                                      .toDate()
                                      .toString()
                                      .split(' ')
                                      .first,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    ));
  }
}