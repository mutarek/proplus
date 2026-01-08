# Login Function Architecture Guide

## Overview
The login function is now fully integrated into your Flutter app using Riverpod for state management.

## Architecture Flow

```
LoginScreen (UI)
      ↓
   [TextField] → _handleLogin() method
      ↓
loginProvider (FutureProvider.family)
      ↓
authRepositoryProvider
      ↓
AuthRepository.loginUser()
      ↓
DioClient.post() → API Call
      ↓
UserResponse (parsed response)
```

## Files Created/Modified

### 1. **AuthRepository** (`lib/feature/auth/repository/auth_repository.dart`)
   - The data layer that calls the API
   - **Function**: `loginUser(UserRequestBody userRequestBody)`
   - **Returns**: `Future<UserResponse>`

### 2. **Login Provider** (`lib/feature/auth/provider/login_provider.dart`)
   - Riverpod FutureProvider for login state management
   - **Type**: `FutureProvider.family<UserResponse, UserRequestBody>`
   - **Usage**: Wraps the repository function and handles loading/error states

### 3. **Auth Repository Provider** (`lib/feature/auth/provider/auth_repository_provider.dart`)
   - Provides DioClient and AuthRepository instances
   - Ensures dependency injection

### 4. **LoginScreen** (`lib/feature/auth/login_screen.dart`)
   - UI Layer (ConsumerStatefulWidget)
   - **Where login is called**: `_handleLogin()` method
   - **How**: `ref.refresh(loginProvider(userRequestBody))`

## How to Call the Login Function

### In LoginScreen:
```dart
void _handleLogin() {
  final username = _usernameController.text.trim();
  final password = _passwordController.text.trim();

  // Validation
  if (username.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all fields')),
    );
    return;
  }

  // Create request body
  final userRequestBody = UserRequestBody(
    username: username,
    password: password,
    expiresInMins: 60,
  );

  // Call login function through Riverpod provider
  ref.refresh(loginProvider(userRequestBody));
}
```

## State Management with Riverpod

The `loginProvider` handles three states automatically:

### 1. **Loading State**
- Button shows circular progress indicator
- Button is disabled

### 2. **Success State**
- Response is a `UserResponse` object
- Access via: `loginState.maybeWhen(data: (user) => {...})`

### 3. **Error State**
- Error message is displayed
- Button remains enabled for retry

## Example Usage in Widget

```dart
Consumer(
  builder: (context, ref, child) {
    final loginState = ref.watch(loginProvider(userRequestBody));
    
    return loginState.when(
      data: (userResponse) => Text('Welcome ${userResponse.username}!'),
      loading: () => CircularProgressIndicator(),
      error: (error, _) => Text('Login failed: $error'),
    );
  },
)
```

## Data Flow Summary

1. **UI Layer**: LoginScreen accepts username & password input
2. **State Management**: FutureProvider.family manages async state
3. **Dependency Injection**: Providers inject DioClient and AuthRepository
4. **Data Layer**: AuthRepository sends POST request to `/auth/login`
5. **Network Layer**: DioClient handles HTTP communication
6. **Response**: UserResponse model parses the JSON response

## API Endpoint
- **URL**: `https://dummyjson.com/auth/login`
- **Method**: POST
- **Request Body**: 
  ```json
  {
    "username": "string",
    "password": "string",
    "expiresInMins": 60
  }
  ```
- **Response**: UserResponse with user details and tokens

## Next Steps

1. **Handle Success**: Navigate to home screen on successful login
2. **Store Tokens**: Save `accessToken` and `refreshToken` securely
3. **Add Error Handling**: Show specific error messages for different failure scenarios
4. **Add Validation**: Add email/username format validation
5. **Implement Remember Me**: Add checkbox to save credentials securely

