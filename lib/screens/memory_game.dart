import 'dart:async';

import 'package:flutter/material.dart';

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  final List<String> _symbols = ['🍎', '🍎', '🌸', '🌸', '⭐', '⭐', '🦋', '🦋'];

  List<bool> _revealed = [];
  List<int> _selectedCards = [];

  int _matchedPairs = 0;
  int _attempts = 0;

  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _symbols.shuffle();

    _revealed = List<bool>.filled(_symbols.length, false);
    _selectedCards = [];
    _matchedPairs = 0;
    _attempts = 0;
    _isChecking = false;
  }

  void _tapCard(int index) {
    if (_isChecking || _revealed[index] || _selectedCards.contains(index)) {
      return;
    }

    setState(() {
      _revealed[index] = true;
      _selectedCards.add(index);
    });

    if (_selectedCards.length == 2) {
      _checkMatch();
    }
  }

  void _checkMatch() {
    _isChecking = true;
    _attempts++;

    final first = _selectedCards[0];
    final second = _selectedCards[1];

    if (_symbols[first] == _symbols[second]) {
      setState(() {
        _matchedPairs++;
        _selectedCards.clear();
        _isChecking = false;
      });

      if (_matchedPairs == 4) {
        _showCompleteDialog();
      }
    } else {
      Timer(const Duration(milliseconds: 900), () {
        if (!mounted) return;

        setState(() {
          _revealed[first] = false;
          _revealed[second] = false;
          _selectedCards.clear();
          _isChecking = false;
        });
      });
    }
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Well Done!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF173B35),
            ),
          ),
          content: Text(
            'You found all the pairs!\n\nAttempts: $_attempts',
            style: const TextStyle(fontSize: 17),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _startGame();
                });
              },
              child: const Text(
                'Play Again',
                style: TextStyle(
                  color: Color(0xFF376B5C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F2),
        elevation: 0,

        title: const Text(
          'Memory Game',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF173B35),
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: const Color(0xFFE4EFEA),
                  borderRadius: BorderRadius.circular(22),
                ),

                child: const Column(
                  children: [
                    Text('🧠', style: TextStyle(fontSize: 45)),

                    SizedBox(height: 8),

                    Text(
                      'Find the Matching Pairs',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173B35),
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      'Remember where each symbol is!',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SCORE
              Row(
                children: [
                  Expanded(
                    child: _infoCard('Pairs Found', '$_matchedPairs / 4'),
                  ),

                  const SizedBox(width: 12),

                  Expanded(child: _infoCard('Attempts', '$_attempts')),
                ],
              ),

              const SizedBox(height: 24),

              // GAME GRID
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),

                  itemCount: _symbols.length,

                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _tapCard(index),

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),

                        decoration: BoxDecoration(
                          color: _revealed[index]
                              ? Colors.white
                              : const Color(0xFF376B5C),

                          borderRadius: BorderRadius.circular(22),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),

                        child: Center(
                          child: Text(
                            _revealed[index] ? _symbols[index] : '?',

                            style: TextStyle(
                              fontSize: _revealed[index] ? 48 : 38,

                              fontWeight: FontWeight.bold,

                              color: _revealed[index]
                                  ? const Color(0xFF173B35)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // RESTART BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _startGame();
                    });
                  },

                  icon: const Icon(Icons.refresh_rounded),

                  label: const Text(
                    'Restart Game',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF376B5C),

                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF376B5C),
            ),
          ),
        ],
      ),
    );
  }
}
