# Sentry Monitoring Setup Guide

## What is Sentry?

Sentry is an error tracking and performance monitoring platform that helps you:
- Track errors and exceptions in production
- Monitor application performance
- Get alerted when issues occur
- View stack traces and user context
- Fix bugs faster with actionable insights

**Cost:** Free tier includes 5,000 errors/month + 10,000 performance units (sufficient for small-medium apps)

---

## Quick Setup (15 minutes)

### Step 1: Create Sentry Account

1. Go to https://sentry.io/signup/
2. Sign up with GitHub or email
3. Create a new organization (e.g., "Zidni")

### Step 2: Create Projects

You need **3 separate projects** (one for each component):

1. **Flutter Mobile App**
   - Click "Create Project"
   - Platform: Flutter
   - Alert frequency: "Only on new issues"
   - Name: `zidni-mobile`

2. **Laravel Backend**
   - Create another project
   - Platform: Laravel
   - Name: `zidni-backend`

3. **Python Companion**
   - Create another project
   - Platform: Flask
   - Name: `zidni-companion`

### Step 3: Get Your DSN Keys

For each project, get the DSN (Data Source Name):
- Go to **Settings** → **Projects** → [Project Name] → **Client Keys (DSN)**
- Copy the DSN URL (format: `https://[key]@[org].ingest.sentry.io/[project-id]`)

You should now have 3 DSN URLs:
- `FLUTTER_SENTRY_DSN` for mobile app
- `LARAVEL_SENTRY_DSN` for backend
- `PYTHON_SENTRY_DSN` for companion server

---

## Configuration

### Flutter Mobile App

#### Option 1: Build-time Configuration (Recommended)

Build with Sentry DSN passed as compile-time constant:

```bash
# Debug build (Sentry disabled)
flutter build apk

# Production build with Sentry enabled
flutter build apk --release \
  --dart-define=SENTRY_DSN="https://YOUR_FLUTTER_DSN_HERE"

# iOS production build
flutter build ios --release \
  --dart-define=SENTRY_DSN="https://YOUR_FLUTTER_DSN_HERE"
```

#### Option 2: Environment File (Alternative)

Create `zidni_mobile/.env`:

```bash
SENTRY_DSN=https://YOUR_FLUTTER_DSN_HERE
```

Then load with `flutter_dotenv` package (requires additional setup).

#### Verify Flutter Integration

The app is already configured! Check `zidni_mobile/lib/main.dart`:

```dart
await SentryFlutter.init(
  (options) {
    options.dsn = Env.sentryDsn;  // Reads from --dart-define
    options.environment = Env.environment;
    // ... more config
  },
  appRunner: () => runApp(const ZidniApp()),
);
```

---

### Laravel Backend

#### Step 1: Install Sentry Package

```bash
composer install  # Already added sentry/sentry-laravel to composer.json
```

#### Step 2: Publish Sentry Config

```bash
php artisan sentry:publish --dsn=YOUR_LARAVEL_DSN_HERE
```

This creates `config/sentry.php` with your DSN.

#### Step 3: Update .env.production

```bash
SENTRY_LARAVEL_DSN=https://YOUR_LARAVEL_DSN_HERE
```

#### Step 4: Test Laravel Integration

```bash
# Test Sentry by triggering a test exception
php artisan sentry:test

# You should see:
# [Sentry] DSN discovered!
# [Sentry] Generating test event...
# [Sentry] Sending test event with ID: xxxxxxxx
```

Check Sentry dashboard → Issues to see the test error.

---

### Python Companion Server

#### Step 1: Install Dependencies

```bash
cd local_companion
pip install -r requirements.txt  # Already includes sentry-sdk[flask]
```

#### Step 2: Set Environment Variable

```bash
export SENTRY_DSN="https://YOUR_PYTHON_DSN_HERE"
export COMPANION_ENV="production"
export VERSION="1.0.0"
```

Or create `.env` file:

```bash
# local_companion/.env
SENTRY_DSN=https://YOUR_PYTHON_DSN_HERE
COMPANION_ENV=production
VERSION=1.0.0
```

Load with:

```bash
pip install python-dotenv  # Already in requirements.txt
```

Then in `server.py` (already configured):

```python
from dotenv import load_dotenv
load_dotenv()

sentry_sdk.init(
    dsn=os.environ.get('SENTRY_DSN', ''),
    environment=os.environ.get('COMPANION_ENV', 'development'),
    # ... more config
)
```

#### Step 3: Test Python Integration

```python
# Add test endpoint temporarily
@app.route('/sentry-test')
def sentry_test():
    division_by_zero = 1 / 0  # Trigger error
```

Visit `https://192.168.4.1:8787/sentry-test` and check Sentry dashboard.

---

## Production Deployment

### Deploy with Environment Variables

#### Docker / Kubernetes

```yaml
# docker-compose.yml
services:
  backend:
    environment:
      - SENTRY_LARAVEL_DSN=${SENTRY_LARAVEL_DSN}

  companion:
    environment:
      - SENTRY_DSN=${SENTRY_PYTHON_DSN}
      - COMPANION_ENV=production
```

