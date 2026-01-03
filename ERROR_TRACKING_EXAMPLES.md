# Error Tracking Examples & Best Practices

## Common Error Tracking Patterns for Zidni App

This guide shows you how to properly track errors in the Zidni app across Flutter, Laravel, and Python components.

---

## Flutter Mobile App Examples

### 1. Track Firestore Errors

```dart
// lib/services/firestore_service.dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<List<DealFolder>> getDealFolders() async {
  if (_uid == null) {
    // Capture authentication errors
    Sentry.captureMessage(
      'User not authenticated when fetching deal folders',
      level: SentryLevel.warning,
    );
    throw AuthenticationException("User not logged in");
  }

  try {
    final snapshot = await _db
        .collection('deal_folders')
        .where('ownerUid', isEqualTo: _uid)
        .get();

    return snapshot.docs.map((doc) => DealFolder.fromFirestore(doc)).toList();
  } on FirebaseException catch (error, stackTrace) {
    // Capture Firebase-specific errors
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: Hint.withMap({
        'operation': 'getDealFolders',
        'userId': _uid,
        'errorCode': error.code,
      }),
    );
    throw DealFolderException('Failed to fetch folders: ${error.message}');
  } catch (error, stackTrace) {
    // Capture unexpected errors
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: Hint.withMap({'operation': 'getDealFolders'}),
    );
    rethrow;
  }
}
```

---

### 2. Track STT Engine Errors

```dart
// lib/services/stt_engine_speech_to_text.dart
import 'package:sentry_flutter/sentry_flutter.dart';

@override
Future<void> startListening({
  required void Function(String) onResult,
  required void Function() onListening,
}) async {
  try {
    _blockedThisInteraction = false;
    if (_speech.isListening) return;

    final available = await _speech.initialize(
      onError: (error) {
        Sentry.captureMessage(
          'STT error: ${error.errorMsg}',
          level: SentryLevel.error,
          withScope: (scope) {
            scope.setTag('errorType', error.errorMsg);
            scope.setTag('permanent', error.permanent.toString());
          },
        );
      },
    );

    if (!available) {
      Sentry.captureMessage(
        'Speech recognition not available',
        level: SentryLevel.warning,
      );
      return;
    }

    await _speech.listen(onResult: onResult);
    onListening();
  } catch (error, stackTrace) {
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: Hint.withMap({'operation': 'startListening'}),
    );
    _setBlocked();
  }
}
```

---

### 3. Track Offline Queue Failures

```dart
// lib/services/offline_capture_queue.dart
import 'package:sentry_flutter/sentry_flutter.dart';

static Future<void> processQueue() async {
  final queue = await getQueue();
  if (queue.isEmpty) return;

  Sentry.addBreadcrumb(Breadcrumb(
    message: 'Processing offline queue',
    level: SentryLevel.info,
    data: {'queueSize': queue.length},
  ));

  for (final capture in queue) {
    try {
      await _uploadCapture(capture);
      await removeFromQueue(capture.id);

      Sentry.addBreadcrumb(Breadcrumb(
        message: 'Uploaded offline capture',
        category: 'offline_sync',
        level: SentryLevel.info,
      ));
    } catch (error, stackTrace) {
      // Don't remove from queue if upload failed
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'operation': 'processOfflineQueue',
          'captureId': capture.id,
          'folderId': capture.folderId,
        }),
      );

      // Stop processing queue on error
      break;
    }
  }
}
```

---

### 4. Track Payment/Billing Errors

```dart
// lib/billing/services/entitlement_service.dart
import 'package:sentry_flutter/sentry_flutter.dart';

static Future<void> upgradeToBusinessSolo({DateTime? expiresAt}) async {
  final transaction = Sentry.startTransaction(
    'upgradeToBusinessSolo',
    'task',
  );

  try {
    final current = await getEntitlement();
    final upgraded = Entitlement(
      tier: SubscriptionTier.businessSolo,
      expiresAt: expiresAt,
      updatedAt: DateTime.now(),
      hasEverPaid: true,
    );

    await setEntitlement(upgraded);

    // Log successful upgrade
    Sentry.captureMessage(
      'User upgraded to Business Solo',
      level: SentryLevel.info,
      withScope: (scope) {
        scope.setTag('fromTier', current.tier.id);
        scope.setTag('toTier', upgraded.tier.id);
      },
    );

    transaction.finish(status: SpanStatus.ok());
  } catch (error, stackTrace) {
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: Hint.withMap({
        'operation': 'upgrade',
        'targetTier': 'business_solo',
      }),
    );
    transaction.finish(status: SpanStatus.internalError());
    rethrow;
  }
}
```

---

### 5. Track Network Errors

