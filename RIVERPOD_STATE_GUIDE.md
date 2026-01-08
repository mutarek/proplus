# Riverpod Login State Management Guide

## Overview
Your login screen now uses Riverpod's state management for reactive UI updates and proper async handling.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   LoginScreen (UI)                       │
│  - Displays username/password fields                     │
│  - Shows loading, success, or error states              │
└────────────────────────┬────────────────────────────────┘
                         │
                         │ ref.watch() - Reactive state
                         │
┌────────────────────────▼────────────────────────────────┐
│         loginProvider (FutureProvider.family)            │
│  - Takes UserRequestBody as parameter                    │
│  - Manages async login state automatically              │
│  - Provides: data, loading, error states                │
└────────────────────────┬────────────────────────────────┘
                         │
                         │ delegates to
                         │
┌────────────────────────▼────────────────────────────────┐
│      AuthRepository.loginUser()                          │
│  - Makes API call via DioClient                          │
│  - Returns UserResponse                                  │
└─────────────────────────────────────────────────────────┘
```

## State Management Flow

### 1. **Initial State** (Before Login)
```dart
_lastRequestBody = null;
// loginState = null
// Button is enabled, text fields are enabled
```

### 2. **User Clicks Login**
```dart
_handleLogin() {
  // 1. Validate inputs
  // 2. Create UserRequestBody
  // 3. setState(() { _lastRequestBody = userRequestBody; })
  // 4. ref.refresh(loginProvider(userRequestBody))
}
```

### 3. **Riverpod Provider Activation**
```dart
ref.watch(loginProvider(_lastRequestBody!))
```
- This triggers the FutureProvider
- Widget rebuilds automatically when state changes

### 4. **Three Possible States**

#### **LOADING State**
```dart
.when(
  loading: () => Column(
    children: [
      ElevatedButton(onPressed: null, ...), // Disabled
      CircularProgressIndicator(),
      Text('Logging in...'),
    ],
  ),
)
```
- Button is disabled (null onPressed)
- Loading indicator shows
- Text fields are disabled

#### **SUCCESS State** (data)
```dart
.when(
  data: (userData) => Column(
    children: [
      ElevatedButton(onPressed: _handleLogin, ...),
      Container(
        child: Column(
          children: [
            Text('✓ Login Successful!'),
            Text('Welcome, ${userData.username}!'),
          ],
        ),
      ),
    ],
  ),
)
```
- Shows user data
- Can login again
- Text fields remain disabled until manual clear

#### **ERROR State**
```dart
.when(
  error: (error, stackTrace) => Column(
    children: [
      ElevatedButton(onPressed: _handleLogin, ...),
      Container(
        child: Column(
          children: [
            Text('✗ Login Failed'),
            Text(error.toString()),
          ],
        ),
      ),
    ],
  ),
)
```
- Shows error message
- Button enabled to retry
- Can modify text fields and retry

### 5. **No Login Attempt Yet** (null state)
```dart
loginState?.when(...) ?? ElevatedButton(
  onPressed: _handleLogin,
  child: Text('Login'),
)
```
- Shows default login button
- Text fields are enabled
- Ready for user input

## Key Riverpod Concepts Used

### 1. **FutureProvider.family**
```dart
final loginProvider = FutureProvider.family<UserResponse, UserRequestBody>(
  (ref, userRequestBody) async {
    final authRepository = ref.watch(authRepositoryProvider);
    return authRepository.loginUser(userRequestBody: userRequestBody);
  },
);
```
- `FutureProvider` - Handles async operations
- `.family` - Takes a parameter (UserRequestBody)
- Automatically manages: loading, data, error states

### 2. **ref.watch()** - Reactive Updates
```dart
final loginState = _lastRequestBody != null 
    ? ref.watch(loginProvider(_lastRequestBody!))
    : null;
```
- Watches the provider
- Widget rebuilds when state changes
- Used in build method for reactive UI

### 3. **ref.refresh()** - Trigger the Provider
```dart
ref.refresh(loginProvider(userRequestBody));
```
- Triggers the provider with parameters
- Executes the async function
- Updates the state

## AsyncValue Pattern

Riverpod uses `AsyncValue<T>` to represent async states:

```dart
AsyncValue<UserResponse> loginState;

// Check state
loginState.isLoading;   // bool
loginState.hasError;    // bool
loginState.hasValue;    // bool

// Pattern matching with .when()
loginState.when(
  data: (value) { /* T */ },
  loading: () { /* shows loading */ },
  error: (error, stack) { /* error handling */ },
);

// Safe extraction
loginState.maybeWhen(
  data: (value) => Text(value.username),
  orElse: () => Text('Not logged in'),
);
```

## Disabled State Management

Text fields are disabled during login:
```dart
TextField(
  enabled: loginState?.isLoading != true,  // Disable if loading
  ...
)
```

This prevents users from modifying credentials while login is in progress.

## Error Recovery

On error, the user can:
1. See the error message
2. Click "Login" button again
3. Modify username/password
4. Retry the login

## Benefits of This Approach

✅ **Automatic State Management** - No manual setState() for loading/error  
✅ **Reactive UI** - Widget automatically rebuilds on state changes  
✅ **Type Safe** - Generic types ensure type safety  
✅ **Performance** - Only watches specific provider instance  
✅ **Testable** - Providers can be easily mocked and tested  
✅ **Clean Code** - Separates UI from business logic  

## Testing the Login

```dart
// Test credentials from dummyjson.com
username: "emilys"
password: "emilyspassword"
```

This will show:
- Loading spinner while request is sent
- Success message with user data if credentials are correct
- Error message if credentials are invalid

## Advanced: Handling Success Navigation

To navigate after successful login:

```dart
@override
void initState() {
  super.initState();
  _usernameController = TextEditingController();
  _passwordController = TextEditingController();
  
  // Add listener for navigation
  ref.listen(loginProvider(UserRequestBody(
    username: '',
    password: '',
    expiresInMins: 60,
  )), (previous, next) {
    next.whenData((userData) {
      // Navigate to home screen
      Navigator.of(context).pushReplacementNamed('/home');
    });
  });
}
```

Or use `ref.watch()` in build to handle navigation:

```dart
@override
Widget build(BuildContext context) {
  if (_lastRequestBody != null) {
    ref.listen(loginProvider(_lastRequestBody!), (previous, next) {
      next.whenData((userData) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    });
  }
  // ... rest of build
}
```

