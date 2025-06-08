import 'package:demo_vps/MobileLayouts/customwidgets/primarybuttonwidget.dart';
import 'package:flutter/material.dart';

class ChooseUser extends StatefulWidget {
  const ChooseUser({super.key});

  @override
  State<ChooseUser> createState() => _ChooseUserState();
}

class _ChooseUserState extends State<ChooseUser> {
  String selectedRole = "Teacher"; // Default selected value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFF8C5FF5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Choose User",
              style: TextStyle(
                color: Color.fromARGB(193, 255, 255, 255),
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Material(
              elevation: 40.0,
              shadowColor: Color.fromARGB(255, 78, 42, 163),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: EdgeInsets.only(top: 40, left: 20, right: 20),
                height: 290,
                width: 250,
                decoration: BoxDecoration(
                  color: Color.fromARGB(158, 187, 183, 183),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Radio<String>(
                          value: "Teacher",
                          groupValue: selectedRole,
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value!;
                            });
                          },
                          activeColor: Color(0xFF8C5FF5),
                        ),
                        Text(
                          "Teacher",
                          style: TextStyle(
                            color: Color(0xFF8C5FF5),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: "Student",
                          groupValue: selectedRole,
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value!;
                            });
                          },
                          activeColor: Color(0xFF8C5FF5),
                        ),
                        Text(
                          "Student",
                          style: TextStyle(
                            color: Color(0xFF8C5FF5),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: "Admin",
                          groupValue: selectedRole,
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value!;
                            });
                          },
                          activeColor: Color(0xFF8C5FF5),
                        ),
                        Text(
                          "Admin",
                          style: TextStyle(
                            color: Color(0xFF8C5FF5),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Primarybuttonwidget(run: () => {}, input: "Continue"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
