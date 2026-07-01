import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/network_config.dart';

class NetworkTestScreen extends StatefulWidget {
  const NetworkTestScreen({super.key});

  @override
  State<NetworkTestScreen> createState() => _NetworkTestScreenState();
}

class _NetworkTestScreenState extends State<NetworkTestScreen> {
  String _output = 'Press a button to start probe...';
  bool _isLoading = false;

  void _log(String message) {
    setState(() => _output = '$message\n\n$_output');
    debugPrint('🔎 [FORENSIC] $message');
  }

  Future<void> _pingBackend() async {
    setState(() { _isLoading = true; _output = ''; });
    _log('Starting Probe A: Native HTTP GET...');
    _log('OS: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
    _log('Resolved Host: ${NetworkConfig.host}');
    _log('Target URL: http://${NetworkConfig.host}:${NetworkConfig.port}/api/v1/home');

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(Uri.parse('http://${NetworkConfig.host}:${NetworkConfig.port}/api/v1/home'));
      final response = await request.close();
      
      _log('✓ RESPONSE RECEIVED');
      _log('Status Code: ${response.statusCode}');
      _log('Headers: ${response.headers}');
      
      final body = await response.transform(utf8.decoder).join();
      _log('Body Snippet: ${body.substring(0, body.length > 100 ? 100 : body.length)}');
    } catch (e, stack) {
      _log('✗ PROBE FAILED');
      _log('Error Type: ${e.runtimeType}');
      _log('Error Message: $e');
      _log('Stack Trace: $stack');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _postTestLogin() async {
    setState(() { _isLoading = true; _output = ''; });
    _log('Starting Probe B: Raw Socket POST...');
    final url = '${NetworkConfig.baseUrl}/auth/login';
    _log('Target URL: $url');

    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse(url));
      request.headers.contentType = ContentType('application', 'json', charset: 'utf-8');
      
      final bodyData = jsonEncode({'phone': '0550999888', 'password': 'password123'});
      _log('Payload: $bodyData');
      
      request.write(bodyData);
      final response = await request.close();

      _log('✓ RESPONSE RECEIVED');
      _log('Status Code: ${response.statusCode}');
      final body = await response.transform(utf8.decoder).join();
      _log('Response: $body');
    } catch (e, stack) {
      _log('✗ PROBE FAILED');
      _log('Error: $e');
      _log('Stack: $stack');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network Forensic Lab')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.network_check),
              label: const Text('PROBE A: PING BACKEND (Raw GET)'),
              onPressed: _isLoading ? null : _pingBackend,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.security_update_good_rounded),
              label: const Text('PROBE B: POST TEST LOGIN (Raw Socket)'),
              onPressed: _isLoading ? null : _postTestLogin,
            ),
            const Divider(height: 32),
            const Text('EVIDENCE LOGS:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black,
                child: SingleChildScrollView(
                  child: Text(
                    _output,
                    style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
