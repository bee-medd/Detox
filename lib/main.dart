import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const Detox150ProApp());
}

class Detox150ProApp extends StatelessWidget {
  const Detox150ProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xff0d0d0d),
        primaryColor: const Color(0xfff97316),
      ),
      home: const MainChallengeScreen(),
    );
  }
}

class MainChallengeScreen extends StatefulWidget {
  const MainChallengeScreen({super.key});

  @override
  State<MainChallengeScreen> createState() => _MainChallengeScreenState();
}

class _MainChallengeScreenState extends State<MainChallengeScreen> {
  final int _totalDays = 150;
  List<bool> _daysStatus = [];
  int _completedDays = 0;
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _daysStatus = List.generate(_totalDays, (index) => false);
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    int completed = 0;
    List<bool> loadedStatus = [];

    for (int i = 0; i < _totalDays; i++) {
      bool status = prefs.getBool('day_$i') ?? false;
      loadedStatus.add(status);
      if (status) completed++;
    }

    setState(() {
      _daysStatus = loadedStatus;
      _completedDays = completed;
      _currentStreak = _calculateStreak(loadedStatus);
    });
  }

  int _calculateStreak(List<bool> statusList) {
    int maxStreak = 0;
    int currentCounter = 0;
    for (bool status in statusList) {
      if (status) {
        currentCounter++;
        if (currentCounter > maxStreak) {
          maxStreak = currentCounter;
        }
      } else {
        currentCounter = 0;
      }
    }
    return maxStreak;
  }

  Future<void> _toggleDay(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _daysStatus[index] = !_daysStatus[index];
      prefs.setBool('day_$index', _daysStatus[index]);
      
      _completedDays = _daysStatus.where((status) => status).length;
      _currentStreak = _calculateStreak(_daysStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
    double progressPercent = (_completedDays / _totalDays) * 100;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Detox.",
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Your story, make it worth reading...",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xff161616),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem("Completed", "$_completedDays/$_totalDays"),
                    _buildStatItem("Progress", "${progressPercent.toStringAsFixed(1)}%"),
                    _buildStatItem("Streak", "$_currentStreak Days"),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                "150 Days Matrix",
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _totalDays,
                  itemBuilder: (context, index) {
                    bool isDone = _daysStatus[index];
                    return InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () => _toggleDay(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDone ? const Color(0xffea580c) : const Color(0xff161616),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDone ? const Color(0xfff97316) : const Color(0xff262626),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDone ? Colors.white : const Color(0xffa3a3a3),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xff737373), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold, 
            color: Colors.white,
            letterSpacing: 0.5
          ),
        ),
      ],
    );
  }
}
