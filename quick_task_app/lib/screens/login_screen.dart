import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../services/backend_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.blue, // Change app bar color
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildUsernameTextField(),
              SizedBox(height: 20.0),
              _buildPasswordTextField(),
              SizedBox(height: 20.0),
              _buildLoginButton(),
              SizedBox(height: 10.0),
              if (_errorMessage != null) _buildErrorMessage(),
              SizedBox(height: 20.0),
              _buildSignUpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameTextField() {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: 'Username',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
      ),
      obscureText: true,
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      child: Text('Login'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Change button color
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        _errorMessage!,
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return TextButton(
      onPressed: _navigateToSignUpScreen,
      child: Text('Don\'t have an account? Sign up'),
    );
  }

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    // Perform basic validation
    if (username.isEmpty || password.isEmpty) {
      _showErrorMessage("Username and password are required.");
      return;
    }

    // Make API call to authenticate user
    try {
      final String? token = await BackendService.login(username, password);
      if (token != null) {
        // Authentication successful, navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorMessage("Invalid username or password.");
      }
    } catch (error) {
      _showErrorMessage("An error occurred. Please try again later.");
    }
  }

  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _navigateToSignUpScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  }
}
