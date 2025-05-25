import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WebhookService {
  final String webhookUrl;

  WebhookService({required this.webhookUrl});

  Future<Map<String, dynamic>> fetchWebhookData() async {
    try {
      final response = await http.get(Uri.parse(webhookUrl));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch webhook data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to webhook: $e');
    }
  }
}

class WebhookConsumerPage extends StatefulWidget {
  const WebhookConsumerPage({Key? key}) : super(key: key);

  @override
  State<WebhookConsumerPage> createState() => _WebhookConsumerPageState();
}

class _WebhookConsumerPageState extends State<WebhookConsumerPage> {
  final TextEditingController _webhookUrlController = TextEditingController();
  late WebhookService _webhookService = WebhookService(
      webhookUrl: 'https://your-webhook-endpoint.com/hook'
  );

  Map<String, dynamic>? _lastWebhookData;
  bool _isLoading = false;
  String _errorMessage = '';

  // Polling timer
  Future<void>? _pollingFuture;

  @override
  void initState() {
    super.initState();
    _webhookUrlController.text = _webhookService.webhookUrl;
  }

  @override
  void dispose() {
    _webhookUrlController.dispose();
    super.dispose();
  }

  // Fetch data from webhook
  Future<void> _fetchWebhookData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _webhookService.fetchWebhookData();
      setState(() {
        _lastWebhookData = data;
        _isLoading = false;

        // Process the data and make changes as needed
        _processWebhookData(data);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // Process the webhook data and make necessary changes
  void _processWebhookData(Map<String, dynamic> data) {
    // Example: Check for specific notification types
    if (data.containsKey('notification_type')) {
      final notificationType = data['notification_type'];

      switch (notificationType) {
        case 'new_message':
          _handleNewMessage(data);
          break;
        case 'update_available':
          _handleUpdateAvailable(data);
          break;
        case 'account_status':
          _handleAccountStatus(data);
          break;
        default:
          print('Unknown notification type: $notificationType');
      }
    }
  }

  // Handle different notification types
  void _handleNewMessage(Map<String, dynamic> data) {
    // Example: Show a notification or update UI
    final message = data['message'] ?? 'New message received';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleUpdateAvailable(Map<String, dynamic> data) {
    // Example: Show update dialog
    final version = data['version'] ?? 'unknown';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: Text('Version $version is now available. Would you like to update?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              // Implement update logic
              Navigator.pop(context);
            },
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  void _handleAccountStatus(Map<String, dynamic> data) {
    // Example: Update account status in app state
    final status = data['status'] ?? 'unknown';
    print('Account status updated to: $status');
    // Update your app state accordingly
  }

  // Update webhook URL
  void _updateWebhookUrl() {
    final newUrl = _webhookUrlController.text.trim();
    if (newUrl.isNotEmpty) {
      setState(() {
        _webhookService = WebhookService(webhookUrl: newUrl);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Webhook Consumer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Webhook URL field
            TextField(
              controller: _webhookUrlController,
              decoration: const InputDecoration(
                labelText: 'Webhook URL',
                hintText: 'https://your-webhook-endpoint.com/hook',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _updateWebhookUrl,
              child: const Text('Update URL'),
            ),
            const SizedBox(height: 16),

            // Fetch data button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _fetchWebhookData,
              icon: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.refresh),
              label: const Text('Fetch Webhook Data'),
            ),
            const SizedBox(height: 16),

            // Error message
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade100,
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),

            // Data display
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latest Webhook Data:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _lastWebhookData == null
                            ? const Center(
                          child: Text('No data fetched yet'),
                        )
                            : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final entry in _lastWebhookData!.entries)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${entry.key}:',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        entry.value.toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Divider(),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Enable automatic polling for webhook updates
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Auto-Polling'),
              content: const Text('Would you like to enable automatic polling every 30 seconds?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Start polling logic here
                    // Note: In a real app, you'd use a better approach for background polling
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Auto-polling enabled')),
                    );
                  },
                  child: const Text('Yes'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.timer),
      ),
    );
  }
}