import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:karvaan/widgets/glass_container.dart';

class AICarCompanionTab extends StatefulWidget {
  const AICarCompanionTab({Key? key}) : super(key: key);

  @override
  State<AICarCompanionTab> createState() => _AICarCompanionTabState();
}

class _AICarCompanionTabState extends State<AICarCompanionTab> {
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  final List<_ChatMessage> _chatMessages = [];
  final TextEditingController _chatController = TextEditingController();
  static const String _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _geminiModel = 'gemini-flash-latest';

  // Default values (mid-range based on your app.py)
  double _engineRpm = 1150.0;
  double _lubOilPressure = 3.6;
  double _fuelPressure = 10.5;
  double _coolantPressure = 3.7;
  double _lubOilTemp = 80.0;
  double _coolantTemp = 128.0;
  double _tempDiff = 48.0;

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _predictEngineHealth() async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      // Use 10.0.2.2 for Android Emulator, localhost for Windows
      final url = Uri.parse('http://127.0.0.1:5000/predict');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'engine_rpm': _engineRpm,
          'lub_oil_pressure': _lubOilPressure,
          'fuel_pressure': _fuelPressure,
          'coolant_pressure': _coolantPressure,
          'lub_oil_temp': _lubOilTemp,
          'coolant_temp': _coolantTemp,
          'temp_difference': _tempDiff,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _result = jsonDecode(response.body) as Map<String, dynamic>;
        });
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Connection failed. Is the AI server running?');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _loadTestData() {
    setState(() {
      // Randomize values slightly for testing
      _engineRpm = 1500.0;
      _lubOilPressure = 2.0; // Low pressure (simulate issue)
      _fuelPressure = 10.0;
      _coolantPressure = 3.5;
      _lubOilTemp = 85.0;
      _coolantTemp = 130.0;
      _tempDiff = 50.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(theme),
        const SizedBox(height: 20),
        if (_result != null) _buildResultCard(theme),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Engine Parameters',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _loadTestData,
                    icon: const Icon(Icons.science, size: 16, color: Colors.cyanAccent),
                    label: const Text('Load Test Data', style: TextStyle(color: Colors.cyanAccent)),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 24),
              _buildSlider('Engine RPM', _engineRpm, 61.0, 2239.0, (v) => setState(() => _engineRpm = v)),
              _buildSlider('Lub Oil Pressure', _lubOilPressure, 0.0, 7.3, (v) => setState(() => _lubOilPressure = v)),
              _buildSlider('Fuel Pressure', _fuelPressure, 0.0, 21.2, (v) => setState(() => _fuelPressure = v)),
              _buildSlider('Coolant Pressure', _coolantPressure, 0.0, 7.5, (v) => setState(() => _coolantPressure = v)),
              _buildSlider('Lub Oil Temp', _lubOilTemp, 71.0, 90.0, (v) => setState(() => _lubOilTemp = v)),
              _buildSlider('Coolant Temp', _coolantTemp, 61.0, 196.0, (v) => setState(() => _coolantTemp = v)),
              _buildSlider('Temp Difference', _tempDiff, -23.0, 120.0, (v) => setState(() => _tempDiff = v)),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _predictEngineHealth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Analyze Engine Health', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [Colors.cyan.withOpacity(0.2), Colors.blue.withOpacity(0.2)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.cyanAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Car Companion',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Predictive maintenance powered by ML',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme) {
    final isNormal = _result!['prediction'] == 0;
    final confidence = (1.0 - (_result!['confidence'] as num)).abs() * 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        gradient: LinearGradient(
          colors: isNormal
              ? [Colors.green.withOpacity(0.3), Colors.greenAccent.withOpacity(0.1)]
              : [Colors.red.withOpacity(0.3), Colors.orange.withOpacity(0.1)],
        ),
        child: Column(
          children: [
            Icon(
              isNormal ? Icons.check_circle_outline : Icons.warning_amber_rounded,
              color: isNormal ? Colors.greenAccent : Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              isNormal ? 'Engine Condition Normal' : 'Maintenance Required',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Confidence: ${confidence.toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              isNormal
                  ? 'Your engine parameters look healthy. Keep up the regular maintenance!'
                  : 'Abnormal readings detected. We recommend visiting a mechanic soon.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _openAdvisor(context, isNormal),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Ask AI for next steps'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Text(value.toStringAsFixed(2), style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.cyanAccent,
            inactiveTrackColor: Colors.white10,
            thumbColor: Colors.white,
            overlayColor: Colors.cyanAccent.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Future<void> _openAdvisor(BuildContext context, bool isNormal) async {
    if (_geminiApiKey.isEmpty) {
      _showError('Missing GEMINI_API_KEY. Add via --dart-define GEMINI_API_KEY=your_key');
      return;
    }

    _chatMessages.clear();
    final summary = StringBuffer()
      ..writeln('Engine analysis: ${isNormal ? 'Normal' : 'Maintenance Required'}')
        ..writeln('RPM ${_engineRpm.toStringAsFixed(0)}, Coolant ${_coolantTemp.toStringAsFixed(1)}C, Oil ${_lubOilTemp.toStringAsFixed(1)}C, FuelP ${_fuelPressure.toStringAsFixed(1)}, OilP ${_lubOilPressure.toStringAsFixed(1)}, CoolantP ${_coolantPressure.toStringAsFixed(1)}, dT ${_tempDiff.toStringAsFixed(1)}');

    await _sendGeminiPrompt(
      'Act as an automotive maintenance expert. Based on these readings, give concise next steps, risk level (low/med/high), and a short checklist.',
      summary.toString(),
    );

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.support_agent, color: Colors.cyanAccent),
                  const SizedBox(width: 8),
                  Text(
                    'Karavan Chat',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 320,
                child: ListView.builder(
                  itemCount: _chatMessages.length,
                  itemBuilder: (context, index) {
                    final msg = _chatMessages[index];
                    final align = msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                    final color = msg.isUser
                        ? Colors.cyanAccent.withOpacity(0.2)
                        : Colors.white.withOpacity(0.08);
                    return Column(
                      crossAxisAlignment: align,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            msg.text,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ask how to improve... ',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _handleUserQuestion(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _handleUserQuestion,
                    icon: const Icon(Icons.send, color: Colors.cyanAccent),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleUserQuestion() async {
    final query = _chatController.text.trim();
    if (query.isEmpty) return;
    _chatController.clear();
    setState(() {
      _chatMessages.add(_ChatMessage(text: query, isUser: true));
    });
    await _sendGeminiPrompt(query, null);
    if (mounted) setState(() {});
  }

  Future<void> _sendGeminiPrompt(String prompt, String? contextLine) async {
    if (_geminiApiKey.isEmpty) return;
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_geminiModel:generateContent?key=$_geminiApiKey',
    );

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                if (contextLine != null) {'text': contextLine},
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final text = (body['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?) ?? 'No advice returned.';
        setState(() {
          _chatMessages.add(_ChatMessage(text: text, isUser: false));
        });
      } else {
          final body = res.body.isNotEmpty ? res.body : 'No response body';
          _showError('Gemini error: ${res.statusCode} - $body');
      }
    } catch (e) {
      _showError('Failed to reach Gemini. Check network.');
    }
  }
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}
