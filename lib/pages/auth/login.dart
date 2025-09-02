import 'package:ConnectUs/services/AuthChecker.dart';
import 'package:ConnectUs/services/session_manager.dart';
import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFFA67B00); // Dark Yellow
const kSecondaryColor = Color(0xFFFFC107); // Amber
const kBackgroundColor = Color(0xFF1E1E1E); // Dark Gray-Black
const kAccentColor = Color(0xFFFFCA28); // Light Amber
const kTextColor = Color(0xFFFFD54F); // Warm Yellow

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  bool _isLoading = false;
  bool _rememberMe = false;

  final _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _loadLastLoginEmail();
  }

  void _loadLastLoginEmail() async {
    final lastEmail = await _sessionManager.getLastLoginEmail();
    final rememberMe = await _sessionManager.getRememberMe();
    setState(() {
      _email = lastEmail ?? '';
      _rememberMe = rememberMe;
    });
  }

  final width = WidgetsBinding.instance.window.physicalSize.width / WidgetsBinding.instance.window.devicePixelRatio;

  // Update your existing Login class
void _validateUser() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }
  _formKey.currentState!.save();

  try {
    setState(() => _isLoading = true);
    
    // Use SessionManager for enhanced login with remember me
    final response = await _sessionManager.signInWithEmailAndPassword(
      email: _email.trim(),
      password: _password.trim(),
      rememberMe: _rememberMe,
    );

    if (response.session != null) {
      print('✅ Login successful, session created');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to home page
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  } catch (error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 44.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 60),
                  MaterialButton(
                    onPressed: () {
                      print("Pressed");
                    },
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(
                        "assets/images/profile.png",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: _email,
                    style: TextStyle(color: kTextColor),

                    decoration: InputDecoration(
                      
                      prefixIcon: Icon(Icons.email, color: kAccentColor),
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: kTextColor, width: 2.0),
                      ),
                      filled: true,
                      fillColor: kBackgroundColor,
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      errorStyle: TextStyle(color: Colors.redAccent),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: kAccentColor, width: 2.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                      ),
                      labelStyle: TextStyle(color: kAccentColor, fontSize: 16.0),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value!;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    style: TextStyle(color: kTextColor),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: kAccentColor),
          
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),

                        borderSide: BorderSide(color: kTextColor, width: 2.0),
                      ),
                      
                      filled: true,
                      fillColor: kBackgroundColor,
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      errorStyle: TextStyle(color: Colors.redAccent),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: kAccentColor, width: 2.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                      ),
                      labelStyle: TextStyle(color: kAccentColor, fontSize: 16.0),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _password = value!;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Remember Me Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (bool? value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: kSecondaryColor,
                        checkColor: kBackgroundColor,
                      ),
                      Text(
                        'Remember me',
                        style: TextStyle(
                          color: kTextColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryColor,
                      padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                    ),
                    onPressed: _isLoading ? null : () {
                      _validateUser();
                    },
                    child: _isLoading 
                      ? CircularProgressIndicator(color: kBackgroundColor) 
                      : Text("Login", style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      textStyle: TextStyle(fontSize: (width > 600) ? 18 : 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/getStarted');
                    },
                    child: Text("Don't have an Account? Sign Up", style: TextStyle(color: kTextColor)),
                  ),
                  const SizedBox(height: 20),
                 /*  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/loginPhone');
                    },
                    color: kSecondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    child: Text("Use Phone Number Instead", style: TextStyle(color: kBackgroundColor, fontSize: 16)),
                  )*/
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}