import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _elapsedTime = 0; // Elapsed time in seconds
  Timer? _timer; // Timer object
  bool _isRunning = false; // Timer state
  String bookImageUrl = ''; // Book image URL
  bool isLoading = true; // Loading state for the book cover
  String author = ''; // Author name
  int totalPages = 0; // Total number of pages in the book
  int _currentIndex = 2; // Default to Timer (index 2)

  // This will start/pause the timer
  void _startPauseTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedTime++;
        });
      });
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  // Format elapsed time to MM:SS format
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')} : ${secs.toString().padLeft(2, '0')}';
  }

  // Fetch the book data from Google Books API
  Future<void> _fetchBookData(String bookTitle) async {
    final apiKey = 'AIzaSyALaf-OWZNNYcmem0yWLjPLIjtUOi5QNAg';  // Replace with your API key

    final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$bookTitle&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['items'] != null && data['items'].isNotEmpty) {
        setState(() {
          bookImageUrl = data['items'][0]['volumeInfo']['imageLinks']['thumbnail'];
          author = data['items'][0]['volumeInfo']['authors']?.join(', ') ?? 'Unknown Author';
          totalPages = data['items'][0]['volumeInfo']['pageCount'] ?? 0;
          isLoading = false;
        });
      } else {
        setState(() {
          bookImageUrl = '';
          author = 'Unknown Author';
          totalPages = 0;
          isLoading = false;
        });
      }
    } else {
      throw Exception('Failed to load book data');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBookData('Holly'); // Replace with any book title you'd like to search for
  }

  @override
  void dispose() {
    _timer?.cancel(); // Ensure the timer is disposed of when leaving the screen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6E6FA),
      appBar: AppBar(
        title: Text('Timer'),
        backgroundColor: Colors.purple[200],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Timer Section
          Center(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _formatTime(_elapsedTime),
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  _isRunning ? "Reading..." : "Paused",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                IconButton(
                  icon: Icon(_isRunning ? Icons.pause_circle : Icons.play_circle),
                  iconSize: 60,
                  color: Colors.purpleAccent,
                  onPressed: _startPauseTimer,
                ),
              ],
            ),
          ),
          SizedBox(height: 30),

          // Book Info Section
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                isLoading
                    ? CircularProgressIndicator() // Show loading spinner while fetching
                    : bookImageUrl.isNotEmpty
                    ? Image.network(bookImageUrl, height: 60)
                    : Icon(Icons.book, color: Colors.white), // Fallback icon if no image found
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Holly',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        author,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        '$totalPages pages',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Renk değişikliğinin çalışmasını sağlar
          backgroundColor: Colors.purple[200], // AppBar ile aynı renk// Darker purple background color
          selectedItemColor:  Color(0xFF6A1B9A), // Selected item color white
          unselectedItemColor: Colors.purple, // Unselected item color white70
          currentIndex: _currentIndex, // Set the current selected index

          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home', // Label under icon
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Book', // Label under icon
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer),
              label: 'Timer', // Label under icon
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile', // Label under icon
            ),
          ],
        )


    );
  }
}
