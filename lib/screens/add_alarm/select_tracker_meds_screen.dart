import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project/models/med_options.dart';
import 'package:project/models/medicine.dart';
import 'package:project/models/tracker.dart';
import 'package:project/screens/add_alarm/enter_dosages_screent.dart';
import 'package:project/screens/add_medicine/search_screen.dart';
import 'package:project/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:provider/provider.dart';
import 'package:project/screens/home/track_med_screen.dart';
import 'package:project/utils/theme.dart';
import 'package:project/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/screens/auth/login_screen.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart'; //For creating the SMTP Server
import 'package:project/utils/globals.dart' as globals;

class SelectTrackerMedsScreen extends StatefulWidget {
  const SelectTrackerMedsScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<SelectTrackerMedsScreen> createState() => _SelectTrackerMedsScreenState();

  final String uid;
}

class _SelectTrackerMedsScreenState extends State<SelectTrackerMedsScreen> {
  List<Medicine> _selected_meds = [];
  List<Medicine> _medicines = [];
  bool _emptyList = false;
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _is_repeating = false;
  late DateTime startDate;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    startDate = DateTime.now();
    getMedicines();
  }

  void getMedicines() async {
    _medicines = await Database.getMedicines(widget.uid).then((value) {
      if (value.isEmpty) {
        setState(() {
          _emptyList = true;
        });
      } else {
        setState(() {
          _emptyList = false;
        });
      }
      setState(() {
        _isLoading = false;
      });
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth.User firebaseUser = Provider.of<auth.User>(context);
    globals.userEmail = firebaseUser.email.toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tracker"),
        backgroundColor: AppColors.primary,
      ),
      body: _emptyList
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.medication_liquid,
                    color: AppColors.iconDark,
                    size: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'You have no medicines.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchScreen()));
                    },
                    child: const Text('Add Medicine'),
                  )
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      "Select the medications you would like to add to your alarm",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.primary.withOpacity(0.25),
                    ),
                    child: ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _medicines.length,
                      itemBuilder: (context, int index) {
                        return Container(
                          margin: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/pill-shape/${(_medicines[index].shape).toString().padLeft(2, '0')}.svg",
                                    color:
                                        MedColor.List[_medicines[index].color],
                                    height: 40,
                                  ),
                                  const SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _medicines[index].med_name,
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _medicines[index].med_form_strength,
                                        style: const TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "rxcui: " + _medicines[index].rxcui,
                                        style: const TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                      child: Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      iconSize: 40,
                                      icon: Icon(
                                        _medicines[index].selected
                                            ? Icons.check_box_outlined
                                            : Icons.check_box_outline_blank,
                                        color: _medicines[index].selected
                                            ? AppColors.quaternary
                                            : Colors.grey,
                                      ),
                                      onPressed: () {
                                        if (_medicines[index].selected) {
                                          setState(() {
                                            _medicines[index].selected = false;
                                            _selected_meds
                                                .remove(_medicines[index]);
                                          });
                                        } else {
                                          setState(() {
                                            _medicines[index].selected = true;
                                            _selected_meds
                                                .add(_medicines[index]);
                                          });
                                        }
                                      },
                                    ),
                                  )),
                                ],
                              ),
                              SizedBox(height: 5),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Notes: " + _medicines[index].notes,
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, int index) {
                        return const Divider(
                          thickness: 1.0,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: Visibility(
        visible: _selected_meds.isNotEmpty,
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.secondary,
          onPressed: () {
            if (_isLoading || _isSuccess) {
              return;
            }

            setState(() {
              _isLoading = true;
            });

            Tracker tracker;

            final List<String> med_ids =
            _medicines.map((med) => med.id).toList();
            final List<String> med_names =
            _medicines.map((med) => med.med_name).toList();

            tracker = Tracker(
                id: '',
                name: startDate.toString(),
                med_ids: med_ids,
                med_names: med_names,
                tracker_time: startDate
            );


            Database.addTracker(firebaseUser.uid, tracker).then((value) {

              print('Record Added');
              String username = 'shresthashikha045@gmail.com';//Your Email;
              String password = 'hhpjqycatbvsdogw';//Your Email's password;
              //final auth.User firebaseUser = Provider.of<auth.User>(context);
              final smtpServer = gmail(username, password);
              // Creating the Gmail server
              print('Sending Email at : ' + globals.userEmail);
              // Create our email message.
              final message = Message()
                ..from = Address(username)
                ..recipients.add(globals.userEmail) //recipent email
              //..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com']) //cc Recipents emails
              //..bccRecipients.add(Address('bccAddress@example.com')) //bcc Recipents emails
                ..subject = 'Med Reminder: Medication Taken ${DateTime.now()}' //subject of the email
                ..text = 'Dear Consumer,\nYou have taken medication from Med Reminder.'; //body of the email

              try {
                final sendReport = send(message, smtpServer);
                print('Message sent: ' + sendReport.toString()); //print if the email is sent
              } on MailerException catch (e) {
                print('Message not sent. \n'+ e.toString()); //print if the email is not sent
                // e.toString() will show why the email is not sending
              }
              setState(() async {
                _isLoading = false;
                _isSuccess = true;


                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TrackerScreen()));
              });
            }).catchError((error) {
              setState(() {
                _isLoading = false;
                _isSuccess = false;
                print(error.toString());
                print('Record not added');

              });
            });
          },
          label: const Text('Submit'),
        ),
      ),
    );
  }
}