```dart
// lib/services/local_companion_client.dart
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:http/http.dart' as http;

Future<String> transcribeAudio(File audioFile) async {
  final url = await OfflineSettingsService.getCompanionUrl();

  try {
    final request = http.MultipartRequest('POST', Uri.parse('$url/stt'));
    request.files.add(await http.MultipartFile.fromPath('audio', audioFile.path));

    final response = await request.send().timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      return jsonDecode(body)['transcript'];
    } else {
      // Track non-200 responses
      Sentry.captureMessage(
        'STT request failed',
        level: SentryLevel.error,
        withScope: (scope) {
          scope.setTag('statusCode', response.statusCode.toString());
          scope.setTag('companionUrl', url);
        },
      );
      throw Exception('STT failed with status ${response.statusCode}');
    }
  } on TimeoutException catch (error, stackTrace) {
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: Hint.withMap({
        'operation': 'transcribeAudio',
        'companionUrl': url,
        'errorType': 'timeout',
      }),
    );
    throw Exception('STT request timed out');
  } on SocketException catch (error, stackTrace) {
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: Hint.withMap({
        'operation': 'transcribeAudio',
        'companionUrl': url,
        'errorType': 'network',
      }),
    );
    throw Exception('Could not connect to companion server');
  }
}
```

---

## Laravel Backend Examples

### 1. Track API Errors

```php
// app/Http/Controllers/DealController.php
use Sentry\Laravel\Facades\Sentry;

public function store(Request $request)
{
    $transaction = Sentry::startTransaction(
        (new \Sentry\Tracing\TransactionContext())
            ->setName('CreateDeal')
            ->setOp('http.request')
    );

    Sentry::SentrySdk::getCurrentHub()->setSpan($transaction);

    try {
        $validated = $request->validate([
            'product_name' => 'required|string|max:255',
            'supplier' => 'required|string',
        ]);

        $deal = Deal::create([
            'user_id' => auth()->id(),
            'product_name' => $validated['product_name'],
            'supplier' => $validated['supplier'],
        ]);

        $transaction->finish(\Sentry\Tracing\SpanStatus::ok());

        return response()->json($deal, 201);
    } catch (\Illuminate\Validation\ValidationException $e) {
        Sentry::captureMessage('Deal validation failed', [
            'level' => 'warning',
            'extra' => ['errors' => $e->errors()],
        ]);

        $transaction->finish(\Sentry\Tracing\SpanStatus::invalidArgument());
        throw $e;
    } catch (\Exception $e) {
        Sentry::captureException($e);
        $transaction->finish(\Sentry\Tracing\SpanStatus::internalError());

        return response()->json([
            'error' => 'Failed to create deal'
        ], 500);
    }
}
```

---

### 2. Track Database Errors

```php
// app/Services/DealService.php
use Sentry\Laravel\Facades\Sentry;
use Illuminate\Database\QueryException;

public function getDealsByUser(int $userId): Collection
{
    try {
        return Deal::where('user_id', $userId)
            ->with('captures')
            ->orderBy('created_at', 'desc')
            ->get();
    } catch (QueryException $e) {
        // Track database errors
        Sentry::captureException($e, [
            'extra' => [
                'query' => $e->getSql(),
                'bindings' => $e->getBindings(),
                'userId' => $userId,
            ],
            'tags' => [
                'errorCode' => $e->getCode(),
            ],
        ]);

        throw new ServiceException('Failed to fetch user deals');
    }
}
```

---

### 3. Track Authentication Errors

```php
// app/Http/Middleware/Authenticate.php
use Sentry\Laravel\Facades\Sentry;

protected function unauthenticated($request, array $guards)
{
    Sentry::addBreadcrumb([
        'category' => 'auth',
        'message' => 'Unauthenticated request',
        'level' => 'warning',
        'data' => [
            'path' => $request->path(),
            'method' => $request->method(),
            'ip' => $request->ip(),
        ],
    ]);

    parent::unauthenticated($request, $guards);
}
```

---

## Python Companion Server Examples

### 1. Track STT Processing Errors

```python
# local_companion/server.py
from sentry_sdk import capture_exception, capture_message, add_breadcrumb

@app.route('/stt', methods=['POST'])
@limiter.limit("10 per minute")
def speech_to_text():
    add_breadcrumb(
        category='stt',
        message='STT request received',
        level='info',
        data={'file_size': request.content_length},
    )

    try:
        # ... validation code ...

        model = get_whisper_model()

        if model == "placeholder":
            capture_message(
                'Whisper model not available',
                level='warning',
            )
            transcript = "[Whisper not installed]"
        else:
            add_breadcrumb(
                category='stt',
                message='Transcribing audio',
                level='info',
            )

            result = model.transcribe(tmp_path)
            transcript = result.get('text', '').strip()

        return jsonify({'transcript': transcript})

    except Exception as e:
        # Capture with context
        capture_exception(e, {
            'extra': {
                'file_extension': file_ext,
                'file_size': file_size,
            },
            'tags': {
                'endpoint': 'stt',
            },
        })
        logger.error(f"STT processing failed: {str(e)}", exc_info=True)
        return jsonify({'error': 'Speech transcription failed', 'transcript': ''}), 500
```

---

### 2. Track LLM Generation Errors

