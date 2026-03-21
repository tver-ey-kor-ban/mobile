import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/pages/login_page.dart' as login;
import '../../../../shared/services/auth_service.dart';
import '../../domain/models/car_model.dart';
import '../../domain/models/service_model.dart';
import 'widgets/step_one_car_selection.dart';
import 'widgets/step_two_car_services.dart';
import 'widgets/step_three_confirmation.dart';

class BookingPage extends StatefulWidget {
  final String? initialService;
  const BookingPage({super.key, this.initialService});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int currentStep = 0;
  double total = 0.0;
  List<String> selectedServiceNames =
      []; // 1. Added dynamic state for selected services
  bool _authChecked = false;

  @override
  void initState() {
    super.initState();
    // Check auth after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  void _checkAuth() async {
    final auth = context.read<AuthService>();
    if (!auth.isAuthenticated) {
      await login.showLoginModal(context);
      if (!auth.isAuthenticated && mounted) {
        Navigator.of(context).pop();
      }
    }
    setState(() {
      _authChecked = true;
    });
  }

  // Controllers for Step 1
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  final List<String> steps = ["រថយន្ត", "សេវាកម្ម", "ផ្ទៀងផ្ទាត់"];

  // Car selection
  SelectedCar? selectedCar;

  // Service selection
  List<CarService> selectedServices = [];
  double totalPrice = 0.0;

  // Appointment details
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final notesController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    dateController.dispose();
    timeController.dispose();
    notesController.dispose();
    super.dispose();
  }

  // 3. Extracted navigation logic for cleaner code and validation
  void _nextStep() {
    if (currentStep == 0) {
      if (selectedCar == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("សូមជ្រើសរើសរថយន្ត")),
        );
        return;
      }
    } else if (currentStep == 1) {
      if (selectedServices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("សូមជ្រើសរើសសេវាកម្មយ៉ាងហោចណាស់មួយ")),
        );
        return;
      }
    }

    if (currentStep < 2) {
      setState(() => currentStep++);
    } else {
      // Final Submit Logic
      _submitBooking();
    }
  }

  void _submitBooking() {
    // TODO: Submit booking to backend
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Confirmed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle: ${selectedCar!.displayName}'),
            Text('Services: ${selectedServices.length} selected'),
            Text('Total: \$${totalPrice.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_authChecked) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.initialService ?? "ការកក់ទុក")),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.initialService ?? "ការកក់ទុក")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 4. Visual Stepper Indicator (1 - 2 - 3)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: currentStep >= index
                        ? Colors.red
                        : Colors.grey.shade300,
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Step content rendering
            Expanded(
              child: IndexedStack(
                index: currentStep,
                children: [
                  StepOneCarSelection(
                    onCarSelected: (car) {
                      setState(() {
                        selectedCar = car;
                      });
                    },
                    initialCar: selectedCar,
                  ),
                  if (selectedCar != null)
                    StepTwoCarServices(
                      selectedCar: selectedCar!,
                      onServicesSelected: (services, total) {
                        setState(() {
                          selectedServices = services;
                          totalPrice = total;
                        });
                      },
                      initiallySelectedServiceIds:
                          selectedServices.map((s) => s.id).toList(),
                    )
                  else
                    const Center(child: Text('Please select a car first')),
                  if (selectedCar != null && selectedServices.isNotEmpty)
                    StepThreeConfirmation(
                      selectedCar: selectedCar!,
                      selectedServices: selectedServices,
                      totalPrice: totalPrice,
                      selectedDate: selectedDate,
                      selectedTime: selectedTime,
                      notes: notesController.text,
                    )
                  else
                    const Center(
                        child: Text('Please complete previous steps')),
                ],
              ),
            ),

            // Navigation Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentStep > 0)
                  ElevatedButton(
                    onPressed: () => setState(() => currentStep--),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("ត្រឡប់ក្រោយ"),
                  )
                else
                  const SizedBox.shrink(), // Keeps the "Next" button aligned right on Step 1

                ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(currentStep == 2 ? "បញ្ជាក់ការកក់" : "បន្ទាប់"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
