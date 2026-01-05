import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditorPage extends StatefulWidget {
  // Kalau ini null = Tambah Baru. Kalau ada isinya = Edit.
  final Map<String, dynamic>? noteData;

  const EditorPage({super.key, this.noteData});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final _supabase = Supabase.instance.client;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Kalau mau edit, isi kolom dengan data lama
    if (widget.noteData != null) {
      _titleController.text = widget.noteData!['title'];
      _contentController.text = widget.noteData!['content'];
    }
  }

  Future<void> _saveNote() async {
    setState(() => _isLoading = true);
    final userId = _supabase.auth.currentUser!.id;
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context); // Kalau kosong, balik aja
      return;
    }

    try {
      if (widget.noteData == null) {
        // --- LOGIKA TAMBAH BARU ---
        await _supabase.from('notes').insert({
          'user_id': userId,
          'title': title,
          'content': content,
        });
      } else {
        // --- LOGIKA UPDATE (EDIT) ---
        await _supabase
            .from('notes')
            .update({'title': title, 'content': content})
            .eq('id', widget.noteData!['id']); // Cari berdasarkan ID lama
      }

      if (mounted) Navigator.pop(context); // Kembali ke Home setelah simpan
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteData == null ? 'Catatan Baru' : 'Edit Catatan'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.black),
                  )
                : const Icon(Icons.check),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input JUDUL (Huruf Besar)
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Judul',
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            // Input ISI (Expand memenuhi layar)
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null, // Bisa enter sebanyak mungkin
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Tulis sesuatu...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
