import 'package:easyph/ui/views/profile/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:path/path.dart' as path;
import '../../../app/app.locator.dart';
import '../../../core/data/models/profile.dart';
import '../../../core/data/repositories/repository.dart';
import '../../../core/network/api_response.dart';
import '../../../state.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../components/profile_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ProfileViewModel viewModel;
  const ProfileScreen({
    Key? key, required this.viewModel,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  bool loading = false;
  final repo = locator<Repository>();
  String shippingId = "";
  bool makingDefault = false;
  bool isUpdating = false;
  final snackBar = locator<SnackbarService>();

  void getProfile(ProfileViewModel viewModel) async {
    try {
      ApiResponse res = await repo.getProfile();
      if (res.statusCode == 200) {
        profile.value =
            Profile.fromJson(Map<String, dynamic>.from(res.data["user"]));

        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ProfileScreen(viewModel: viewModel,),
        ));
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  // New method to show the edit/add phone number dialog
  void _showEditPhoneDialog(BuildContext context) {
    final TextEditingController phoneController = TextEditingController(text: profile.value.phoneNumber);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Phone Number'),
          content: TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                String newPhone = phoneController.text.trim();
                if (newPhone.isNotEmpty) {
                  // Optionally show a loading indicator here if needed.
                  ApiResponse response = await repo.updateProfile({
                    'phoneNumber': newPhone,
                  });
                  if (response.statusCode == 200) {
                    // Update the profile's phone number and persist it locally.
                    setState(() {
                      profile.value.phoneNumber = newPhone;
                    });
                    // Optionally show a success message, e.g. via Snackbar:
                    locator<SnackbarService>().showSnackbar(
                      message: "Phone number updated successfully",
                      duration: Duration(seconds: 2),
                    );
                  } else {
                    // Handle error response
                    locator<SnackbarService>().showSnackbar(
                      message: response.data["message"] ?? "Failed to update phone number",
                      duration: Duration(seconds: 2),
                    );
                  }
                }
                Navigator.of(context).pop();
              },
            ),

          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
      uiMode.value == AppUiModes.dark ? kcDarkGreyColor : kcWhiteColor,
      appBar: AppBar(
        toolbarHeight: 100.0,
        title: const Text('Profile Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: <Widget>[
          ProfilePicturePicker(
            selectedFile: widget.viewModel.selectedFile,
            onImagePicked: widget.viewModel.updateProfileImage,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0), // Add padding inside the card
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ListTile(
                                title: const Text(
                                  'Full Name',
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                                subtitle: Text(
                                  "${profile.value.firstName} ${profile.value.lastName}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: uiMode.value == AppUiModes.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              // This will give bounded constraints to the ListTile.
                              child: ListTile(
                                title: const Text(
                                  'Email Address',
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                                subtitle: Text(
                                  '${profile.value.email}',
                                  style: TextStyle(
                                      color: uiMode.value == AppUiModes.dark
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: const Text(
                                  'Phone Number',
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                                subtitle: Text(
                                  "${profile.value.phoneNumber}",
                                  style: TextStyle(
                                      color: uiMode.value == AppUiModes.dark
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                // Added edit button to allow editing/adding phone number
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showEditPhoneDialog(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // ... Other widgets can go here
                      ],
                    ),
                  ),
                  horizontalSpaceLarge,
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Optional padding for spacing
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns items properly
                            children: [
                              // Text(
                              //   "Create Afritag",
                              //   style: TextStyle(
                              //     color: uiMode.value == AppUiModes.dark
                              //         ? Colors.white
                              //         : Colors.black,
                              //     fontSize: 12,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                            ],
                          ),
                          verticalSpaceSmall,
                          Text(
                            "Create a unique username to transfer shopping credits with family to purchase or donate.",
                            style: TextStyle(
                              color: uiMode.value == AppUiModes.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          verticalSpaceSmall,
                          // Row(... commented out section ...),
                        ],
                      ),
                    ),
                  ),
                  horizontalSpaceMedium,
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Column(
                      children: [],
                    ),
                  ),
                  horizontalSpaceLarge,
                ]),
          ),
        ],
      ),
    );
  }
}

class AddressTile extends StatelessWidget {
  final String address;
  final String phone;

  const AddressTile({super.key, required this.address, required this.phone});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Address'),
      subtitle: Text(address),
      trailing: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.edit),
          SizedBox(height: 4),
          Icon(Icons.delete),
        ],
      ),
    );
  }
}