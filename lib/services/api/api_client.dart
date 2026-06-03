import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../models/models.dart';

/// HTTP client for Reticulum Link's REST API.
///
/// Connects to localhost:4000 by default (the Phoenix endpoint).
/// All methods return parsed JSON or throw [ApiException].
class ApiClient {
  final String baseUrl;
  final HttpClient _http;

  ApiClient({this.baseUrl = 'http://localhost:4000'})
      : _http = HttpClient();

  /// GET /health — Quick health check.
  Future<HealthStatus> health() async {
    final json = await _get('/health');
    return HealthStatus(
      status: json['status'] as String,
      checks: (json['checks'] as Map<String, dynamic>).cast<String, bool>(),
      timestamp: json['timestamp'] as String,
    );
  }

  /// GET /api/status — Node status, uptime, peer count.
  Future<NodeStatus> status() async {
    final json = await _get('/api/status');
    return NodeStatus(
      node: json['node'] as String,
      version: json['version'] as String,
      uptime: json['uptime'] as int,
      links: json['links'] as int,
      paths: json['paths'] as int,
      messages: json['messages'] as int,
      propagation: json['propagation'] as bool,
    );
  }

  /// GET /api/peers — List known peers.
  Future<List<Peer>> peers() async {
    final json = await _get('/api/peers');
    final list = json['peers'] as List<dynamic>;
    return list.map((p) {
      final map = p as Map<String, dynamic>;
      return Peer(
        hash: map['hash'] as String,
        name: map['hash'] as String,
        lastSeen: DateTime.now(),
        linkQuality: 1.0,
        hops: map['hops'] as int? ?? 1,
        services: const [],
        isOnline: true,
        isFavorite: false,
      );
    }).toList();
  }

  /// GET /api/messages — List stored LXMF messages.
  Future<List<LxmfMessage>> messages() async {
    final json = await _get('/api/messages');
    final list = json['messages'] as List<dynamic>;
    return list.map((m) => _decodeMessage(m as Map<String, dynamic>)).toList();
  }

  /// POST /api/messages — Send a new LXMF message.
  Future<String> sendMessage({
    required String destination,
    required String source,
    required String content,
    String title = '',
  }) async {
    final json = await _post('/api/messages', {
      'destination': destination,
      'source': source,
      'content': content,
      'title': title,
    });
    return json['hash'] as String? ?? json['status'] as String;
  }

  LxmfMessage _decodeMessage(Map<String, dynamic> json) {
    final isOutgoing = json['source'] == 'local_identity';
    return LxmfMessage(
      id: json['hash'] as String,
      senderHash: json['source'] as String,
      recipientHash: json['destination'] as String,
      content: json['content'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        ((json['timestamp'] as num) * 1000).toInt(),
      ),
      status: MessageStatus.delivered,
      attachments: const [],
      isOutgoing: isOutgoing,
    );
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _http.getUrl(uri);
    request.headers.set('Accept', 'application/json');

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(body) as Map<String, dynamic>;
    }
    throw ApiException(
      statusCode: response.statusCode,
      body: body,
      path: path,
    );
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _http.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    request.write(jsonEncode(body));

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(responseBody) as Map<String, dynamic>;
    }
    throw ApiException(
      statusCode: response.statusCode,
      body: responseBody,
      path: path,
    );
  }

  void dispose() {
    _http.close();
  }
}

/// Health check response from /health.
class HealthStatus {
  final String status;
  final Map<String, bool> checks;
  final String timestamp;

  HealthStatus({
    required this.status,
    required this.checks,
    required this.timestamp,
  });
}

/// Node status from /api/status.
class NodeStatus {
  final String node;
  final String version;
  final int uptime;
  final int links;
  final int paths;
  final int messages;
  final bool propagation;

  NodeStatus({
    required this.node,
    required this.version,
    required this.uptime,
    required this.links,
    required this.paths,
    required this.messages,
    required this.propagation,
  });
}

/// API error.
class ApiException implements Exception {
  final int statusCode;
  final String body;
  final String path;

  ApiException({
    required this.statusCode,
    required this.body,
    required this.path,
  });

  @override
  String toString() => 'ApiException($statusCode) on $path: $body';
}
