import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OMDb API Demo',
      home: MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Movie> _movies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OMDb Movie Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: 'Search Movies'),
              onSubmitted: (value) {
                _searchMovies(value);
              },
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_movies[index].titre),
                    subtitle: Text(_movies[index].annee),
                    onTap: (){
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (BuildContext context) => MovieDetailScreen(movie: _movies[index])),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchMovies(String query) async {
    const apiKey = '38fb1b90';
    final apiUrl = 'http://www.omdbapi.com/?apikey=$apiKey&s=$query';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> movies = data['Search'];

      setState(() {
        _movies = movies.map((movie) => Movie.fromJson(movie)).toList();
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }
}

class Movie {
  String titre;
  String annee;
  String imdbID;

  Movie({required this.titre, required this.annee, this.imdbID});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      titre: json['Title'],
      annee: json['Year'],
      imdbID: json['imdbID'],
    );
  }
}


class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  MovieDetailScreen({required this.movie});
  @override
  
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _movieDetails;
  bool _isLoading = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.titre ?? 'Details du film'),
      ),
      body: _isLoading
      ? Center(child: CircularProgressIndicator())
      : _movieDetails == null
      ? Center(child: Text('Erreur de chargement'))
      : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Titre: ${_movieDetails!['Title']}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              )
            ),
            SizedBox(height: 10),
            Text(
              'Année: ${_movieDetails!['Year']}'
            ),
          ],
        ),
      ),
    );
  }
}