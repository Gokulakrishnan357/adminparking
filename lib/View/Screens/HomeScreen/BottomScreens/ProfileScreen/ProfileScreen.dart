import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../Components/Utills/TextformFiled.dart';
import '../../../../../Controller/UserController.dart';
import '../../../../../Model/ProfileModel.dart';
import '../../../../../Model/UserModel.dart';
import '../../../../../Service/GraphqlService/Graphql_Service.dart';
import '../../HomeScreen.dart';
import '../../SubScreens/BottomNavBar.dart';
import '../../SubScreens/LogOutScreen.dart';
import '../CompanyScreen/AddCompanyScreen.dart';
import '../LogScreen.dart';
import '../SummaryScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;

  final TextEditingController nameController = TextEditingController(
    text: "CCS",
  );

  final TextEditingController roleController = TextEditingController(
    text: "Admin",
  );

  final TextEditingController locationController = TextEditingController(
    text: "Chennai",
  );

  final _formKey = GlobalKey<FormState>();
  final int _currentIndex = 3;

  XFile? _selectedImage;
  late final UserController userController;
  List<ParkingLot>? parkinglots;
  int? userId;
  bool _hasSubmittedBefore = false;

  Future<void> clearProfileFromPrefs() async {
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('companyProfile_\$userId');
    await prefs.remove('hasSubmittedProfile_\$userId');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final client = GraphQLProvider.of(context).value;
      userController = UserController(GraphQLService(client));
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('userId');
      await loadSavedProfile();
      await loadUserLoginInfo();
      await loadSavedProfile();
    });
  }

  Future<void> loadUserLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('loginData');

    if (storedData != null) {
      final Map<String, dynamic> loginJson = jsonDecode(storedData);
      final loginResponse = LoginResponse.fromJson(loginJson);
      final user = loginResponse.data;

      if (user != null) {
        final String location = user.parkinglots?.isNotEmpty == true
            ? user.parkinglots!.first.location ?? "Chennai"
            : "Chennai";

        setState(() {
          nameController.text = user.fullname ?? "";
          roleController.text = user.isadmin == true ? "Admin" : "User";
          locationController.text = location;
        });
      }
    }
  }

  Future<void> loadSavedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (userId == null) return;
    final storedProfile = prefs.getString('companyProfile_\$userId');
    _hasSubmittedBefore =
        prefs.getBool('hasSubmittedProfile_\$userId') ?? false;
    if (storedProfile != null) {
      final profileData = CompanyProfileData.fromJson(
        jsonDecode(storedProfile),
      );
      if (profileData.companyuserid == userId) {
        setState(() {
          nameController.text = profileData.name ?? "";
          roleController.text = profileData.email ?? "";
          if (profileData.imageUrl != null &&
              profileData.imageUrl!.isNotEmpty) {
            _selectedImage = XFile(profileData.imageUrl!);
          }
        });
      }
    }
  }

  void _onNavItemTapped(int index) {
    if (index == _currentIndex) return;
    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = HomeScreen(userData: userController.userData.value);
        break;
      case 1:
        nextScreen = LogScreen();
        break;
      case 2:
        nextScreen = SummaryScreen();
        break;
      case 3:
        nextScreen = ProfileScreen();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  Future<void> _pickImage() async {
    if (!isEditing) return;
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = XFile(pickedFile.path);
      });
    }
  }

  Future<void> saveProfileToPrefs() async {
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();

    final updatedProfile = CompanyProfileData(
      companyuserid: userId!,
      name: nameController.text.trim(),
      location: locationController.text.trim(),
      imageUrl: _selectedImage?.path,
    );

    await prefs.setString(
      'companyProfile_$userId',
      jsonEncode(updatedProfile.toJson()),
    );

    await prefs.setBool('hasSubmittedProfile_$userId', true);

    setState(() {
      _hasSubmittedBefore = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => HomeScreen(
                                    userData: userController.userData.value,
                                  ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(width: 4),
                      Text(
                        'Settings',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _selectedImage != null
                                ? FileImage(File(_selectedImage!.path))
                                : const AssetImage('assets/Png/UserProfile.png')
                                    as ImageProvider,
                      ),
                      if (isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 20,
                                color: Color(0xFF0C448E),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (!isEditing) ...[
                    buildInfoRow('Name', nameController.text),
                    buildInfoRow('Role', roleController.text),
                    buildInfoRow('Location', locationController.text),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2F6FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () => setState(() => isEditing = true),
                      icon: const Icon(Icons.edit, color: Color(0xFF0C448E)),
                      label: Text(
                        'Edit Profile',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0C448E),
                        ),
                      ),
                    ),
                  ] else ...[
                    buildTextFormField("Name", nameController, labelStyle),
                    buildTextFormField("Role", roleController, labelStyle),
                    buildTextFormField(
                      "Location",
                      locationController,
                      labelStyle,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 250,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C448E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            bool success =
                                _hasSubmittedBefore
                                    ? await userController.updateCompanyProfile(
                                      companyuserId: userId!,
                                      name: nameController.text.trim(),
                                      role: roleController.text.trim(),
                                      imageUrl: _selectedImage?.path,
                                    )
                                    : await userController.createCompanyProfile(
                                      companyuserId: userId!,
                                      name: nameController.text.trim(),
                                      role: roleController.text.trim(),
                                      imageUrl: _selectedImage?.path,
                                    );

                            if (success) {
                              await saveProfileToPrefs();
                              setState(() {
                                isEditing = false;
                                _hasSubmittedBefore = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Profile saved successfully'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to save profile'),
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          'Submit',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),
                  Divider(color: const Color(0xFFE4E4E4)),
                  const SizedBox(height: 24),
                  if (!isEditing)
                    TextButton.icon(
                      onPressed: () => showLogoutDialog(context),
                      icon: const Icon(Icons.logout, color: Color(0xFFD71920)),
                      label: Text(
                        'Logout',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD71920),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        onAddTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddCompanyForm()),
            ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 10, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label :',
              textAlign: TextAlign.right,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextFormField(
    String label,
    TextEditingController controller,
    TextStyle labelStyle,
  ) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 8),
          CustomTextFormField(
            hintText: 'Enter $label',
            controller: controller,
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? '$label is required'
                        : null,
          ),
        ],
      ),
    );
  }
}
