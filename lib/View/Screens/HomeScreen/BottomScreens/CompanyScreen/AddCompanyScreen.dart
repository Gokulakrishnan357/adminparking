import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../Components/Utills/TextformFiled.dart';
import '../../../../../Controller/UserController.dart';
import '../../../../../Controller/CompanyController.dart';
import '../../../../../Model/CompanyModel.dart';
import '../../HomeScreen.dart';
import '../../SubScreens/BottomNavBar.dart';
import '../../SubScreens/QRScreen.dart';
import '../LogScreen.dart';
import '../SummaryScreen.dart';
import '../ProfileScreen/ProfileScreen.dart';
import 'package:path/path.dart' as path;

class AddCompanyForm extends StatefulWidget {
  final int? entryId;
  const AddCompanyForm({super.key, this.entryId});

  @override
  State<AddCompanyForm> createState() => _AddCompanyFormState();
}

class _AddCompanyFormState extends State<AddCompanyForm> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final vehicleNumberController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final logIdController = TextEditingController();
  final entryDateController = TextEditingController();
  final entryTimeController = TextEditingController();
  final exitTimeController = TextEditingController();
  final amountController = TextEditingController();
  final notesController = TextEditingController();

  // Form state
  String? selectedPaymentMethod;
  String? selectedLocation;
  double? latitude;
  double? longitude;

  bool isSignUpAllowed = false;
  bool isLoading = false;
  bool isEditMode = false;

  String? selectedSalesOwner;
  String? savedSalesOwnerName;
  String? savedSalesOwnerImagePath;

  final int _currentIndex = 0;
  int? userId;
  late CompanyController companyController;
  late UserController userController;
  bool isLoadingVisitor = true;
  final TextEditingController _timeController = TextEditingController();
  LogDetails? companyInfo;
  LogDetails? logDetails;
  bool isReadonlyMode = false;
  String? selectedAddress;
  String? selectedLatitude;
  String? selectedLongitude;
  bool isSavePressed = false;
  bool isCheckoutDone = false;

  List<String> statusList = ['Paid', 'Unpaid'];
  String? selectedStatus;

  List<String> paymentMethod = ['Cash', 'UPI'];

  String? selectedTime;

  File? _selectedImage;
  String? _selectedImageName;
  String? _uploadedImageUrl;
  bool isInitialReadOnly = false;
  bool isExitingVehicle = false;

  @override
  void dispose() {
    _timeController.dispose();
    vehicleNumberController.dispose();
    amountController.dispose();
    customerPhoneController.dispose();
    logIdController.dispose();
    entryDateController.dispose();
    entryTimeController.dispose();
    exitTimeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    companyController = Get.find<CompanyController>();
    userController = Get.find<UserController>();
    isEditMode = widget.entryId != null;
    if (isEditMode) {
      _loadCompanyData(widget.entryId!);
    }

    // Automatically fetch and set Log ID
    fetchAndSetLogId();

    // Set current date
    final currentDate = DateTime.now();
    final formattedDate = DateFormat('dd-MM-yyyy').format(currentDate);
    entryDateController.text = formattedDate;

    if (!statusList.contains(selectedStatus)) {
      selectedStatus = null;
    }
  }

  Future<void> fetchAndSetLogId() async {
    try {
      final logId = await companyController.fetchNewLogId();
      if (logId != null && logId.isNotEmpty) {
        if (mounted) {
          setState(() {
            logIdController.text = logId;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch Log ID')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching Log ID: $e')));
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Now safe to use context
    final currentTime = TimeOfDay.now();
    final formattedTime = currentTime.format(context);
    entryTimeController.text = formattedTime;
  }

  DateTime _parseDateTime(String dateStr, String timeStr) {
    final time = TimeOfDay(
      hour: int.parse(timeStr.split(":")[0]),
      minute: int.parse(timeStr.split(":")[1].split(" ")[0]),
    );

    final isPM = timeStr.toLowerCase().contains("pm");
    int hour = time.hour;
    if (isPM && hour < 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    final dateParts = dateStr.split('-');
    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[2]);

    return DateTime(year, month, day, hour, time.minute);
  }

  void _calculateAmount() {
    final entryDate = entryDateController.text;
    final entryTime = entryTimeController.text;
    final exitTime = exitTimeController.text;

    if (entryDate.isEmpty || entryTime.isEmpty || exitTime.isEmpty) return;

    try {
      final entryDateTime = _parseDateTime(entryDate, entryTime);
      final exitDateTime = _parseDateTime(entryDate, exitTime);

      final actualExit =
          exitDateTime.isBefore(entryDateTime)
              ? exitDateTime.add(const Duration(days: 1))
              : exitDateTime;

      final duration = actualExit.difference(entryDateTime);
      final totalMinutes = duration.inMinutes;

      final int days = (totalMinutes / 1440).ceil(); // 1440 = 24*60
      final amount = days * 50;

      amountController.text = amount.toString();
    } catch (e) {
      debugPrint('Amount calc error: $e');
    }
  }

  TimeOfDay? _parseTimeOfDay(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print('Time parse error: $e');
      return null;
    }
  }

  Future<void> _loadCompanyData(int entryId) async {
    setState(() {
      isLoading = true;
      isLoadingVisitor = true;
      isSavePressed = false;
      isInitialReadOnly = false;
    });

    try {
      final logData = await companyController.getLogByVehicle(entryId);

      if (logData != null) {
        final vehicle =
            logData.vehicledetails?.isNotEmpty == true
                ? logData.vehicledetails!.first
                : null;

        File? localImage;
        final imagePath =
            '${(await getApplicationDocumentsDirectory()).path}/entry_$entryId.jpg';
        final file = File(imagePath);
        if (await file.exists()) {
          localImage = file;
        }

        setState(() {
          companyInfo = logData;

          vehicleNumberController.text = vehicle?.vehiclenumber ?? '';
          amountController.text = logData.totalamount?.toString() ?? '';
          customerPhoneController.text = vehicle?.customerphone ?? '';
          logIdController.text = logData.logid ?? '';
          entryDateController.text = logData.entrydate ?? '';

          entryTimeController.text =
              logData.entrytime?.isNotEmpty == true
                  ? (_parseTimeOfDay(logData.entrytime!)?.format(context) ??
                      logData.entrytime!)
                  : '';

          exitTimeController.text =
              logData.exittime?.isNotEmpty == true
                  ? (_parseTimeOfDay(logData.exittime!)?.format(context) ??
                      logData.exittime!)
                  : '';

          selectedStatus = logData.paymentstatus;
          selectedAddress = logData.notes;

          selectedPaymentMethod =
              (logData.paymentMethod?.isNotEmpty ?? false)
                  ? logData.paymentMethod
                  : 'Cash';

          print(">>> paymentMethod set from logData: $selectedPaymentMethod");

          print(">>> paymentMethod set from logData: $selectedPaymentMethod");

          latitude = null;
          longitude = null;
          selectedLatitude = '';
          selectedLongitude = '';

          if (localImage != null) {
            _selectedImage = localImage;
            _selectedImageName = 'entry_$entryId.jpg';
            _uploadedImageUrl = null;
          } else if (vehicle?.imageurl != null) {
            _selectedImage = null;
            _uploadedImageUrl =
                'https://crestparkzapidev.crestclimbers.com/uploads/${vehicle!.imageurl}';
            _selectedImageName = vehicle.imageurl!;
          }

          isSignUpAllowed = logData.isexit ?? false;
          isLoadingVisitor = false;
        });
      } else {
        setState(() {
          isLoadingVisitor = false;
        });
      }
    } catch (e, stackTrace) {
      print("Error loading vehicle log data: $e");
      print("StackTrace: $stackTrace");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load log data')));
      setState(() {
        isLoadingVisitor = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
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

  void _submitForm() {
    final isFormValid = _formKey.currentState?.validate() ?? false;

    // Extra manual validation if Exit button is pressed
    if (isExitingVehicle) {
      if (amountController.text.isEmpty) {
        _showSnackBar("Amount is required");
        return;
      }

      if (selectedStatus == null || selectedStatus!.isEmpty) {
        _showSnackBar("Payment status is required");
        return;
      }

      if (selectedPaymentMethod == null || selectedPaymentMethod!.isEmpty) {
        _showSnackBar("Payment method is required");
        return;
      }
    }

    if (isFormValid) {
      _formKey.currentState?.save();
      _showConfirmDialog(
        isUpdate: widget.entryId != null,
        companyId: widget.entryId,
      );
    } else {
      Scrollable.ensureVisible(
        _formKey.currentContext!,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  String _formatTimeForServer(String time12hr) {
    try {
      // Parse input like "02:22 PM"
      final inputFormat = DateFormat('hh:mm a');
      final parsedTime = inputFormat.parse(time12hr);

      // Return it back in same 12-hour format with AM/PM
      return DateFormat('hh:mm a').format(parsedTime);
    } catch (e) {
      print("Time formatting error: $e");
      return time12hr;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showConfirmDialog({required bool isUpdate, required int? companyId}) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.directions_bike_rounded,
                    size: 40,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isUpdate
                        ? "Update Entry Details?"
                        : "Confirm this Entry Details?",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C448E),
                          minimumSize: const Size(50, 35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          'Submit',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();

                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final int? userId = prefs.getInt('userId');

                            if (userId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'User ID is missing. Cannot create entry.',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (isExitingVehicle) {
                              if (amountController.text.isEmpty) {
                                _showSnackBar("Amount is required");
                                return;
                              }
                              if (selectedStatus == null ||
                                  selectedStatus!.isEmpty) {
                                _showSnackBar("Payment status is required");
                                return;
                              }
                              if (selectedPaymentMethod == null ||
                                  selectedPaymentMethod!.isEmpty) {
                                _showSnackBar("Payment method is required");
                                return;
                              }
                            }

                            if (isUpdate && companyId != null) {
                              await companyController.updateEntry(
                                entryId: widget.entryId!,
                                exitTime:
                                    exitTimeController.text.trim().isEmpty
                                        ? null
                                        : _formatTimeForServer(
                                          exitTimeController.text.trim(),
                                        ),
                                imageUrl: _selectedImageName,
                                isExit:
                                    true, // ✅ force exit to be saved in backend
                                paymentMethod: selectedPaymentMethod,
                                paymentStatus: selectedStatus,
                                totalAmount:
                                    amountController.text.trim().isEmpty
                                        ? null
                                        : double.tryParse(
                                          amountController.text.trim(),
                                        ),
                              );

                              // ✅ REFRESH data to update the UI based on new isexit=true
                              await _loadCompanyData(widget.entryId!);

                              // ✅ Also locally mark exit flag to hide buttons immediately
                              setState(() {
                                isExitingVehicle = true;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Entry updated successfully'),
                                ),
                              );

                              print("Creating Exit with values:");
                              print("adminId: $userId");
                              print(
                                "customerPhone: ${customerPhoneController.text.trim()}",
                              );
                              print(
                                "entryDate: ${DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(entryDateController.text))}",
                              );
                              print(
                                "entryTime: ${entryTimeController.text.trim()}",
                              );
                              print("exitTime: null");
                              print("imageUrl: $_uploadedImageUrl");
                              print("logId: ${logIdController.text.trim()}");
                              print("paymentMethod: $selectedPaymentMethod");
                              print("paymentStatus: $selectedStatus");
                              print(
                                "totalAmount: ${amountController.text.trim().isEmpty ? null : double.tryParse(amountController.text.trim())}",
                              );
                              print(
                                "vehicleNumber: ${vehicleNumberController.text.trim()}",
                              );

                              // ✅ Show confirmation dialog
                              showDialog(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      title: Text(
                                        "This Exit is Completed...",
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                      content: Text(
                                        "Please confirm if the payment has been received. If not, Click the 'Generate Ticket QR' button to proceed with the payment.",
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(
                                              context,
                                            ).pop(); // close dialog
                                          },
                                          child: Text(
                                            "OK",
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                              color: const Color(0xFF0C448E),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                            } else {
                              await companyController.createEntry(
                                adminId: userId,
                                customerPhone:
                                    customerPhoneController.text.trim().isEmpty
                                        ? null
                                        : customerPhoneController.text.trim(),
                                entryDate: DateFormat('yyyy-MM-dd').format(
                                  DateFormat(
                                    'dd-MM-yyyy',
                                  ).parse(entryDateController.text),
                                ),
                                entryTime: entryTimeController.text.trim(),
                                exitTime: null,
                                imageUrl: _selectedImageName,
                                logId: logIdController.text.trim(),
                                paymentMethod: selectedPaymentMethod,
                                paymentStatus: selectedStatus,
                                totalAmount:
                                    amountController.text.trim().isEmpty
                                        ? null
                                        : double.tryParse(
                                          amountController.text.trim(),
                                        ),
                                vehicleNumber:
                                    vehicleNumberController.text.trim(),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Entry created successfully'),
                                ),
                              );

                              print("Creating entry with values:");
                              print("adminId: $userId");
                              print(
                                "customerPhone: ${customerPhoneController.text.trim()}",
                              );
                              print(
                                "entryDate: ${DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(entryDateController.text))}",
                              );
                              print(
                                "entryTime: ${entryTimeController.text.trim()}",
                              );
                              print("exitTime: null");
                              print("imageUrl: $_uploadedImageUrl");
                              print("logId: ${logIdController.text.trim()}");
                              print("paymentMethod: $selectedPaymentMethod");
                              print("paymentStatus: $selectedStatus");
                              print(
                                "totalAmount: ${amountController.text.trim().isEmpty ? null : double.tryParse(amountController.text.trim())}",
                              );
                              print(
                                "vehicleNumber: ${vehicleNumberController.text.trim()}",
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LogScreen(),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  bool get canSubmit {
    return vehicleNumberController.text.isNotEmpty &&
        logIdController.text.isNotEmpty &&
        entryDateController.text.isNotEmpty &&
        entryTimeController.text.isNotEmpty;
  }

  bool get canSubmit1 {
    return vehicleNumberController.text.isNotEmpty &&
        logIdController.text.isNotEmpty &&
        entryDateController.text.isNotEmpty &&
        entryTimeController.text.isNotEmpty &&
        amountController.text.isNotEmpty &&
        selectedStatus!.isNotEmpty &&
        paymentMethod.isNotEmpty &&
        exitTimeController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEditMode ? "Entry Details" : "Add New Entry",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode:
            isSavePressed
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,

        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            _buildLabel("Vehicle No"),
            CustomTextFormField(
              hintText: 'Enter Vehicle No',
              controller: vehicleNumberController,
              validator: (val) {
                if (isSavePressed && val == null) {
                  return 'Vehicle Number is required';
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            _buildLabel1("Phone No"),
            CustomTextFormField(
              hintText: 'Enter Phone Number',
              controller: customerPhoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Allow digits only
                LengthLimitingTextInputFormatter(10), // Max length: 10
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                }
                if (value.length != 10) {
                  return 'Phone number must be exactly 10 digits';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            _buildLabel1("Log ID"),

            CustomTextFormField(
              hintText: 'Log ID',
              controller: logIdController,
              readOnly: true,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Log ID is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            _buildLabel1("Date"),
            CustomTextFormField(
              controller: entryDateController,
              hintText: 'Select Date',
              readOnly: true,
              suffixIcon: Icon(
                Icons.calendar_month_rounded,
              ), // Optional calendar icon
              onTap: () async {
                // Optional date picker

                // DateTime? pickedDate = await showDatePicker(
                //   context: context,
                //   initialDate: DateTime.now(),
                //   firstDate: DateTime(2000),
                //   lastDate: DateTime(2101),
                // );
                //
                // if (pickedDate != null) {
                //   String formattedDate = DateFormat(
                //     'dd-MM-yyyy',
                //   ).format(pickedDate);
                //   entryDateController.text = formattedDate;
                // }
              },
            ),

            const SizedBox(height: 20),

            _buildLabel1("Entry Time"),
            CustomTextFormField(
              controller: entryTimeController,
              hintText: 'Select Time',
              readOnly: true,
              suffixIcon: Icon(Icons.access_time),
              onTap: () async {
                // TimeOfDay? pickedTime = await showTimePicker(
                //   context: context,
                //   initialTime: TimeOfDay.now(),
                // );
                //
                // if (pickedTime != null) {
                //   entryTimeController.text = pickedTime.format(context);
                // }
              },
            ),

            const SizedBox(height: 20),

            _buildLabel1("Exit Time"),
            _buildTimePicker(),

            const SizedBox(height: 20),

            _buildLabel1("Amount"),

            CustomTextFormField(
              hintText: 'Your Amount',
              controller: amountController,
              readOnly: isInitialReadOnly,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed < 0) {
                    return 'Enter a valid amount';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            _buildLabel("Payment Status"),
            DropdownButtonFormField<String>(
              value:
                  statusList.contains(selectedStatus) ? selectedStatus : null,
              onChanged: (val) => setState(() => selectedStatus = val),
              validator: (val) {
                if (isSavePressed && val == null) {
                  return "Please select status";
                }
                return null;
              },
              decoration: _dropdownDecoration("Select Status"),
              items:
                  statusList
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
            ),

            const SizedBox(height: 20),

            _buildLabel1("Payment Method"),
            DropdownButtonFormField<String>(
              value:
                  paymentMethod.contains(selectedPaymentMethod)
                      ? selectedPaymentMethod
                      : null,
              onChanged:
                  isInitialReadOnly
                      ? null
                      : (value) {
                        setState(() {
                          selectedPaymentMethod = value;
                        });
                      },
              validator: (val) {
                if (isSavePressed &&
                    isExitingVehicle &&
                    (val == null || val.isEmpty)) {
                  return "Please select Payment Method";
                }
                return null;
              },
              decoration: _dropdownDecoration("Select Option"),
              items:
                  paymentMethod.map((method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text(method),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 20),

            buildTakePhotoField(),

            const SizedBox(height: 40),

            isEditMode && selectedPaymentMethod != 'Cash'
                ? Center(
                  child: TextButton(
                    onPressed: () async {
                      final int? entryId = widget.entryId;

                      if (entryId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Entry ID is missing.")),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                      );

                      try {
                        final qrDetails = await companyController
                            .generateQrCode(entryId);
                        Navigator.pop(context); // Remove the loading dialog

                        if (qrDetails != null && qrDetails.qrCodeUrl != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => QrDisplayPage(qrDetails: qrDetails),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "QR generation failed or QR not available.",
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        Navigator.pop(context); // Close loading dialog
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    },

                    child: Text(
                      'Generate Ticket QR',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: const Color(0xFF757373),
                      ),
                    ),
                  ),
                )
                : const SizedBox(height: 20),

            if (!isExitingVehicle) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26.0,
                  vertical: 46.0,
                ),
                child: _buildActionButtons(),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        onAddTap: () => print("Floating Add tapped"),
      ),
    );
  }

  Widget _buildActionButtons() {
    // Return empty container if exiting vehicle
    if (isExitingVehicle) {
      return Container();
    }

    if (widget.entryId != null) {
      return isLoadingVisitor
          ? const Center(child: CircularProgressIndicator())
          : companyInfo != null
          ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildCancelButton(), _buildSubmitButton()],
          )
          : const Center(
            child: Text(
              "Failed to load Entry Details.",
              style: TextStyle(color: Colors.red),
            ),
          );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_buildCancelButton(), _buildSubmitButton()],
      );
    }
  }

  Widget _buildCancelButton() {
    // Hide if exiting vehicle or entry is completed
    if (isExitingVehicle || (companyInfo?.isexit ?? false)) {
      return Container();
    }

    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(
        'Cancel',
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    // Hide if exiting vehicle or entry is completed
    if (isExitingVehicle || (companyInfo?.isexit ?? false)) {
      return Container();
    }

    final bool isEnabled = isEditMode ? canSubmit1 : canSubmit;

    return ElevatedButton(
      onPressed:
          isEnabled
              ? () {
                setState(() {
                  isSavePressed = true;
                  isInitialReadOnly = false;
                });

                final isFormValid = _formKey.currentState?.validate() ?? false;

                if (isFormValid) {
                  _submitForm();
                } else {
                  Scrollable.ensureVisible(
                    _formKey.currentContext!,
                    duration: const Duration(milliseconds: 300),
                  );
                }
              }
              : null,

      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? const Color(0xFF0C448E) : Colors.grey[400],
        minimumSize: const Size(150, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        disabledBackgroundColor: Colors.grey[400],
      ),
      child: Text(
        isEditMode ? 'Exit Vehicle' : 'Assign & Save',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isEnabled ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFD4D4D4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFD4D4D4), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      hintText: hint,
      hintStyle: GoogleFonts.montserrat(
        fontWeight: FontWeight.w300,
        fontSize: 14,
        height: 1.0,
        letterSpacing: 0,
        textStyle: const TextStyle(
          color: Color(0xFFA4A4A4),
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: RichText(
      text: TextSpan(
        text: text,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: const Color(0xFF282727),
        ),
        children: [
          TextSpan(
            text: ' *',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.red,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildLabel1(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: RichText(
      text: TextSpan(
        text: text,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: const Color(0xFF282727),
        ),
      ),
    ),
  );

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  exitTimeController.text.isEmpty && isSavePressed
                      ? Colors.red
                      : Colors.grey.shade400,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  hintText: 'HH:MM AM/PM',
                  controller: exitTimeController,
                  readOnly: true, // Always read-only
                  onTap:
                      isInitialReadOnly
                          ? null
                          : () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              final formattedTime = pickedTime.format(context);
                              setState(() {
                                exitTimeController.text = formattedTime;
                              });
                            }
                          },
                  validator: (val) {
                    if (isSavePressed &&
                        isExitingVehicle &&
                        (val == null || val.isEmpty)) {
                      return "Please select Exit Time";
                    }
                    return null;
                  },

                  style: GoogleFonts.montserrat(
                    fontWeight:
                        exitTimeController.text.isNotEmpty
                            ? FontWeight.w600
                            : FontWeight.w500,
                    fontSize: 14,
                    color:
                        exitTimeController.text.isNotEmpty
                            ? Colors.black
                            : const Color(0xFFA4A4A4),
                  ),
                  hintTextStyle: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: const Color(0xFFA4A4A4),
                  ),
                ),
              ),

              // Button to set current time
              Container(
                height: 38,
                margin: const EdgeInsets.all(4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C448E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed:
                      isInitialReadOnly
                          ? null
                          : () {
                            final now = TimeOfDay.now();
                            final formattedTime = now.format(context);
                            setState(() {
                              exitTimeController.text = formattedTime;
                              _calculateAmount();
                            });
                          },
                  child: Text(
                    'Set Current Time',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTakePhotoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Take Photo',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextFormField(
              enabled: false,
              controller: TextEditingController(
                text: _selectedImageName ?? 'No file selected',
              ),
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            if (_selectedImage != null)
              Positioned(
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    print("View button clicked");
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            contentPadding: const EdgeInsets.all(10),
                            content: Image.file(
                              _selectedImage!,
                              fit: BoxFit.contain,
                            ),
                          ),
                    );
                  },
                  child: Text(
                    'View',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: const Color(0xFF0C448E),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Center(
            child: GestureDetector(
              onTap: _pickImageFromCamera,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt_outlined, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Take Vehicle Photo',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _selectedImage = imageFile;
        _selectedImageName = path.basename(pickedFile.path);
      });

      // Upload to server
      String? uploadedImageName = await _uploadImageToServer(imageFile);
      if (uploadedImageName != null) {
        setState(() {
          _uploadedImageUrl =
              'https://crestparkzapidev.crestclimbers.com/uploads$uploadedImageName';
        });
      }
    }
  }

  Future<String?> _uploadImageToServer(File imageFile) async {
    final uri = Uri.parse("https://crestparkzapidev.crestclimbers.com/upload");
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = json.decode(resStr);
      return data['filename'];
    } else {
      print('Upload failed, saving locally.');

      // Save locally with entryId as filename
      final appDir = await getApplicationDocumentsDirectory();
      final localImagePath = '${appDir.path}/entry_${widget.entryId}.jpg';
      await imageFile.copy(localImagePath);

      setState(() {
        _uploadedImageUrl = localImagePath;
        _selectedImageName =
            'entry_${widget.entryId}.jpg'; // Still store filename
      });

      return 'entry_${widget.entryId}.jpg'; // return a fallback filename
    }
  }
}
