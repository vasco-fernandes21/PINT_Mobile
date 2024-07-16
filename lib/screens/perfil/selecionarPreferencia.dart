import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pint/api/UtilizadorAPI.dart';
import 'package:pint/models/area.dart';
import 'package:pint/models/subarea.dart';
import 'package:pint/models/utilizador.dart';
import 'package:pint/navbar.dart';
import 'package:pint/screens/perfil/meuperfil.dart';
import 'package:pint/utils/colors.dart';
import 'package:pint/utils/fetch_functions.dart';
import 'package:pint/utils/form_validators.dart';
import 'package:pint/widgets/custom_button.dart';
import 'package:pint/widgets/dropdown_input.dart';
import 'package:pint/widgets/verifica_conexao.dart';


class PreferenciasPage extends StatefulWidget {
  final int postoID;
  final Utilizador? myUser;

  PreferenciasPage({required this.myUser, required this.postoID});

  @override
  _PreferenciasPageState createState() => _PreferenciasPageState();
}

class _PreferenciasPageState extends State<PreferenciasPage> {
  List<Area> areas = [];
  List<Subarea> subareas = [];
  int? selectedAreaId;
  int? selectedSubareaId;
  bool isLoading = true;
  bool isServerOff = false;

  @override
  void initState() {
    super.initState();
    loadAreas();
    loadUserPreferences();
  }

  void loadUserPreferences() {
    setState(() {
      selectedAreaId = widget.myUser!.idAreaPreferencia;
      if(selectedAreaId != null){
        loadSubareas(selectedAreaId!);
        selectedSubareaId = widget.myUser!.idSubareaPreferencia;
      }
    });
  }

  void loadAreas() async {
    try {
    final fetchedAreas = await fetchAreas(context);
    setState(() {
      areas = fetchedAreas;
      isLoading = false;
    });
    } catch (e) {
      setState(() {
        isLoading = false;
        isServerOff = true;
      });
    }

  }

  void loadSubareas(int areaId) async {
    try {
    final fetchedSubareas = await fetchSubareas(context, areaId);
    setState(() {
      subareas = fetchedSubareas;
    }); 
    } catch (e) {
      setState(() {
        isLoading = false;
        isServerOff = true;
      });
    }

  }

  Future<void> savePreferences() async {
    if(selectedAreaId == null){
           Fluttertoast.showToast(
            msg: 'Erro ao guardar preferência. Selecione uma área',
            fontSize: 12,
            backgroundColor: errorColor);
            return;
    }

    final api = UtilizadorAPI();
    final response = await api.editarPreferenciaUtilizador(
      widget.myUser!.id,
      selectedAreaId,
      selectedSubareaId,
    );

    if (response.statusCode == 200) {
      // Preferências salvas com sucesso
      Fluttertoast.showToast(
          msg: 'Preferência guardada com sucesso',
          backgroundColor: successColor,
          fontSize: 12);
        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PerfilPage(
            postoID: widget.postoID,
          ),
        ),
      );
    } else {
      // Ocorreu um erro ao salvar as preferências
     Fluttertoast.showToast(
            msg: 'Erro ao guardar preferência',
            fontSize: 12,
            backgroundColor: errorColor);
    }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Preferência'),
      ),
      body: VerificaConexao(isLoading: isLoading, isServerOff: isServerOff, child: 
       Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownInput<int>(
                    value: selectedAreaId,
                    items: areas.map((area) {
                      return DropdownMenuItem<int>(
                        value: area.id,
                        child: Text(
                          area.nome,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedAreaId = newValue;
                        selectedSubareaId = null;
                        subareas = [];
                        if (newValue != null) {
                          loadSubareas(newValue);
                        }
                      });
                    },
                    label: 'Área',
                    validator: (value) => validateNotEmpty(
                      value?.toString(),
                      errorMessage: 'Por favor, selecione uma área',
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownInput<int>(
                    value: selectedSubareaId,
                    items: subareas.map((subarea) {
                      return DropdownMenuItem<int>(
                        value: subarea.id,
                        child: Text(
                          subarea.nome,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedSubareaId = newValue;
                      });
                    },
                    label: 'Subárea',
                  ),
                  const SizedBox(height: 30),
                  CustomButton(onPressed: savePreferences, title: 'Guardar')
                ],
              ),
            ),
          ),
            bottomNavigationBar: NavBar(postoID: widget.postoID, index: 4),
    );
  }
}
