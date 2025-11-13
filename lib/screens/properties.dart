import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PublishPropertyScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const PublishPropertyScreen({Key? key}) : super(key: key);

  @override
  State<PublishPropertyScreen> createState() => _PublishPropertyScreenState();
}

class _PublishPropertyScreenState extends State<PublishPropertyScreen> {
  int _currentStep = 0;

  // Paso 1
  String _tipoPropiedad = 'Casa';
  final List<String> _tiposPropiedad = const ['Casa', 'Departamento'];
  final TextEditingController _direccion1Controller = TextEditingController();
  final TextEditingController _direccion2Controller = TextEditingController();
  String _comuna = 'Las Condes';
  final List<String> _comunas = const ['Las Condes', 'Providencia', 'Ñuñoa'];

  // Paso 2
  final TextEditingController _metrosController = TextEditingController();
  int _banos = 1;
  final List<int> _banosList = const [1, 2, 3, 4];
  bool _estacionamiento = false;
  bool _quincho = false;
  bool _gimnasio = false;

  // Paso 3
  final TextEditingController _precioController = TextEditingController();

  void _resetForm() {
    setState(() {
      _currentStep = 0;
      _tipoPropiedad = _tiposPropiedad.first;
      _direccion1Controller.clear();
      _direccion2Controller.clear();
      _comuna = _comunas.first;
      _metrosController.clear();
      _banos = _banosList.first;
      _estacionamiento = false;
      _quincho = false;
      _gimnasio = false;
      _precioController.clear();
    });
  }