```python
@app.route('/llm', methods=['POST'])
@limiter.limit("20 per minute")
def generate_text():
    try:
        data = request.get_json()
        prompt = str(data['prompt']).strip()

        add_breadcrumb(
            category='llm',
            message='LLM request received',
            level='info',
            data={'prompt_length': len(prompt)},
        )

        text = get_llm_response(prompt, data.get('system_prompt'), int(data.get('max_tokens', 1024)))

        return jsonify({
            'text': text,
            'tokens_used': len(text.split())
        })

    except ValueError as e:
        capture_exception(e, {
            'level': 'warning',
            'tags': {'error_type': 'validation'},
        })
        return jsonify({'error': 'Invalid request format'}), 400
    except Exception as e:
        capture_exception(e)
        logger.error(f"LLM error: {str(e)}", exc_info=True)
        return jsonify({'error': 'Text generation failed'}), 500
```

---

### 3. Track Rate Limit Exceeded

```python
from flask_limiter import Limiter
from sentry_sdk import capture_message

@limiter.request_filter
def rate_limit_filter():
    # Log rate limit hits
    if limiter.current_limit.exceeded:
        capture_message(
            'Rate limit exceeded',
            level='warning',
            extras={
                'endpoint': request.endpoint,
                'ip': request.remote_addr,
                'limit': str(limiter.current_limit),
            },
        )
    return False  # Don't skip rate limiting
```

---

## Best Practices

### 1. Always Add Context

❌ **Bad:**
```dart
catch (e) {
  Sentry.captureException(e);
}
```

✅ **Good:**
```dart
catch (error, stackTrace) {
  await Sentry.captureException(
    error,
    stackTrace: stackTrace,
    hint: Hint.withMap({
      'operation': 'uploadDocument',
      'documentId': docId,
      'userId': currentUser.uid,
    }),
  );
}
```

---

### 2. Use Breadcrumbs for User Actions

```dart
// Track user navigation
Sentry.addBreadcrumb(Breadcrumb(
  message: 'User navigated to Deal Folders screen',
  category: 'navigation',
  level: SentryLevel.info,
));

// Track user actions
Sentry.addBreadcrumb(Breadcrumb(
  message: 'User created new deal folder',
  category: 'user_action',
  level: SentryLevel.info,
  data: {'folderName': folderName},
));
```

---

### 3. Set User Context After Login

```dart
// After Firebase authentication
final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  Sentry.configureScope((scope) {
    scope.setUser(SentryUser(
      id: user.uid,
      username: user.displayName,
      // Email redacted by beforeSend in main.dart
    ));
  });
}
```

---

### 4. Use Tags for Filtering

```dart
Sentry.captureException(
  error,
  withScope: (scope) {
    scope.setTag('feature', 'offline_sync');
    scope.setTag('network_type', 'wifi');
    scope.setTag('app_version', '1.0.0');
  },
);
```

---

### 5. Performance Monitoring

```dart
// Track slow operations
final transaction = Sentry.startTransaction('loadDashboard', 'task');

try {
  final span1 = transaction.startChild('fetchDeals');
  final deals = await firestoreService.getDealFolders();
  span1.finish(status: SpanStatus.ok());

  final span2 = transaction.startChild('renderUI');
  setState(() {
    _deals = deals;
  });
  span2.finish(status: SpanStatus.ok());

  transaction.finish(status: SpanStatus.ok());
} catch (e) {
  transaction.finish(status: SpanStatus.unknownError());
  rethrow;
}
```

---

## What NOT to Track

### ❌ Don't Track Expected Errors

```dart
// Bad - this is expected behavior
if (user == null) {
  Sentry.captureException(Exception('User not logged in'));
  return;
}

// Good - handle gracefully without Sentry
if (user == null) {
  return; // Expected state, no error
}
```

---

### ❌ Don't Track Sensitive Data

```dart
// Bad - leaks password
catch (error) {
  Sentry.captureException(error, hint: Hint.withMap({
    'password': userPassword,  // NEVER!
  }));
}

// Good - no sensitive data
catch (error) {
  Sentry.captureException(error, hint: Hint.withMap({
    'operation': 'login',
  }));
}
```

---

### ❌ Don't Over-Track

```dart
// Bad - too noisy
debugPrint('Button clicked');
Sentry.captureMessage('Button clicked');  // Don't!

// Good - only track important events
onButtonPressed() {
  // Just handle the action, no Sentry needed
  navigateToScreen();
}
```

---

## Monitoring Checklist

Daily:
- [ ] Check Sentry dashboard for new issues
- [ ] Review high-frequency errors
- [ ] Check crash-free session rate

Weekly:
- [ ] Review performance trends
- [ ] Update error grouping rules
- [ ] Close resolved issues

Monthly:
- [ ] Review Sentry quota usage
- [ ] Update alert rules
- [ ] Archive old issues

---

## Quick Reference

### Severity Levels
- `fatal` - App crash, requires immediate attention
- `error` - Exception occurred, user impacted
- `warning` - Something unexpected, not critical
- `info` - Informational message
- `debug` - Debug information (dev only)

### When to Use Each Level

- **fatal**: App crashes, unrecoverable errors
- **error**: Failed API calls, database errors, unhandled exceptions
- **warning**: Deprecated features, retry attempts, fallback used
- **info**: User actions, successful operations, milestones
- **debug**: Verbose logging (development only)

---

**Remember:** Good error tracking helps you fix bugs faster and improve user experience!