#### Systemd (for Python companion)

```ini
# /etc/systemd/system/zidni-companion.service
[Service]
Environment="SENTRY_DSN=https://YOUR_PYTHON_DSN_HERE"
Environment="COMPANION_ENV=production"
ExecStart=/opt/zidni-companion/venv/bin/gunicorn ...
```

#### Flutter App Store Builds

```bash
# Android APK
flutter build apk --release \
  --dart-define=SENTRY_DSN="$FLUTTER_SENTRY_DSN"

# iOS App Store
flutter build ipa --release \
  --dart-define=SENTRY_DSN="$FLUTTER_SENTRY_DSN"
```

---

## Verify Everything Works

### 1. Check Sentry Dashboard

Go to Sentry.io → Issues. You should see:
- Real-time errors from all 3 components
- Performance traces
- Release versions

### 2. Test Each Component

#### Flutter App
```dart
// Add to a test button
ElevatedButton(
  onPressed: () {
    throw Exception('Test Sentry from Flutter');
  },
  child: Text('Test Sentry'),
)
```

#### Laravel
```bash
php artisan sentry:test
```

#### Python
```bash
curl https://192.168.4.1:8787/sentry-test
```

### 3. Verify Alerts

Go to **Alerts** → **Create Alert Rule**:
- Alert on: "New issue created"
- Notify: Your email
- Projects: All 3 projects

---

## Error Tracking Best Practices

### 1. Add User Context

#### Flutter
```dart
import 'package:sentry_flutter/sentry_flutter.dart';

// After user logs in
Sentry.configureScope((scope) {
  scope.setUser(SentryUser(
    id: user.uid,
    username: user.displayName,
    // email redacted for privacy (see main.dart beforeSend)
  ));
});
```

#### Laravel
```php
use Sentry\State\Scope;

// In middleware or controller
Sentry\configureScope(function (Scope $scope): void {
    $scope->setUser([
        'id' => auth()->id(),
        'username' => auth()->user()->name,
    ]);
});
```

#### Python
```python
from sentry_sdk import configure_scope

@app.before_request
def set_user_context():
    with configure_scope() as scope:
        scope.set_user({"id": "user123", "username": "john"})
```

---

### 2. Add Breadcrumbs (Navigation Tracking)

Breadcrumbs help you understand user actions leading up to an error.

#### Flutter (Already Configured)
```dart
// Automatic via SentryNavigatorObserver in MaterialApp
navigatorObservers: [SentryNavigatorObserver()],
```

#### Laravel
```php
use Sentry\Breadcrumb;

Breadcrumb::record([
    'message' => 'User viewed product',
    'category' => 'navigation',
    'level' => 'info',
]);
```

#### Python
```python
from sentry_sdk import add_breadcrumb

@app.route('/stt', methods=['POST'])
def speech_to_text():
    add_breadcrumb(
        category='stt',
        message='Audio file uploaded',
        level='info',
    )
    # Process audio...
```

---

### 3. Capture Custom Events

#### Flutter
```dart
import 'package:sentry_flutter/sentry_flutter.dart';

// Capture custom message
Sentry.captureMessage(
  'User completed onboarding',
  level: SentryLevel.info,
);

// Capture exception with context
try {
  await riskyOperation();
} catch (error, stackTrace) {
  await Sentry.captureException(
    error,
    stackTrace: stackTrace,
    hint: Hint.withMap({'operation': 'risky_operation'}),
  );
}
```

#### Laravel
```php
use Sentry\Laravel\Facades\Sentry;

// Capture message
Sentry::captureMessage('Payment processed', [
    'level' => 'info',
    'tags' => ['payment_method' => 'stripe'],
]);

// Capture exception
try {
    processPayment();
} catch (\Exception $e) {
    Sentry::captureException($e);
    throw $e;
}
```

#### Python
```python
from sentry_sdk import capture_message, capture_exception

# Capture custom message
capture_message('STT request processed', level='info')

# Capture exception
try:
    transcribe_audio()
except Exception as e:
    capture_exception(e)
    raise
```

---

### 4. Performance Monitoring

#### Flutter (Already Enabled)
```dart
// Automatic transaction tracking via tracesSampleRate
// Manual transaction:
final transaction = Sentry.startTransaction('loadUserData', 'task');

try {
  final span = transaction.startChild('fetchFromFirestore');
  await firestoreService.getDealFolders();
  span.finish(status: SpanStatus.ok());
} finally {
  transaction.finish();
}
```

#### Laravel
```php
$transaction = \Sentry\startTransaction(
    \Sentry\TransactionContext::make()
        ->setName('ProcessOrder')
        ->setOp('task')
);

\Sentry\SentrySdk::getCurrentHub()->setSpan($transaction);

// Your code here
processOrder($order);

$transaction->finish();
```

---

### 5. Filter Sensitive Data

