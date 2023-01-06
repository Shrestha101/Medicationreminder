import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/screens/auth/register_screen.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/utils/theme.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart'; //For creating the SMTP Server
import 'package:project/utils/globals.dart' as globals;

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  String? _emailValidator(String? value) {
    if (value!.isEmpty) {
      return 'Email is required';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value!.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      String res = await AuthService.signIn(
          _emailController.text, _passwordController.text);

      globals.userEmail = _emailController.text;
      String username = 'shresthashikha045@gmail.com';//Your Email;
      String password = 'hhpjqycatbvsdogw';//Your Email's password;

      final smtpServer = gmail(username, password);
      // Creating the Gmail server

      // Create our email message.
      final message = Message()
        ..from = Address(username)
        ..recipients.add(globals.userEmail) //recipent email
        //..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com']) //cc Recipents emails
        //..bccRecipients.add(Address('bccAddress@example.com')) //bcc Recipents emails
        ..subject = 'Med Reminder: Login Notification ${DateTime.now()}' //subject of the email
        ..text = 'Dear Consumer,\nYou have successfully logged in to Med Reminder.'; //body of the email

      try {
        final sendReport = await send(message, smtpServer);
        print('Message sent: ' + sendReport.toString()); //print if the email is sent
      } on MailerException catch (e) {
        print('Message not sent. \n'+ e.toString()); //print if the email is not sent
        // e.toString() will show why the email is not sending
      }

      if (res != 'Success') {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res),
          duration: const Duration(seconds: 3),
        ));
      }
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthService.signInWithGoogle(context);
    if (res != 'Success') {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: AppColors.primary,
      ),
      body: (_isLoading)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/medicine.png'),
                        ),
                      ),
                    ),
                    Text(
                      'Med Reminder',
                      style: GoogleFonts.cedarvilleCursive(
                        textStyle: Theme.of(context).textTheme.headline4,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Card(
                        color: AppColors.tertiary,//.withOpacity(0.25),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 24, bottom: 24),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: _emailController,
                                    validator: _emailValidator,
                                    decoration: const InputDecoration(
                                        hintText: 'email'),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    obscureText: _isObscure,
                                    controller: _passwordController,
                                    validator: _passwordValidator,
                                    decoration: InputDecoration(
                                      hintText: 'password',
                                      suffixIcon: IconButton(
                                          icon: Icon(_isObscure
                                              ? Icons.visibility_off
                                              : Icons.visibility),
                                          onPressed: () {
                                            setState(() {
                                              _isObscure = !_isObscure;
                                            });
                                          }),
                                    ),
                                    keyboardType: TextInputType.visiblePassword,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _signIn();
                                    },
                                    child: const Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        primary: AppColors.primary,
                                        onPrimary: Colors.white,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                        ),
                                        minimumSize:
                                            const Size(double.minPositive, 48)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    /*const SizedBox(height: 18),
                    InkWell(
                      child: Container(
                        width: 210,
                        height: 46,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: AppColors.tertiary),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                height: 30.0,
                                width: 30.0,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      image:
                                          AssetImage('assets/google-logo.png'),
                                      fit: BoxFit.cover),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Text(
                                'Sign in with Google',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () async {
                        await _signInWithGoogle(context);
                      },
                    ),*/
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Don\'t have have an account?',
                            style: Theme.of(context).textTheme.subtitle2),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterScreen()));
                          },
                          child: const Text('Create account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
