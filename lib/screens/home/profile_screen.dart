import 'package:flutter/material.dart';
import 'package:project/screens/auth/login_screen.dart';
import 'package:project/screens/auth/login_screen.dart';
import 'package:project/screens/auth/register_screen.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/utils/theme.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart'; //For creating the SMTP Server
import 'package:project/utils/globals.dart' as globals;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String fName = '';
  late String lName = '';
  late String email = '';
  late String gender = '';
  late String dateOfBirth = '';

  @override
  Widget build(BuildContext context) {
    final auth.User firebaseUser = Provider.of<auth.User>(context);
    print('Email ' + firebaseUser.email.toString());
    globals.userEmail = firebaseUser.email.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.secondary,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            color: Colors.white,
            onPressed: () {
              signOutDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfileScreen()));
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          var userDocument = snapshot.data;
          fName = userDocument!['firstName'];
          lName = userDocument['lastName'];
          email = userDocument['email'];
          gender = userDocument['gender'];
          dateOfBirth = userDocument['dateOfBirth'];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 50.0,
                      backgroundImage: AssetImage('assets/medicine.png'),
                    ),
                  ),
                  // first and last name
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Hello, $fName $lName",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  // email
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Email: $email",
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  // gender
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Gender: $gender",
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  // date of birth
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Date of Birth: $dateOfBirth",
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void signOutDialog(BuildContext context) async {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                AuthService.signOut();

                String username = 'shresthashikha045@gmail.com';//Your Email;
                String password = 'hhpjqycatbvsdogw';//Your Email's password;
                //final auth.User firebaseUser = Provider.of<auth.User>(context);
                final smtpServer = gmail(username, password);
                // Creating the Gmail server

                // Create our email message.
                final message = Message()
                  ..from = Address(username)
                  ..recipients.add(globals.userEmail) //recipent email
                //..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com']) //cc Recipents emails
                //..bccRecipients.add(Address('bccAddress@example.com')) //bcc Recipents emails
                  ..subject = 'Med Reminder: Logged Out Notification ${DateTime.now()}' //subject of the email
                  ..text = 'Dear Consumer,\nYou have successfully logged out from Med Reminder.'; //body of the email

                try {
                  final sendReport = await send(message, smtpServer);
                  print('Message sent: ' + sendReport.toString()); //print if the email is sent
                } on MailerException catch (e) {
                  print('Message not sent. \n'+ e.toString()); //print if the email is not sent
                  // e.toString() will show why the email is not sending
                }

                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              child: const Text("Yes."),
            ),
          ],
        );
      });
}
