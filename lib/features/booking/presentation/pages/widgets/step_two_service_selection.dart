import 'package:flutter/material.dart';

class ServiceOption {
  final String name;
  final double price;
  bool isSelected;

  ServiceOption({
    required this.name,
    required this.price,
    this.isSelected = false,
  });
}

class StepTwoServiceSelection extends StatefulWidget {
  final Function(double, List<String>) onSelectionChanged;

  const StepTwoServiceSelection({super.key, required this.onSelectionChanged});

  @override
  State<StepTwoServiceSelection> createState() =>
      _StepTwoServiceSelectionState();
}

class _StepTwoServiceSelectionState extends State<StepTwoServiceSelection> {
  final List<ServiceOption> services = [
    ServiceOption(name: "ប្តូរប្រេង SW-40", price: 55),
    ServiceOption(name: "ប្តូរប្រេងប្រអប់លេខ (Dexron III)", price: 60),
    ServiceOption(name: "ប្តូរប្រេងម៉ាស៊ីន", price: 13),
    ServiceOption(name: "ប្តូរត្រង DotsJoost", price: 15),
    ServiceOption(name: "ជួសជុល", price: 46),
  ];

  void _toggleService(int index) {
    setState(() {
      services[index].isSelected = !services[index].isSelected;

      // 1. Calculate the new total
      double total = services
          .where((s) => s.isSelected)
          .fold(0, (sum, s) => sum + s.price);

      // 2. Create the list of selected names
      List<String> selectedNames = services
          .where((s) => s.isSelected)
          .map((s) => s.name)
          .toList();

      // 3. Send both back to BookingPage
      widget.onSelectionChanged(total, selectedNames);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: CheckboxListTile(
            value: services[index].isSelected,
            onChanged: (_) => _toggleService(index),
            title: Text(
              services[index].name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            secondary: Text(
              "\$${services[index].price.toInt()}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 16,
              ),
            ),
            activeColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }
}
