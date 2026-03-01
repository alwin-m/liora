import 'package:flutter/material.dart';
import '../services/ai_service.dart';

/// AI SETTINGS SCREEN
///
/// Allows users to:
/// - Enable/Disable AI features
/// - Configure API keys (Claude, Ollama)
/// - Manage privacy settings
/// - View AI capability status
/// - Clear AI cache
class AISettingsScreen extends StatefulWidget {
  const AISettingsScreen({Key? key}) : super(key: key);

  @override
  State<AISettingsScreen> createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends State<AISettingsScreen> {
  final AIService _aiService = AIService();
  late TextEditingController _ollamaController;
  late TextEditingController _claudeKeyController;
  bool _aiEnabled = false;
  bool _isInitialized = false;
  String? _currentProvider;

  @override
  void initState() {
    super.initState();
    _ollamaController = TextEditingController();
    _claudeKeyController = TextEditingController();
    _initialize();
  }

  void _initialize() async {
    await _aiService.initialize();
    setState(() {
      _aiEnabled = _aiService.isEnabled;
      _currentProvider = _aiService.currentProvider.toString();
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _ollamaController.dispose();
    _claudeKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AI Settings'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI-Enhanced Cycle Prediction',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your medical data stays on your device. AI helps personalize predictions.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // MAIN TOGGLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enable AI Features',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enhance cycle predictions with AI',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Switch(
                  value: _aiEnabled,
                  onChanged: (value) async {
                    await _aiService.setAIEnabled(value);
                    setState(() => _aiEnabled = value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? 'AI features enabled'
                              : 'AI features disabled',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // PROVIDER SELECTION
            if (_aiEnabled) ...[
              Text(
                'AI Provider',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),

              // Local Model (Default)
              _buildProviderCard(
                title: 'Local Processing (Default)',
                subtitle: 'Fast, private, no API key needed',
                isSelected: _currentProvider == 'AIProvider.local',
                onTap: () {
                  setState(() => _currentProvider = 'AIProvider.local');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Using local AI processing')),
                  );
                },
                icon: Icons.phone_android,
              ),
              const SizedBox(height: 12),

              // Ollama Configuration
              ExpansionTile(
                title: const Text('Ollama (On-Device LLM)'),
                subtitle: const Text('Run Llama 3 locally'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Setup Instructions:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        _buildInstruction(
                          '1. Install Ollama from ollama.ai',
                          'https://ollama.ai',
                        ),
                        _buildInstruction(
                          '2. Run: ollama run llama3',
                          'Starts Ollama server',
                        ),
                        _buildInstruction(
                          '3. Enter server URL below',
                          'Usually http://localhost:11434',
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _ollamaController,
                          decoration: InputDecoration(
                            labelText: 'Ollama URL',
                            hintText: 'http://localhost:11434',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_ollamaController.text.isNotEmpty) {
                                await _aiService.configureOllama(
                                  _ollamaController.text,
                                );
                                setState(() {
                                  _currentProvider = 'AIProvider.ollama';
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Ollama configured'),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('Connect to Ollama'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Claude API Configuration
              ExpansionTile(
                title: const Text('Claude API (Cloud)'),
                subtitle: const Text('Advanced AI (requires API key)'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Setup Instructions:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        _buildInstruction(
                          '1. Get API key from console.anthropic.com',
                          'Free trial available',
                        ),
                        _buildInstruction(
                          '2. Paste your API key below',
                          'Stored securely on your device',
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _claudeKeyController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Claude API Key',
                            hintText: 'sk-ant-...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_claudeKeyController.text.isNotEmpty) {
                                await _aiService.configureClaudeAPI(
                                  _claudeKeyController.text,
                                );
                                setState(() {
                                  _currentProvider = 'AIProvider.claudeApi';
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Claude API configured'),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('Connect to Claude API'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // DATA MANAGEMENT
              Text(
                'Data Management',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await _aiService.clearCache();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('AI cache cleared')),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear AI Cache'),
                ),
              ),
              const SizedBox(height: 24),

              // PRIVACY POLICY
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔒 Privacy Commitment',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Your cycle data NEVER leaves your device\n'
                      '• AI processing uses only your local data\n'
                      '• Optional API keys are stored encrypted\n'
                      '• You control what APIs are used\n'
                      '• Enable/disable anytime',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Enable AI features to configure providers and unlock enhanced predictions.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey[600],
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blue, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String text, String subtext) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontSize: 13)),
                Text(
                  subtext,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
