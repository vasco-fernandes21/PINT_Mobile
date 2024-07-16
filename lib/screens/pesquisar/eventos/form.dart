import 'package:flutter/material.dart';

class DynamicForm extends StatefulWidget {
  final List<Formulario> formulario;
  final Function onAlteracao;

  DynamicForm({required this.formulario, required this.onAlteracao});

  @override
  _DynamicFormState createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  Map<String, dynamic> formData = {};
  bool loading = true;
  bool openEditDialog = false;
  Formulario? editData;
  int? selectedFormIndex;
  bool openRespostasDialog = false;
  List<Resposta> respostas = [];
  Map<String, String> fieldLabelMap = {};

  @override
  void initState() {
    super.initState();
    if (widget.formulario.isNotEmpty) {
      for (var form in widget.formulario) {
        for (var field in form.campos) {
          fieldLabelMap[field.id] = field.label;
        }
      }
    }
    loading = false;
  }

  void handleChange(String id, dynamic value) {
    setState(() {
      formData[id] = value;
    });
  }

  void handleSubmit(int idFormulario) {
    handleEnviarRespostas(idFormulario);
  }

  void handleOpenEditDialog(int index) {
    setState(() {
      editData = widget.formulario[index];
      selectedFormIndex = index;
      openEditDialog = true;
    });
  }

  void handleCloseEditDialog() {
    setState(() {
      openEditDialog = false;
      selectedFormIndex = null;
      widget.onAlteracao();
    });
  }

  Future<void> handleOpenRespostasDialog(int idFormulario) async {
    // Simulando a busca de respostas
    try {
      // Aqui você deveria fazer a chamada à API para buscar as respostas
      // List<Resposta> fetchedRespostas = await api.getRespostas(idFormulario);
      setState(() {
        respostas = fetchedRespostas; // Substitua pelo resultado da API
        openRespostasDialog = true;
      });
    } catch (error) {
      print('Erro ao buscar respostas: $error');
    }
  }

  void handleCloseRespostasDialog() {
    setState(() {
      openRespostasDialog = false;
      respostas = [];
    });
  }

  String formatValue(dynamic value) {
    if (value is bool) {
      return value ? 'Sim' : 'Não';
    }
    return value.toString();
  }

  Future<void> handleEnviarRespostas(int idFormulario) async {
    // Simulando o envio de respostas
    try {
      // Aqui você deveria fazer a chamada à API para enviar as respostas
      // bool success = await api.enviarRespostas(idFormulario, formData);
      if (success) {
        print('Respostas enviadas com sucesso!');
        resetForm();
        Toast.show('Respostas enviadas com sucesso!', context, duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      } else {
        print('Erro ao enviar respostas');
        Toast.show('Erro ao enviar respostas!', context, duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    } catch (error) {
      print('Erro ao enviar respostas: $error');
      Toast.show('Erro ao enviar respostas!', context, duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  void resetForm() {
    setState(() {
      formData = {};
      widget.onAlteracao();
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: CircularProgressIndicator())
        : widget.formulario.isEmpty
            ? Center(child: Text('Carregando campos do formulário...'))
            : ListView.builder(
                itemCount: widget.formulario.length,
                itemBuilder: (context, index) {
                  final form = widget.formulario[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(form.titulo, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => handleOpenEditDialog(index),
                              ),
                            ],
                          ),
                          Text(form.textoAuxiliar),
                          ...form.campos.map((field) {
                            if (field.type == 'texto') {
                              return TextField(
                                decoration: InputDecoration(labelText: field.label, helperText: field.helperText),
                                onChanged: (value) => handleChange(field.id, value),
                                enabled: form.estado,
                                controller: TextEditingController(text: formData[field.id] ?? ''),
                              );
                            } else if (field.type == 'numero') {
                              return TextField(
                                decoration: InputDecoration(labelText: field.label, helperText: field.helperText),
                                keyboardType: TextInputType.number,
                                onChanged: (value) => handleChange(field.id, value),
                                enabled: form.estado,
                                controller: TextEditingController(text: formData[field.id] ?? ''),
                              );
                            } else if (field.type == 'checkbox') {
                              return CheckboxListTile(
                                title: Text(field.label),
                                value: formData[field.id] ?? false,
                                onChanged: (value) => handleChange(field.id, value),
                                controlAffinity: ListTileControlAffinity.leading,
                                enabled: form.estado,
                              );
                            } else if (field.type == 'select') {
                              return DropdownButtonFormField<String>(
                                decoration: InputDecoration(labelText: field.label),
                                value: formData[field.id] ?? '',
                                items: field.options.split(',').map((option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option),
                                  );
                                }).toList(),
                                onChanged: (value) => handleChange(field.id, value),
                                enabled: form.estado,
                              );
                            }
                            return SizedBox.shrink();
                          }).toList(),
                          ButtonBar(
                            children: [
                              ElevatedButton(
                                onPressed: form.estado ? () => handleSubmit(form.id) : null,
                                child: Text('Enviar'),
                              ),
                              ElevatedButton(
                                onPressed: () => handleOpenRespostasDialog(form.id),
                                child: Text('Ver Respostas'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }
}

class Formulario {
  final int id;
  final String titulo;
  final String textoAuxiliar;
  final bool estado;
  final List<Campo> campos;

  Formulario({required this.id, required this.titulo, required this.textoAuxiliar, required this.estado, required this.campos});
}

class Campo {
  final String id;
  final String label;
  final String type;
  final String helperText;
  final String options;

  Campo({required this.id, required this.label, required this.type, required this.helperText, required this.options});
}

class Resposta {
  final int id;
  final Formulario? formulario;
  final Map<String, dynamic> respostas;
  final String? utilizador;
  final DateTime data;

  Resposta({required this.id, this.formulario, required this.respostas, this.utilizador, required this.data});
}