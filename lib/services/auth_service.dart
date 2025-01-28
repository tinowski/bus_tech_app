class AuthService {
  // Mock user data
  final Map<String, String> _users = {
    'tino': 'password1',
    'luigi': 'password2',
  };

  bool login(String username, String password) {
    return _users[username] == password;
  }

  // In a real app, you might have a logout or token-based approach.
  void logout() {
    // Clear session, tokens, etc.
  }
}
