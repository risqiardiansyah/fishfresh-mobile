import 'package:flutter/material.dart';

class SelectInput extends StatefulWidget {
  const SelectInput({super.key});

  @override
  State<SelectInput> createState() => _SelectInputState();
}

class _SelectInputState extends State<SelectInput> {
  // List of options for the dropdown
  final List<String> _items = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];

  // Variable to store selected value
  String? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dropdown Select Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Label for Dropdown
              const Text(
                'Please select an option:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),

              // DropdownButton widget
              DropdownButton<String>(
                isExpanded:
                    true, // Allow the dropdown to fill the available space
                hint: const Text('Select an option'), // Placeholder
                value: _selectedItem, // Selected item
                items: _items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedItem = value; // Update the selected value
                  });
                },
              ),
              const SizedBox(height: 20),

              // Display selected value
              Text(
                _selectedItem != null
                    ? 'Selected: $_selectedItem'
                    : 'No option selected',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: SelectInput(),
  ));
}
