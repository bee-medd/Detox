import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ReplyBossApp());
}

class ReplyBossApp extends StatelessWidget {
  const ReplyBossApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReplyBoss AI',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF8EE),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF147DF5),
          brightness: Brightness.light,
        ),
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
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _businessController = TextEditingController();

  final List<String> _goals = [
    'Sell',
    'Apologize',
    'Negotiate',
    'Follow up',
    'Ask for payment',
    'Bad review',
  ];

  final List<String> _tones = [
    'Professional',
    'Friendly',
    'Short',
    'Firm',
  ];

  final List<String> _platforms = [
    'WhatsApp',
    'Instagram',
    'Gmail',
    'LinkedIn',
    'Etsy',
    'Upwork',
  ];

  String _selectedGoal = 'Sell';
  String _selectedTone = 'Professional';
  String _selectedPlatform = 'WhatsApp';

  List<String> _replies = [];

  @override
  void initState() {
    super.initState();
    _loadBusinessProfile();
  }

  Future<void> _loadBusinessProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _businessController.text = prefs.getString('business_profile') ?? '';
  }

  Future<void> _saveBusinessProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('business_profile', _businessController.text.trim());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Business profile saved')),
    );
  }

  void _generateReplies() {
    final customerMessage = _messageController.text.trim();

    if (customerMessage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paste the customer message first')),
      );
      return;
    }

    final business = _businessController.text.trim();

    setState(() {
      _replies = _buildReplies(
        message: customerMessage,
        business: business,
        goal: _selectedGoal,
        tone: _selectedTone,
        platform: _selectedPlatform,
      );
    });
  }

  List<String> _buildReplies({
    required String message,
    required String business,
    required String goal,
    required String tone,
    required String platform,
  }) {
    final businessText = business.isEmpty ? 'our product/service' : business;
    final lowerMessage = message.toLowerCase();

    List<String> replies;

    if (goal == 'Sell') {
      if (lowerMessage.contains('expensive') ||
          lowerMessage.contains('price') ||
          lowerMessage.contains('discount') ||
          lowerMessage.contains('too much')) {
        replies = [
          'Thank you for your interest. The price reflects the quality of $businessText, but I can offer a small discount if you confirm today.',
          'I understand your concern. Many customers choose $businessText because of the value and quality it provides. I’d be happy to help you choose the best option.',
          'The price is based on the quality and service included. If you are ready to order today, I can see what small offer is available for you.',
        ];
      } else {
        replies = [
          'Hello! Thank you for your interest in $businessText. I’d be happy to help you with the next step.',
          'Yes, it’s available. $businessText is a great choice, and I can help you confirm your order today.',
          'Thank you for reaching out. I can guide you through the details and help you choose the best option.',
        ];
      }
    } else if (goal == 'Apologize') {
      replies = [
        'Hello, I sincerely apologize for the inconvenience. Thank you for your patience, and I’ll do my best to resolve this as quickly as possible.',
        'I’m really sorry about this. I understand your concern, and I’ll make sure we handle it properly.',
        'Thank you for letting us know. We apologize for the issue and appreciate the chance to make it right.',
      ];
    } else if (goal == 'Negotiate') {
      replies = [
        'Thank you for your offer. At the moment, this is our best price, but I can make a small adjustment if you confirm today.',
        'I understand your request. The price reflects the quality of $businessText, but I’m happy to discuss a fair option.',
        'I appreciate your offer. I can be a little flexible, but I also want to maintain the quality and service you expect.',
      ];
    } else if (goal == 'Follow up') {
      replies = [
        'Hi! I just wanted to follow up and see if you’re still interested. I’d be happy to answer any questions.',
        'Hello, I hope you’re doing well. I’m checking in to see if you’d like to continue with your order.',
        'Just a quick follow-up. The offer is still available, and I can help you complete everything whenever you’re ready.',
      ];
    } else if (goal == 'Ask for payment') {
      replies = [
        'Hello, this is a friendly reminder that the payment is still pending. Please let me know once it has been completed.',
        'Hi! To confirm your order, please complete the payment when convenient. I’ll proceed as soon as it’s received.',
        'Thank you again for your order. The next step is completing the payment so we can move forward.',
      ];
    } else {
      replies = [
        'Thank you for your feedback. We’re sorry to hear about your experience and would appreciate the chance to make things right.',
        'We apologize for the inconvenience. Please send us more details so we can review the situation and help you properly.',
        'Thank you for bringing this to our attention. Your feedback matters, and we’ll do our best to resolve the issue.',
      ];
    }

    replies = replies.map((reply) {
      return _adaptTone(reply, tone, platform);
    }).toList();

    return replies;
  }

  String _adaptTone(String reply, String tone, String platform) {
    final isFormalPlatform = platform == 'Gmail' ||
        platform == 'LinkedIn' ||
        platform == 'Upwork';

    if (tone == 'Short') {
      if (_selectedGoal == 'Sell') {
        return 'Yes, it’s available. I’d be happy to help you confirm your order.';
      }
      if (_selectedGoal == 'Apologize') {
        return 'I’m sorry for the inconvenience. I’ll help resolve this as soon as possible.';
      }
      if (_selectedGoal == 'Negotiate') {
        return 'This is our best price, but I can offer a small adjustment today.';
      }
      if (_selectedGoal == 'Follow up') {
        return 'Hi! Just following up to see if you’re still interested.';
      }
      if (_selectedGoal == 'Ask for payment') {
        return 'Friendly reminder: the payment is still pending. Please let me know once completed.';
      }
      return 'Thank you for your feedback. We apologize and will do our best to resolve this.';
    }

    if (tone == 'Friendly' && !isFormalPlatform) {
      return '$reply 😊';
    }

    if (tone == 'Firm') {
      return reply
          .replaceAll('I’d be happy to', 'I can')
          .replaceAll('if you’d like', 'when you are ready')
          .replaceAll('small discount', 'limited discount');
    }

    return reply;
  }

  Future<void> _copyReply(String text) async {
    await Clipboard.setData(ClipboardData(text: text));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reply copied')),
    );
  }

  void _clearAll() {
    setState(() {
      _messageController.clear();
      _replies.clear();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _businessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputCard(),
                    const SizedBox(height: 16),
                    _buildBusinessCard(),
                    const SizedBox(height: 22),
                    _buildSelector(
                      title: 'Reply goal',
                      values: _goals,
                      selectedValue: _selectedGoal,
                      onChanged: (value) {
                        setState(() => _selectedGoal = value);
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildSelector(
                      title: 'Tone',
                      values: _tones,
                      selectedValue: _selectedTone,
                      onChanged: (value) {
                        setState(() => _selectedTone = value);
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildSelector(
                      title: 'Platform',
                      values: _platforms,
                      selectedValue: _selectedPlatform,
                      onChanged: (value) {
                        setState(() => _selectedPlatform = value);
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildGenerateButton(),
                    const SizedBox(height: 10),
                    _buildClearButton(),
                    const SizedBox(height: 24),
                    if (_replies.isNotEmpty) _buildRepliesSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 34),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFB800),
            Color(0xFFFFD15C),
            Color(0xFFFFE49C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(38),
          bottomRight: Radius.circular(38),
        ),
      ),
      child: Column(
        children: [
          _buildSunIcon(),
          const SizedBox(height: 18),
          const Text(
            'ReplyBoss AI',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1F2933),
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Write perfect English replies in seconds.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunIcon() {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFF7A00),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7A00).withOpacity(0.35),
            blurRadius: 30,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 28,
            left: 27,
            child: _eye(),
          ),
          Positioned(
            top: 28,
            right: 27,
            child: _eye(),
          ),
          const Positioned(
            top: 38,
            child: Text(
              '⌣',
              style: TextStyle(
                fontSize: 32,
                color: Color(0xFF1F2933),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eye() {
    return Container(
      width: 9,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2933),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildInputCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer message',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF1F2933),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _messageController,
            minLines: 4,
            maxLines: 7,
            style: const TextStyle(
              color: Color(0xFF1F2933),
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Paste the message you received here...',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: const Color(0xFFFFF8EE),
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFF3D7B6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFF3D7B6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color(0xFFFFA726),
                  width: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business profile',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF1F2933),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Example: handmade products, beauty salon, freelance design...',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _businessController,
                  style: const TextStyle(color: Color(0xFF1F2933)),
                  decoration: InputDecoration(
                    hintText: 'What do you sell or offer?',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: const Color(0xFFFFF8EE),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFF3D7B6)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFF3D7B6)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: _saveBusinessProfile,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.save_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelector({
    required String title,
    required List<String> values,
    required String selectedValue,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1F2933),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: values.map((value) {
            final isSelected = selectedValue == value;

            return ChoiceChip(
              selected: isSelected,
              label: Text(value),
              labelStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFF1F2933)
                    : const Color(0xFF6B7280),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              selectedColor: const Color(0xFFFFDFA6),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFFFFA726)
                    : const Color(0xFFE5E7EB),
              ),
              showCheckmark: false,
              onSelected: (_) => onChanged(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _generateReplies,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF147DF5),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Generate Reply',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _clearAll,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1F2933),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.white,
        ),
        child: const Text(
          'Clear',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildRepliesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggested replies',
          style: TextStyle(
            color: Color(0xFF1F2933),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(_replies.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildReplyCard(index + 1, _replies[index]),
          );
        }),
      ],
    );
  }

  Widget _buildReplyCard(int number, String reply) {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFFFFDFA6),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Color(0xFF1F2933),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Ready reply',
                style: TextStyle(
                  color: Color(0xFF1F2933),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _copyReply(reply),
                icon: const Icon(Icons.copy_rounded),
                color: const Color(0xFF147DF5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reply,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 15.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
