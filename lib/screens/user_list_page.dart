import 'package:flutter/material.dart';

import '../widgets/user_avatar.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'user_form_page.dart';

class UserListPage extends StatefulWidget {
const UserListPage({super.key});

@override
State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
final _service = UserService();
late Future<List<UserModel>> _future;
List<UserModel> _users = [];

@override
void initState() {
super.initState();
_load();
}

void _load() {
_future = _service.getUsers().then((data) {
_users = data;
return data;
});
}

void _snack(String msg, {bool error = false}) {
ScaffoldMessenger.of(context)
..hideCurrentSnackBar()
..showSnackBar(SnackBar(
content: Text(msg),
backgroundColor: error ? Colors.red : Colors.green,
));
}

Future<void> _openForm({UserModel? user}) async {
final result = await Navigator.push<UserModel>(
context,
MaterialPageRoute(builder: (_) => UserFormPage(user: user)),
);
if (result == null) return;

setState(() {
if (user == null) {
_users.insert(0, result);
} else {
final i = _users.indexWhere((u) => u.id == result.id);
if (i != -1) _users[i] = result.copyWith(avatar: _users[i].avatar);
}
});
_snack(user == null
? 'User "${result.fullName}" berhasil dibuat (ID: ${result.id})'
    : 'User "${result.fullName}" berhasil diperbarui');
}

Future<void> _delete(UserModel user) async {
final ok = await showDialog<bool>(
context: context,
builder: (_) => AlertDialog(
title: const Text('Hapus user?'),
content: Text('Anda yakin menghapus ${user.fullName}?'),
actions: [
TextButton(
onPressed: () => Navigator.pop(context, false),
child: const Text('Batal')),
TextButton(
onPressed: () => Navigator.pop(context, true),
child: const Text('Hapus')),
],
),
);
if (ok != true) return;

try {
await _service.deleteUser(user.id!);
setState(() => _users.removeWhere((u) => u.id == user.id));
_snack('User "${user.fullName}" berhasil dihapus');
} on ApiException catch (e) {
_snack(e.message, error: true);
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Daftar User (reqres.in)')),
floatingActionButton: FloatingActionButton(
onPressed: () => _openForm(),
child: const Icon(Icons.add),
),
body: FutureBuilder<List<UserModel>>(
future: _future,
builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(child: CircularProgressIndicator());
}

if (snapshot.hasError) {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(Icons.error_outline, size: 56, color: Colors.red),
const SizedBox(height: 12),
Text('${snapshot.error}', textAlign: TextAlign.center),
const SizedBox(height: 16),
FilledButton.icon(
onPressed: () => setState(_load),
icon: const Icon(Icons.refresh),
label: const Text('Coba Lagi'),
),
],
),
),
);
}

if (_users.isEmpty) {
return const Center(child: Text('Belum ada data user.'));
}

return RefreshIndicator(
onRefresh: () async {
setState(_load);
await _future;
},
child: ListView.separated(
itemCount: _users.length,
separatorBuilder: (_, _) => const Divider(height: 1),
itemBuilder: (context, i) {
final u = _users[i];
return ListTile(
  leading: UserAvatar(url: u.avatar, name: u.fullName),
title: Text(u.fullName),
subtitle: Text(u.email),
trailing: Row(
mainAxisSize: MainAxisSize.min,
children: [
IconButton(
icon: const Icon(Icons.edit),
onPressed: () => _openForm(user: u),
),
IconButton(
icon: const Icon(Icons.delete, color: Colors.red),
onPressed: () => _delete(u),
),
],
),
);
},
),
);
},
),
);
}
}
