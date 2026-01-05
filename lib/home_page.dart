import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'editor_page.dart';
import 'login_page.dart';
import 'trash_page.dart'; // <--- Jangan lupa import ini

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _allNotes = [];
  List<Map<String, dynamic>> _filteredNotes = [];
  String _searchQuery = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  // --- UPDATE 1: Cuma ambil yang TIDAK dihapus ---
  Future<void> _fetchNotes() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('notes')
          .select()
          .eq('is_deleted', false) // <--- TAMBAHAN PENTING
          .order('created_at', ascending: false);

      setState(() {
        _allNotes = List<Map<String, dynamic>>.from(response);
        _filterNotes();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterNotes() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredNotes = _allNotes;
      } else {
        _filteredNotes = _allNotes.where((note) {
          final title = (note['title'] ?? '').toString().toLowerCase();
          final content = (note['content'] ?? '').toString().toLowerCase();
          final query = _searchQuery.toLowerCase();
          return title.contains(query) || content.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _signOut() async {
    await _supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  // --- UPDATE 2: Soft Delete (Pindah ke Sampah) ---
  Future<void> _deleteNote(int id) async {
    // Bukannya delete, tapi update is_deleted jadi true
    await _supabase.from('notes').update({'is_deleted': true}).eq('id', id);
    _fetchNotes(); // Refresh list

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan dipindahkan ke sampah')),
      );
    }
  }

  Future<void> _openEditor({Map<String, dynamic>? note}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditorPage(noteData: note)),
    );
    _fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextField(
            onChanged: (value) {
              _searchQuery = value;
              _filterNotes();
            },
            decoration: const InputDecoration(
              hintText: 'Cari catatan...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        // Actions dikosongkan karena Logout pindah ke Drawer (Opsional)
        // Kalau mau tetap ada logout di atas, biarkan saja code actions yang lama
      ),

      // --- UPDATE 3: Menu Garis Tiga (Drawer) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.amber),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.note_alt, size: 48, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Notely App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Catatan Saya'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Sampah'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer dulu
                // Buka halaman sampah
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrashPage()),
                ).then((_) => _fetchNotes());
                // .then(...) artinya kalau balik dari sampah, refresh home (siapa tau ada yg di-restore)
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _signOut,
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
        onPressed: () => _openEditor(),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredNotes.isEmpty
          ? const Center(child: Text('Tidak ada catatan.'))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                final note = _filteredNotes[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () => _openEditor(note: note),
                    title: Text(
                      note['title'] ?? 'Tanpa Judul',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                    ),
                    subtitle: Text(note['content'] ?? '', maxLines: 2),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openEditor(note: note);
                        } else if (value == 'delete') {
                          _deleteNote(note['id']);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
