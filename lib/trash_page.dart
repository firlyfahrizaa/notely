import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrashPage extends StatefulWidget {
  const TrashPage({super.key});

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _trashNotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrash();
  }

  // Ambil data yang is_deleted = true
  Future<void> _fetchTrash() async {
    try {
      final response = await _supabase
          .from('notes')
          .select()
          .eq('is_deleted', true) // <--- INI KUNCINYA
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _trashNotes = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Restore (Kembalikan ke Home)
  Future<void> _restoreNote(int id) async {
    await _supabase.from('notes').update({'is_deleted': false}).eq('id', id);
    _fetchTrash(); // Refresh list
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Catatan dipulihkan!')));
  }

  // Hapus Permanen (Hilang Selamanya)
  Future<void> _deletePermanently(int id) async {
    await _supabase.from('notes').delete().eq('id', id);
    _fetchTrash(); // Refresh list
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Dihapus permanen.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tempat Sampah'),
        backgroundColor: Colors.red[100], // Warna beda biar ketahuan ini sampah
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trashNotes.isEmpty
          ? const Center(child: Text('Sampah kosong.'))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _trashNotes.length,
              itemBuilder: (context, index) {
                final note = _trashNotes[index];
                return Card(
                  color: Colors.grey[200], // Warna abu-abu
                  child: ListTile(
                    title: Text(
                      note['title'] ?? 'Tanpa Judul',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: Text(note['content'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tombol Restore
                        IconButton(
                          icon: const Icon(Icons.restore, color: Colors.green),
                          onPressed: () => _restoreNote(note['id']),
                          tooltip: 'Pulihkan',
                        ),
                        // Tombol Hapus Permanen
                        IconButton(
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          ),
                          onPressed: () => _deletePermanently(note['id']),
                          tooltip: 'Hapus Permanen',
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
