import 'package:flutter/material.dart';

/// Smart Hostel Proposal Workflow
class SmartHostelProposalPage extends StatefulWidget {
  const SmartHostelProposalPage({super.key});

  @override
  State<SmartHostelProposalPage> createState() => _SmartHostelProposalPageState();
}

class _SmartHostelProposalPageState extends State<SmartHostelProposalPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();
  final _budgetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Hostel Proposal')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 4) setState(() => _currentStep++);
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        steps: [
          Step(
            title: const Text('Basic Details'),
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  TextFormField(
                    controller: _capacityController,
                    decoration: const InputDecoration(labelText: 'Capacity'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text('Infrastructure'),
            content: Column(
              children: [
                CheckboxListTile(
                  value: true,
                  onChanged: (_) {},
                  title: const Text('Water Supply'),
                ),
                CheckboxListTile(
                  value: true,
                  onChanged: (_) {},
                  title: const Text('Electricity Backup'),
                ),
                CheckboxListTile(
                  value: false,
                  onChanged: (_) {},
                  title: const Text('Solar Panels'),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Budget & Funding'),
            content: Column(
              children: [
                TextFormField(
                  controller: _budgetController,
                  decoration: const InputDecoration(labelText: 'Total Budget (₹)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text('Funding Sources:'),
                CheckboxListTile(
                  value: true,
                  onChanged: (_) {},
                  title: const Text('Central Government'),
                ),
                CheckboxListTile(
                  value: true,
                  onChanged: (_) {},
                  title: const Text('State Government'),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Documentation'),
            content: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: const Text('Land Documents'),
                  trailing: IconButton(icon: const Icon(Icons.upload), onPressed: () {}),
                ),
                ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: const Text('Site Plan'),
                  trailing: IconButton(icon: const Icon(Icons.upload), onPressed: () {}),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Review & Submit'),
            content: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location: ${_locationController.text}'),
                    Text('Capacity: ${_capacityController.text} students'),
                    Text('Budget: ₹${_budgetController.text}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Submit Proposal'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _capacityController.dispose();
    _budgetController.dispose();
    super.dispose();
  }
}