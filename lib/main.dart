import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MinimalistMinimalApp());
}

class MinimalistMinimalApp extends StatelessWidget {
  const MinimalistMinimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xff121212),
        primaryColor: Colors.white,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentDay = 1;
  final int _targetDays = 150;
  
  final List<String> _habits = [
    "ترك الهاتف غير الضروري",
    "الابتعاد عن الذكاء الاصطناعي",
    "قطع الإنترنت الزائد",
    "التعافي من الإباحية"
  ];

  Map<String, bool> _todayStatus = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentDay = prefs.getInt('current_day') ?? 1;
      for (var habit in _habits) {
        _todayStatus[habit] = prefs.getBool('status_$habit') ?? false;
      }
    });
  }

  Future<void> _toggleHabit(String habit) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _todayStatus[habit] = !(_todayStatus[habit] ?? false);
      prefs.setBool('status_$habit', _todayStatus[habit]!);
    });
  }

  Future<void> _nextDay() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentDay < _targetDays) {
      setState(() {
        _currentDay++;
        for (var habit in _habits) {
          _todayStatus[habit] = false;
          prefs.setBool('status_$habit', false);
        }
        prefs.setInt('current_day', _currentDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "اليوم $_currentDay من $_targetDays",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "${((_currentDay / _targetDays) * 100).toStringAsFixed(1)}% من الرحلة اكتملت",
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 40),
              
              Expanded(
                child: Table(
                  border: TableBorder.all(color: Colors.grey[800]!, width: 1),
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(1),
                  },
                  children: _habits.map((habit) {
                    bool isDone = _todayStatus[habit] ?? false;
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            habit,
                            style: TextStyle(
                              fontSize: 18, 
                              color: isDone ? Colors.grey : Colors.white,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _toggleHabit(habit),
                          child: Container(
                            height: 56,
                            alignment: Alignment.center,
                            color: isDone ? Colors.white.withOpacity(0.05) : Colors.transparent,
                            child: Icon(
                              isDone ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                              color: isDone ? Colors.green : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                  ),
                  onPressed: _nextDay,
                  child: const Text(
                    "إنهاء اليوم والانتقال للتالي",
                    style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