#### Flutter (Already Configured)
```dart
// In main.dart - emails already redacted
options.beforeSend = (event, {hint}) {
  if (event.user?.email != null) {
    event = event.copyWith(
      user: event.user?.copyWith(email: '[REDACTED]'),
    );
  }
  return event;
};
```

#### Laravel
```php
// config/sentry.php
'before_send' => function (\Sentry\Event $event): ?\Sentry\Event {
    // Remove sensitive headers
    if ($request = $event->getRequest()) {
        $headers = $request->getHeaders();
        unset($headers['Authorization']);
        $request->setHeaders($headers);
    }
    return $event;
},
```

#### Python (Already Configured)
```python
# server.py - Only send if DSN is set
before_send=lambda event, hint: event if os.environ.get('SENTRY_DSN') else None,
```

---

## Monitoring Dashboard

### Key Metrics to Watch

1. **Error Rate** - Track increases in errors
2. **Response Time** - Monitor performance degradation
3. **Crash-Free Sessions** - Percentage of sessions without crashes
4. **Most Common Errors** - Fix highest-impact issues first

### Set Up Alerts

Go to **Alerts** → **Create Alert**:

1. **Critical Error Alert**
   - Condition: Any new issue created
   - Severity: Critical
   - Notify: Email, Slack

2. **Performance Degradation**
   - Condition: Transaction duration > 3 seconds
   - Notify: Email

3. **High Error Rate**
   - Condition: Error count > 50 in 1 hour
   - Notify: Email, PagerDuty (if using)

---

## Releases & Source Maps

### Track Releases

#### Flutter
```bash
# Build with release version
flutter build apk --release \
  --dart-define=SENTRY_DSN="$SENTRY_DSN" \
  --build-name=1.0.0 \
  --build-number=1

# Upload debug symbols (for better stack traces)
sentry-cli releases new zidni-mobile@1.0.0
sentry-cli releases files zidni-mobile@1.0.0 upload-sourcemaps build/app/outputs/flutter-apk/
```

#### Laravel
```bash
# In deployment script
export SENTRY_RELEASE=zidni-backend@1.0.0
php artisan config:cache
```

#### Python
```bash
export SENTRY_RELEASE=zidni-companion@1.0.0
gunicorn server:app
```

---

## Troubleshooting

### Sentry Not Receiving Events

1. **Check DSN is set correctly**
   ```bash
   # Flutter
   flutter build apk --release --dart-define=SENTRY_DSN="your-dsn" --verbose

   # Laravel
   php artisan tinker
   >>> config('sentry.dsn')

   # Python
   python -c "import os; print(os.environ.get('SENTRY_DSN'))"
   ```

2. **Verify internet connectivity** from production server

3. **Check firewall rules** - Sentry uses HTTPS (port 443)

4. **Look for initialization errors** in logs

### Too Many Events (Quota Exceeded)

1. **Reduce sample rate** in production:
   ```dart
   // Flutter
   options.tracesSampleRate = 0.1;  // Sample 10% of transactions
   ```

2. **Filter noisy errors**:
   ```python
   # Python
   def before_send(event, hint):
       if 'ignorable_error' in str(hint.get('exc_info', '')):
           return None
       return event
   ```

3. **Upgrade Sentry plan** if needed

---

## Cost Optimization

### Free Tier Limits
- 5,000 errors/month
- 10,000 performance units/month
- 1 GB attachments

### Stay Within Free Tier

1. **Sample performance traces** (already configured at 20%)
2. **Filter debug errors** in development
3. **Use error grouping** to avoid duplicate issues
4. **Set rate limits** per error type

### When to Upgrade

- More than 5K errors/month → **$26/month** (Team plan)
- Need more performance monitoring → **$29/month** (Performance)
- Enterprise features (SSO, SLA) → Contact sales

---

## Security Considerations

### 1. Protect Sentry DSN

✅ **DO:**
- Use environment variables
- Never commit DSN to git
- Rotate DSN if exposed

❌ **DON'T:**
- Hardcode DSN in source code
- Share DSN publicly
- Use same DSN for dev and prod

### 2. Redact Sensitive Data

Already configured:
- Flutter: Email addresses redacted
- Laravel: Authorization headers removed
- Python: Only send if DSN is set (prevents dev leaks)

### 3. Access Control

- Limit Sentry dashboard access to team members only
- Use Sentry Teams for role-based access
- Enable 2FA for Sentry account

---

## Next Steps

1. ✅ Sign up for Sentry (https://sentry.io/signup/)
2. ✅ Create 3 projects (Flutter, Laravel, Python)
3. ✅ Get 3 DSN keys
4. ✅ Configure environment variables
5. ✅ Test each component
6. ✅ Set up alerts
7. ✅ Monitor dashboard daily

---

## Support

- Sentry Documentation: https://docs.sentry.io/
- Flutter Integration: https://docs.sentry.io/platforms/flutter/
- Laravel Integration: https://docs.sentry.io/platforms/php/guides/laravel/
- Python/Flask Integration: https://docs.sentry.io/platforms/python/guides/flask/

**Questions?** Check Sentry community: https://forum.sentry.io/
