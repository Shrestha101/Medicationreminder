import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:project/models/tracker.dart';
import 'package:project/screens/add_alarm/select_tracker_meds_screen.dart';
import 'package:project/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:project/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/screens/auth/login_screen.dart';
import 'package:project/screens/home/profile_screen.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart'; //For creating the SMTP Server
import 'package:project/utils/globals.dart' as globals;

import 'alarm_info_screen.dart';

class TrackerScreen extends StatefulWidget {
  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  @override
  Widget build(BuildContext context) {
    final auth.User firebaseUser = Provider.of<auth.User>(context);
    globals.userEmail = firebaseUser.email.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trackers'),
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .collection('trackers')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final List<DocumentSnapshot> docs = snapshot.data.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text('No tracker'),
            );
          }

          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: docs.length,
            itemBuilder: (BuildContext context, int index) {
              final DocumentSnapshot doc = docs[index];
              Tracker tracker = Tracker.fromDocument(doc);
              String freqTitle = tracker.med_names.join(',');
              Widget timeWidget = Container();
              DateTime trackerTime = tracker.tracker_time;
              final FormatterTime = DateFormat.jm();
              final FormatterDate = DateFormat.yMMMMd('en_US');

              String startTimeHour = FormatterTime.format(trackerTime);
              String endTimeHour = ' ';
              String startTimeDate = FormatterDate.format(trackerTime);
              String endTimeDate = ' ';



              timeWidget = Column(children: [
                Text(startTimeHour,
                    style: const TextStyle(
                        fontSize: 23.0, fontWeight: FontWeight.bold)),
                Text(startTimeDate, style: const TextStyle(fontSize: 16.0)),
              ]);


              return Card(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        title: Text(freqTitle),
                        subtitle: Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: timeWidget),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteTrackerDialog(context, tracker, firebaseUser.uid);
                          },
                        ),
                        /*onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AlarmInfo(tracker: tracker)));
                        },*/
                      )));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      SelectTrackerMedsScreen(uid: firebaseUser.uid)));
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_alarm),
      ),
    );
  }

// delete tracker function with confirmation dialog
  void deleteTrackerDialog(BuildContext context, Tracker tracker, String uid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete tracker?'),
          content: const Text('Are you sure you want to delete this tracker?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                Database.deleteTracker(uid, tracker.id);
              },
            ),
          ],
        );
      },
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

