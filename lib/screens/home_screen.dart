import 'package:flutter/material.dart';
import 'package:flutter_coreml/services/coreml_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CoreMLService _coreMLService = CoreMLService();

  final _formKey = GlobalKey<FormState>();

  final _sepalLengthController = TextEditingController(text: '5.1');
  final _sepalWidthController = TextEditingController(text: '3.5');
  final _petalLengthController = TextEditingController(text: '1.4');
  final _petalWidthController = TextEditingController(text: '0.2');

  String _predictionResult = 'Not predicted yet';
  bool _isLoading = false;
  bool _isUsingNeuralEngine = false;

  @override
  void initState() {
    super.initState();
    _checkNeuralEngine();
  }

  Future<void> _checkNeuralEngine() async {
    final isUsingNE = await _coreMLService.isUsingNeuralEngine();
    setState(() {
      _isUsingNeuralEngine = isUsingNE;
    });
  }

  Future<void> _predict() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _coreMLService.predictIrisSpecies(
          sepalLength: double.parse(_sepalLengthController.text),
          sepalWidth: double.parse(_sepalWidthController.text),
          petalLength: double.parse(_petalLengthController.text),
          petalWidth: double.parse(_petalWidthController.text),
        );

        setState(() {
          _predictionResult = result ?? 'Prediction failed';
        });
      } catch (e) {
        setState(() {
          _predictionResult = 'Error: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) {
        FocusScope.of(context).unfocus();
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iris Species Predictor'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Enter Iris Measurements',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            label: 'Sepal Length (cm)',
                            controller: _sepalLengthController,
                          ),
                          const SizedBox(height: 8),
                          _buildField(
                            label: 'Sepal Width (cm)',
                            controller: _sepalWidthController,
                          ),
                          const SizedBox(height: 8),
                          _buildField(
                              label: 'Patel Length(cm)',
                              controller: _petalLengthController),
                          const SizedBox(height: 8),
                          _buildField(
                              label: 'Patel Width (cm)',
                              controller: _petalWidthController),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _predict,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('PREDICT SPECIES',
                            style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Prediction Result',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _predictionResult,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Using Neural Engine:'),
                          Chip(
                            label: Text(
                              _isUsingNeuralEngine ? 'Yes' : 'No',
                              style: TextStyle(
                                color: _isUsingNeuralEngine
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            backgroundColor: _isUsingNeuralEngine
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 160),
                ],
              ),
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  @override
  void dispose() {
    _sepalLengthController.dispose();
    _sepalWidthController.dispose();
    _petalLengthController.dispose();
    _petalWidthController.dispose();
    super.dispose();
  }
}
