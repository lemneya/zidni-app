import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zidni_mobile/firebase_options.dart';
import 'package:zidni_mobile/services/stt_engine.dart';
import 'package:zidni_mobile/services/stt_engine_speech_to_text.dart';
import 'package:zidni_mobile/zidni_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ZidniApp());
}

class ZidniApp extends StatefulWidget {
  const ZidniApp({super.key});

  @override
  State<ZidniApp> createState() => _ZidniAppState();
}

class _ZidniAppState extends State<ZidniApp> {
  late final SttEngine _sttEngine;

  @override
  void initState() {
    super.initState();
    _sttEngine = SttEngineSpeechToText();
    // IMPORTANT: do NOT call initialize() here
  }

  @override
  void dispose() {
    _sttEngine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zidni',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: ZidniShell(sttEngine: _sttEngine),
    );
  }
}
