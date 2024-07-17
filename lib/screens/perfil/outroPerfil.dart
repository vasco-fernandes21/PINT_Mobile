import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pint/models/utilizador.dart';
import 'package:pint/navbar.dart';
import 'package:pint/utils/fetch_functions.dart';

class OutroPerfilPage extends StatefulWidget {
  final int userId, postoID;

  OutroPerfilPage({required this.userId, required this.postoID});

  @override
  _OutroPerfilPageState createState() => _OutroPerfilPageState();
}

class _OutroPerfilPageState extends State<OutroPerfilPage> {
  Utilizador? userProfile;
  bool isLoading = true;

    @override
  void initState() {
    super.initState();
    loadUser();
  }

    void loadUser() async {
      try {
      final fetchedUser = await fetchUtilizador(widget.userId);
      setState(() {
        userProfile = fetchedUser;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ver Perfil'),
      ),
      body: isLoading
      ? const Center(child: CircularProgressIndicator(),)
      : SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: buildUserAvatar(userProfile?.foto, userProfile?.idGoogle, userProfile?.idFacebook)      
                    ),
                    ),
              const SizedBox(height: 20),
              AutoSizeText(
                userProfile!.nome,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
              if (userProfile!.email != null)
                Text(
                  userProfile!.email!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(height: 20),
             
              if (userProfile!.localidade != null)
                ListTile(
                  title: RichText(
                    text: TextSpan(
                      text: 'Localidade: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: userProfile!.localidade!,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (userProfile!.telemovel != null)
                ListTile(
                  title: RichText(
                    text: TextSpan(
                      text: 'Telemóvel: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: userProfile!.telemovel!,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (userProfile!.cargo != null)
                ListTile(
                  title: RichText(
                    text: TextSpan(
                      text: 'Cargo: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: userProfile!.cargo!,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(postoID: widget.postoID, index: 1),
    );
  }
}