  void _showFormDialog() {
    _resetForm();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: StatefulBuilder(
            builder: (context, setStateSB) {
              // ignore: no_leading_underscores_for_local_identifiers
              void _continueSB() {
                if (_currentStep < 2) {
                  setStateSB(() => _currentStep += 1);
                } else {
                  _showResumenDialog();
                }
              }
              // ignore: no_leading_underscores_for_local_identifiers
              void _cancelSB() {
                Navigator.of(context).pop(); // cancelar formulario
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.maxFinite,
                  height: 500,
                  child: Column(
                    children: [
                      Text(
                        'Publicación de Propiedad',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Stepper(
                          type: StepperType.horizontal,
                          currentStep: _currentStep,
                          onStepContinue: _continueSB,
                          onStepCancel: () {
                            if (_currentStep == 0) {
                              _cancelSB();
                            } else {
                              setStateSB(() => _currentStep -= 1);
                            }
                          },
                          controlsBuilder: (context, details) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (_currentStep == 0)
                                  TextButton(
                                    onPressed: details.onStepCancel,
                                    child: const Text('Cancelar'),
                                  ),
                                if (_currentStep > 0)
                                  TextButton(
                                    onPressed: details.onStepCancel,
                                    child: const Text('Atrás'),
                                  ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  onPressed: details.onStepContinue,
                                  child: Text(
                                    _currentStep == 2 ? 'Finalizar' : 'Siguiente',
                                  ),
                                ),
                              ],
                            );
                          },
                          steps: <Step>[
                            Step(
                              title: const Text('Paso 1'),
                              content: _buildPaso1(setStateSB),
                              isActive: _currentStep >= 0,
                            ),
                            Step(
                              title: const Text('Paso 2'),
                              content: _buildPaso2(setStateSB),
                              isActive: _currentStep >= 1,
                            ),
                            Step(
                              title: const Text('Paso 3'),
                              content: _buildPaso3(),
                              isActive: _currentStep >= 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showResumenDialog() async {
    final tipo = _tipoPropiedad;
    final direccion1 = _direccion1Controller.text.trim();
    final direccion2 = _direccion2Controller.text.trim();
    final comuna = _comuna;
    final metros = double.tryParse(_metrosController.text.trim()) ?? 0;
    final banos = _banos;
    final extrasList = <String>[
      if (_estacionamiento) 'Estacionamiento',
      if (_quincho) 'Quincho',
      if (_gimnasio) 'Gimnasio',
    ];
    final extras = extrasList.join(', ');
    final precio = double.tryParse(_precioController.text.trim()) ?? 0;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Resumen de la propiedad'),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                leading: const Icon(Icons.home_outlined),
                title: const Text('Tipo'),
                subtitle: Text(tipo),
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                leading: const Icon(Icons.location_on_outlined),
                title: const Text('Dirección'),
                subtitle:
                    Text('$direccion1${direccion2.isNotEmpty ? ', $direccion2' : ''}'),
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                leading: const Icon(Icons.map_outlined),
                title: const Text('Comuna'),
                subtitle: Text(comuna),
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                leading: const Icon(Icons.square_foot_outlined),
                title: const Text('Metros²'),
                // ignore: unnecessary_string_interpolations
                subtitle: Text('${metros.toStringAsFixed(0)}'),
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                leading: const Icon(Icons.bathroom_outlined),
                title: const Text('Baños'),
                subtitle: Text('$banos'),
              ),
              if (extras.isNotEmpty)
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  leading: const Icon(Icons.checklist_outlined),
                  title: const Text('Extras'),
                  subtitle: Text(extras),
                ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                leading: const Icon(Icons.attach_money_outlined),
                title: const Text('Precio'),
                subtitle: Text('\$${precio.toStringAsFixed(2)}'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Volver'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );

    if (result == true) {
      Navigator.of(context).pop(); // cerrar formulario diálogo
      await _submit();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Propiedad publicada correctamente')),
      );
    }
  }

  Future<void> _submit() async {
    final tipo = _tipoPropiedad;
    final direccion1 = _direccion1Controller.text.trim();
    final direccion2 = _direccion2Controller.text.trim();
    final comuna = _comuna;
    final metros = double.tryParse(_metrosController.text.trim()) ?? 0;
    final banos = _banos;
    final estacionamiento = _estacionamiento;
    final quincho = _quincho;
    final gimnasio = _gimnasio;
    final precio = double.tryParse(_precioController.text.trim()) ?? 0;

    await FirebaseFirestore.instance.collection('properties').add({
      'tipo': tipo,
      'direccion1': direccion1,
      'direccion2': direccion2,
      'comuna': comuna,
      'metros': metros,
      'banos': banos,
      'estacionamiento': estacionamiento,
      'quincho': quincho,
      'gimnasio': gimnasio,
      'precio': precio,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    _direccion1Controller.dispose();
    _direccion2Controller.dispose();
    _metrosController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Widget _buildPaso1(StateSetter setStateSB) => Column(
        children: <Widget>[
          DropdownButtonFormField<String>(
            value: _tipoPropiedad,
            decoration: const InputDecoration(
              labelText: 'Tipo de propiedad',
              border: OutlineInputBorder(),
            ),
            items: _tiposPropiedad
                .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setStateSB(() {
              _tipoPropiedad = v ?? _tipoPropiedad;
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _direccion1Controller,
            decoration: const InputDecoration(
              labelText: 'Dirección',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _direccion2Controller,
            decoration: const InputDecoration(
              labelText: 'Dirección 2 (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _comuna,
            decoration: const InputDecoration(
              labelText: 'Comuna',
              border: OutlineInputBorder(),
            ),
            items: _comunas
                .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setStateSB(() {
              _comuna = v ?? _comuna;
            }),
          ),
        ],
      );

  Widget _buildPaso2(StateSetter setStateSB) => Column(
        children: <Widget>[
          TextField(
            controller: _metrosController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Metros cuadrados',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _banos,
            decoration: const InputDecoration(
              labelText: 'Baños',
              border: OutlineInputBorder(),
            ),
            items: _banosList
                .map((b) => DropdownMenuItem<int>(value: b, child: Text(b.toString())))
                .toList(),
            onChanged: (v) => setStateSB(() {
              _banos = v ?? _banos;
            }),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Estacionamiento'),
            value: _estacionamiento,
            onChanged: (v) => setStateSB(() {
              _estacionamiento = v ?? false;
            }),
          ),
          CheckboxListTile(
            title: const Text('Quincho'),
            value: _quincho,
            onChanged: (v) => setStateSB(() {
              _quincho = v ?? false;
            }),
          ),
          CheckboxListTile(
            title: const Text('Gimnasio'),
            value: _gimnasio,
            onChanged: (v) => setStateSB(() {
              _gimnasio = v ?? false;
            }),
          ),
        ],
      );

  Widget _buildPaso3() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _precioController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Precio',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Propiedades')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('properties')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar propiedades'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No hay propiedades publicadas'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final tipo = data['tipo'] ?? '';
              final direccion1 = data['direccion1'] ?? '';
              final direccion2 = data['direccion2'] ?? '';
              final comuna = data['comuna'] ?? '';
              final precio = (data['precio'] ?? 0).toDouble();
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text('$tipo en $comuna',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 4),
                      Text('$direccion1${direccion2.isNotEmpty ? ', $direccion2' : ''}'),
                      const SizedBox(height: 4),
                      Text('Precio: \$${precio.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFormDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
