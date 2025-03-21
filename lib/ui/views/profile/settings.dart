import 'package:easyph/ui/components/background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../components/submit_button.dart';
import '../../components/text_field_widget.dart';

class Settings extends StatefulWidget {
  @override
  _Settings createState() => _Settings();
}

class _Settings extends State<Settings> {
  bool _isDarkTheme = false;
  bool isSalesNotificationEnabled = true;
  bool isNewArrivalsNotificationEnabled = false;
  bool isDeliveryStatusNotificationEnabled = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text(''),
          actions: [
            IconButton(
              icon: Icon(Icons.search_outlined),
              onPressed: () {
                // Handle notification settings here
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(6.0),
          child: ListView(
            children: [
              Text(
                "Settings",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              verticalSpaceMedium,
              Text(
                "Personal Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              verticalSpaceMedium,
              _buildInfoContainer("Name", "Anesa Bala"),
              _buildInfoContainer("Date of Birth", "01 Jan 1990"),
              _buildInfoContainer("Password", "••••••••", hasIcon: true),

              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dark Theme', style: TextStyle(fontSize: 18)),
                    Switch(
                      value: _isDarkTheme,
                      onChanged: (value) {
                        setState(() {
                          _isDarkTheme = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    Text('Notifications', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: Text('New arrivals'),
                      value: isNewArrivalsNotificationEnabled,
                      activeColor: Colors.green,
                      onChanged: (val) {
                        setState(() {
                          isNewArrivalsNotificationEnabled = val;
                        });
                      },
                    ),
                    Container(

                      child: SwitchListTile(
                        title: Text('Delivery status changes'),
                        value: isDeliveryStatusNotificationEnabled,
                        activeColor: Colors.green,
                        onChanged: (val) {
                          setState(() {
                            isDeliveryStatusNotificationEnabled = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoContainer(String label, String value, {bool hasIcon = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 16)),
              if (hasIcon)

                GestureDetector(
                  onTap: () => _showBottomSheet(context),
                  child: Text(
                      'Change',
                      style: TextStyle(color: kcPrimaryColor),
                  ),
                ),

            ],
          ),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    final newPassword = TextEditingController();
    final oldPassword = TextEditingController();
    final repeatPassword = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Change Password', style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              TextFieldWidget(
                hint: "Enter Old Password",
                controller: oldPassword,
              ),
              verticalSpaceMedium,
              TextFieldWidget(
                hint: "New Password",
                controller: newPassword,
              ),
              verticalSpaceMedium,
              TextFieldWidget(
                hint: "Repeat new Password",
                controller: repeatPassword,
              ),
              verticalSpaceMedium,
              SubmitButton(
                isLoading: false,
                label: "Save Password",
                submit: () {},
                boldText: true,
                color: kcPrimaryColor,
              ),
            ],
          ),
        );
      },
    );
  }
}
