import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(ThaiMovieApp());
}

class ThaiMovieApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'รายชื่อหนังไทย',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: MovieListPage(),
    );
  }
}

class Movie {
  String? id;
  String title;
  String director;
  int year;
  String genre;

  Movie({
    this.id,
    required this.title,
    required this.director,
    required this.year,
    required this.genre,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => Movie(
        id: json['_id'],
        title: json['title'],
        director: json['director'],
        year: json['year'],
        genre: json['genre'],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'director': director,
        'year': year,
        'genre': genre,
      };
}

class MovieListPage extends StatefulWidget {
  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  final String apiUrl = 'http://10.0.2.2:5000/api/movies';
  List<Movie> movies = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    setState(() => loading = true);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);
        movies = jsonData.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching movies: $e')));
    }
    setState(() => loading = false);
  }

  Future<void> deleteMovie(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('ลบหนังเรียบร้อย')));
        fetchMovies();
      } else {
        throw Exception('Failed to delete movie');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting movie: $e')));
    }
  }

  void openMovieForm({Movie? movie}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => MovieFormPage(
                movie: movie,
                apiUrl: apiUrl,
              )),
    );
    if (result == true) {
      fetchMovies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายชื่อหนังไทย'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : movies.isEmpty
                ? Center(child: Text('ไม่มีข้อมูลหนัง'))
                : ListView.builder(
                    itemCount: movies.length,
                    itemBuilder: (_, i) {
                      final movie = movies[i];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(movie.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              'ผู้กำกับ: ${movie.director}\nปี: ${movie.year}\nประเภท: ${movie.genre}'),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => openMovieForm(movie: movie),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text('ยืนยันการลบ'),
                                    content: Text('ต้องการลบ "${movie.title}" หรือไม่?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('ยกเลิก')),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          deleteMovie(movie.id!);
                                        },
                                        child: Text('ลบ'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openMovieForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}

class MovieFormPage extends StatefulWidget {
  final Movie? movie;
  final String apiUrl;

  MovieFormPage({this.movie, required this.apiUrl});

  @override
  State<MovieFormPage> createState() => _MovieFormPageState();
}

class _MovieFormPageState extends State<MovieFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController directorController;
  late TextEditingController yearController;
  late TextEditingController genreController;

  bool submitting = false;

  @override
  void initState() {
    super.initState();
    titleController =
        TextEditingController(text: widget.movie?.title ?? '');
    directorController =
        TextEditingController(text: widget.movie?.director ?? '');
    yearController =
        TextEditingController(text: widget.movie?.year.toString() ?? '');
    genreController =
        TextEditingController(text: widget.movie?.genre ?? '');
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => submitting = true);

    final movie = Movie(
      title: titleController.text,
      director: directorController.text,
      year: int.parse(yearController.text),
      genre: genreController.text,
    );

    try {
      final url = widget.movie == null
          ? Uri.parse(widget.apiUrl)
          : Uri.parse('${widget.apiUrl}/${widget.movie!.id}');
      final response = widget.movie == null
          ? await http.post(url,
              headers: {'Content-Type': 'application/json'},
              body: json.encode(movie.toJson()))
          : await http.put(url,
              headers: {'Content-Type': 'application/json'},
              body: json.encode(movie.toJson()));

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.movie == null
                  ? 'เพิ่มหนังเรียบร้อย'
                  : 'แก้ไขหนังเรียบร้อย')),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('เกิดข้อผิดพลาด');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.movie != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'แก้ไขหนัง' : 'เพิ่มหนังใหม่'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.orange.shade100, blurRadius: 10)],
          ),
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'ชื่อหนัง'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'กรุณากรอกชื่อหนัง' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: directorController,
                  decoration: InputDecoration(labelText: 'ผู้กำกับ'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'กรุณากรอกชื่อผู้กำกับ' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: yearController,
                  decoration: InputDecoration(labelText: 'ปีที่ฉาย'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกปีที่ฉาย';
                    }
                    if (int.tryParse(value) == null) {
                      return 'กรุณากรอกตัวเลขเท่านั้น';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: genreController,
                  decoration: InputDecoration(labelText: 'ประเภท'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'กรุณากรอกประเภทหนัง' : null,
                ),
                SizedBox(height: 24),
                submitting
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: submit,
                          child: Text(isEditing ? 'บันทึก' : 'เพิ่มหนัง'),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
