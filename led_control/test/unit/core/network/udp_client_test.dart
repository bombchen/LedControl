import 'package:flutter_test/flutter_test.dart';
import 'package:led_control/core/models/network_result.dart';
import 'package:led_control/core/network/udp_client.dart';

void main() {
  group('UDPClient', () {
    test('应该创建客户端实例', () {
      final client = UDPClient();
      expect(client, isNotNull);
      expect(client.isInitialized, false);
      client.close();
    });
  });
}
