import 'package:flutter/material.dart';
import '../services/backend_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers for text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Error message displayed to the user
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.blue, // Change app bar color
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildTextField(_usernameController, 'Username'),
            SizedBox(height: 20.0), // Increased height between fields
            _buildTextField(_passwordController, 'Password', obscureText: true),
            SizedBox(height: 20.0),
            _buildTextField(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
            SizedBox(height: 20.0),
            _buildSignupButton(), // Customized signup button
            SizedBox(height: 10.0),
            if (_errorMessage != null) _buildErrorMessage(),
            SizedBox(height: 16.0),
            _buildLoginButton(), // Customized login button
          ],
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(), // Add border to text fields
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
    );
  }

  // Helper method to build signup button
  Widget _buildSignupButton() {
    return ElevatedButton(
      onPressed: _signup,
      child: Text('Sign Up'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Change button color
      ),
    );
  }

  // Helper method to build login button
  Widget _buildLoginButton() {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text('Already have an account? Log in'),
    );
  }

  // Helper method to build error message
  Widget _buildErrorMessage() {
    return Text(
      _errorMessage!,
      style: TextStyle(color: Colors.red),
    );
  }

  // Method to handle sign up logic
  Future<void> _signup() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String email = _emailController.text.trim();

    // Perform basic validation
    if (username.isEmpty || password.isEmpty || email.isEmpty) {
      setState(() {
        _errorMessage = "All fields are required.";
      });
      return;
    }

    // Make API call to register user
    try {
      bool success = await BackendService.signup(username, password, email);
      if (success) {
        // Registration successful, navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        setState(() {
          _errorMessage = "Failed to create account. Please try again.";
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = "An error occurred. Please try again later.";
      });
    }
  }
}
