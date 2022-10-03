import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contatos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Contatos'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final number = TextEditingController();

  Future<bool> verifyContact() async {
    List<Contact> contacts = await FlutterContacts.getContacts();
    return contacts.any((contact) {
      return contact.displayName == '${firstName.text} ${lastName.text}' ||
          contact.phones == [Phone(number.text)];
    });
  }

  void createNewContact({
    required TextEditingController firstName,
    required TextEditingController lastName,
    required TextEditingController number,
  }) async {
    if (await Permission.contacts.request().isGranted) {
      if (!(await verifyContact())) {
        final newContact = Contact()
          ..name.first = firstName.text
          ..name.last = lastName.text
          ..phones = [Phone(number.text)];

        await newContact.insert();
      } else {
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Atenção'),
            content: Text('Esse contato já existe'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome'),
                controller: firstName,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Sobrenome'),
                controller: lastName,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Número'),
                controller: number,
                keyboardType: TextInputType.number,
                inputFormatters: [TextInputMask(mask: '(99) 9 9999-9999')],
              ),
              TextButton(
                onPressed: () => createNewContact(
                  firstName: firstName,
                  lastName: lastName,
                  number: number,
                ),
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
