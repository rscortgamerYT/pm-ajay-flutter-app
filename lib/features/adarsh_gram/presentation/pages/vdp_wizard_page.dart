import 'package:flutter/material.dart';
import 'package:pm_ajay/features/adarsh_gram/data/models/vdp_model.dart';

/// VDP Wizard - Step-by-step Village Development Plan creation
class VDPWizardPage extends StatefulWidget {
  final String villageId;
  final String villageName;

  const VDPWizardPage({
    super.key,
    required this.villageId,
    required this.villageName,
  });

  @override
  State<VDPWizardPage> createState() => _VDPWizardPageState();
}

class _VDPWizardPageState extends State<VDPWizardPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Format I - General Information
  final _censusCodeController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _blockController = TextEditingController();
  final _gramPanchayatController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _nearestTownController = TextEditingController();
  final _distanceController = TextEditingController();
  final _accessibilityController = TextEditingController();
  
  // Format II - Demographic Profile
  final _totalPopulationController = TextEditingController();
  final _scPopulationController = TextEditingController();
  final _totalHouseholdsController = TextEditingController();
  final _bplHouseholdsController = TextEditingController();
  final _literacyRateController = TextEditingController();

  @override
  void dispose() {
    _censusCodeController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _blockController.dispose();
    _gramPanchayatController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _nearestTownController.dispose();
    _distanceController.dispose();
    _accessibilityController.dispose();
    _totalPopulationController.dispose();
    _scPopulationController.dispose();
    _totalHouseholdsController.dispose();
    _bplHouseholdsController.dispose();
    _literacyRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VDP Wizard: ${widget.villageName}'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        onStepTapped: (step) => setState(() => _currentStep = step),
        steps: [
          Step(
            title: const Text('Format I: General Information'),
            content: _buildFormatIForm(),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Format II: Demographic Profile'),
            content: _buildFormatIIForm(),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Format III: Infrastructure Assessment'),
            content: _buildFormatIIIForm(),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Format IV: Socio-Economic Status'),
            content: _buildFormatIVForm(),
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Format V: Development Priorities'),
            content: _buildFormatVForm(),
            isActive: _currentStep >= 4,
            state: _currentStep > 4 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Format VI: Action Plan & Budget'),
            content: _buildFormatVIForm(),
            isActive: _currentStep >= 5,
            state: _currentStep > 5 ? StepState.complete : StepState.indexed,
          ),
        ],
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else {
      _submitVDP();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submitVDP() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('VDP submitted successfully!')),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildFormatIForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _censusCodeController,
            decoration: const InputDecoration(labelText: 'Census Code'),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          TextFormField(
            controller: _stateController,
            decoration: const InputDecoration(labelText: 'State'),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          TextFormField(
            controller: _districtController,
            decoration: const InputDecoration(labelText: 'District'),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          TextFormField(
            controller: _blockController,
            decoration: const InputDecoration(labelText: 'Block'),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          TextFormField(
            controller: _gramPanchayatController,
            decoration: const InputDecoration(labelText: 'Gram Panchayat'),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _latitudeController,
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _longitudeController,
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _nearestTownController,
            decoration: const InputDecoration(labelText: 'Nearest Town'),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          TextFormField(
            controller: _distanceController,
            decoration: const InputDecoration(labelText: 'Distance from Town (km)'),
            keyboardType: TextInputType.number,
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          TextFormField(
            controller: _accessibilityController,
            decoration: const InputDecoration(labelText: 'Road Accessibility'),
            maxLines: 2,
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFormatIIForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Demographic Profile', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        TextFormField(
          controller: _totalPopulationController,
          decoration: const InputDecoration(labelText: 'Total Population'),
          keyboardType: TextInputType.number,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        TextFormField(
          controller: _scPopulationController,
          decoration: const InputDecoration(labelText: 'SC Population'),
          keyboardType: TextInputType.number,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        TextFormField(
          controller: _totalHouseholdsController,
          decoration: const InputDecoration(labelText: 'Total Households'),
          keyboardType: TextInputType.number,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        TextFormField(
          controller: _bplHouseholdsController,
          decoration: const InputDecoration(labelText: 'BPL Households'),
          keyboardType: TextInputType.number,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        TextFormField(
          controller: _literacyRateController,
          decoration: const InputDecoration(labelText: 'Literacy Rate (%)'),
          keyboardType: TextInputType.number,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildFormatIIIForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Infrastructure Assessment', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        CheckboxListTile(
          title: const Text('Piped Water Supply'),
          value: false,
          onChanged: (v) => setState(() {}),
        ),
        CheckboxListTile(
          title: const Text('All-Weather Road'),
          value: false,
          onChanged: (v) => setState(() {}),
        ),
        CheckboxListTile(
          title: const Text('Electricity Connection'),
          value: false,
          onChanged: (v) => setState(() {}),
        ),
        CheckboxListTile(
          title: const Text('Primary Health Center'),
          value: false,
          onChanged: (v) => setState(() {}),
        ),
        CheckboxListTile(
          title: const Text('Primary School'),
          value: false,
          onChanged: (v) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildFormatIVForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Socio-Economic Status', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Primary Livelihood'),
          items: ['Agriculture', 'Labor', 'Business', 'Service'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (v) {},
          validator: (v) => v == null ? 'Required' : null,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Average Monthly Income (₹)'),
          keyboardType: TextInputType.number,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Major Social Issues'),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildFormatVForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Development Priorities', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Priority 1: Sector & Intervention'),
          maxLines: 2,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Priority 2: Sector & Intervention'),
          maxLines: 2,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Priority 3: Sector & Intervention'),
          maxLines: 2,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Convergence Opportunities'),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildFormatVIForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Action Plan & Budget', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Total Estimated Budget (₹)'),
          keyboardType: TextInputType.number,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'PM-AJAY Allocation (₹)'),
          keyboardType: TextInputType.number,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Convergence Funds (₹)'),
          keyboardType: TextInputType.number,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Timeline (months)'),
          keyboardType: TextInputType.number,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Monitoring Plan'),
          maxLines: 3,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
      ],
    );
  }
}