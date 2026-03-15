import 'package:flutter/material.dart';
import 'widgets/step_one_user_info.dart';
import 'widgets/step_two_service_selection.dart';
import 'widgets/step_three_summary.dart';

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

  // Controllers for Step 1
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  final List<String> steps = ["ព័ត៌មាន", "សេវាកម្ម", "ផ្ទៀងផ្ទាត់"];

  // 2. Always clean up controllers to prevent memory leaks on your machine!
  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  // 3. Extracted navigation logic for cleaner code and validation
  void _nextStep() {
    if (currentStep == 0) {
      if (nameController.text.trim().isEmpty ||
          phoneController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("សូមបំពេញឈ្មោះ និងលេខទូរស័ព្ទ")),
        );
        return; // Stops here if validation fails
      }
    } else if (currentStep == 1) {
      if (selectedServiceNames.isEmpty) {
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
      debugPrint("Submit Booking to FastAPI backend!");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  StepOneUserInfo(
                    nameController: nameController,
                    phoneController: phoneController,
                    dateController: dateController,
                    timeController: timeController,
                  ),
                  StepTwoServiceSelection(
                    // Update this callback to receive both the total and the list
                    onSelectionChanged: (newTotal, selectedList) =>
                        setState(() {
                          total = newTotal;
                          selectedServiceNames = selectedList;
                        }),
                  ),
                  StepThreeSummary(
                    userName: nameController.text,
                    phone: phoneController.text,
                    date: dateController.text,
                    time: timeController.text,
                    selectedServices:
                        selectedServiceNames, // 5. Now perfectly dynamic!
                    total: total,
                  ),
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
