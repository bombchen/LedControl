import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  const app = ProviderScope(child: LedControlApp());
  runApp(app);
}
