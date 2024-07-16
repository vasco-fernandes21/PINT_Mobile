

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareOptions extends StatelessWidget {
  final String url;
  final String msg;

  ShareOptions({required this.url, required this.msg});
  
  Future<void> share(String platform) async {
    print("estou aqui");
  }

  Future<void> sendWhatsapp() async {
    String text= msg + ' ' + url;
    String textEncoded = Uri.encodeFull(text);
    String URL = 'https://wa.me/?text=$textEncoded';
    await launchUrl(Uri.parse(URL));
  }

  Future<void> sendTwitter() async {
    String text= msg + ' ' + url;
    String textEncoded = Uri.encodeFull(text);
    String URL = 'https://twitter.com/intent/tweet?text=$textEncoded';
    await launchUrl(Uri.parse(URL));
  }

Future<void> sendFacebook() async {

    String text= msg + ' ' + url;
    String textEncoded = Uri.encodeFull(text);
    String URL = 'https://www.facebook.com/sharer/sharer.php?u=$textEncoded';
    await launchUrl(Uri.parse(URL));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Partilhar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
        const SizedBox(height: 8,),
       Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                child: const Icon(Icons.copy, size: 30,),
                onTap: () { Clipboard.setData(ClipboardData(text: url));},
              ),
              const Text('Copiar'),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                  child: Image.asset(
                  'assets/images/whatsapp.png',
                  width: 30,
                  ),
                onTap: sendWhatsapp,
              ),
              const Text('WhatsApp'),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                child: Image.asset(
                  'assets/images/twitter.png',
                  width: 30,
                  ),
                onTap: sendTwitter,
              ),
              const Text('Twitter'),
            ],
          ),
        ],
      ),
      const SizedBox(height: 8,),
        ]
      ),
    );
  }
}