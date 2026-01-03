import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:zidni_mobile/firebase_options.dart';
import 'package:zidni_mobile/services/firestore_service.dart';
import 'package:zidni_mobile/services/stt_engine.dart';
import 'package:zidni_mobile/services/stt_engine_speech_to_text.dart';
import 'package:zidni_mobile/zidni_shell.dart';
import 'package:zidni_mobile/core/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // MONITORING: Initialize Sentry for error tracking
  await SentryFlutter.init(
    (options) {
      options.dsn = Env.sentryDsn;
      options.environment = Env.environment;
      options.release = 'zidni@${Env.appVersion}';

      // Performance monitoring
      options.tracesSampleRate = Env.isProduction ? 0.2 : 1.0;

      // Attach screenshots on errors (helps with debugging UI issues)
      options.attachScreenshot = true;
      options.screenshotQuality = SentryScreenshotQuality.low;

      // Filter sensitive data
      options.beforeSend = (event, {hint}) {
        // Remove user email from error reports for privacy
        if (event.user?.email != null) {
          event = event.copyWith(
            user: event.user?.copyWith(email: '[REDACTED]'),
          );
        }
        return event;
      };

      // Don't send errors in debug mode
      options.debug = !Env.isProduction;
    },
    appRunner: () => runApp(const ZidniApp()),
  );
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
    return MultiProvider(
      providers: [
        Provider<FirestoreService>(create: (_) => FirestoreService()),
      ],
      child: MaterialApp(
        title: 'Zidni',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        // MONITORING: Track navigation events in Sentry
        navigatorObservers: [
          SentryNavigatorObserver(),
        ],
        home: ZidniShell(sttEngine: _sttEngine),
      ),
    );
  }
}
