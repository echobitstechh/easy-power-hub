import 'package:easyph/ui/views/profile/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
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
  void _showEditProfileDialog(BuildContext context) {
    final TextEditingController firstNameController = TextEditingController(
      text: profile.value.firstName,
    );

    final TextEditingController lastNameController = TextEditingController(
      text: profile.value.lastName,
    );

    final TextEditingController emailController = TextEditingController(
      text: profile.value.email,
    );

    final TextEditingController phoneController = TextEditingController(
      text: profile.value.phoneNumber,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                ),
              ),
              TextField(
                controller: lastNameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                ),
              ),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
              ),
            ],
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
              onPressed: () {
                String newFirstName = firstNameController.text.trim();
                String newLastName = lastNameController.text.trim();
                String newEmail = emailController.text.trim();
                String newPhone = phoneController.text.trim();

                // Call your ViewModel method with the new values
                widget.viewModel.updateProfileData(
                  firstName: newFirstName,
                  lastName: newLastName,
                  email: newEmail,
                  phoneNumber: newPhone,
                );

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
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showEditProfileDialog(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
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
                                // trailing: IconButton(
                                //   icon: const Icon(Icons.edit),
                                //   onPressed: () => _showEditEmailDialog(context),
                                // ),
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
                                // trailing: IconButton(
                                //   icon: const Icon(Icons.edit),
                                //   onPressed: () => _showEditPhoneDialog(context),
                                // ),
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
                          const Row(
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3.0),
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