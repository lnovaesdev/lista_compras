// No pubscep.yaml em depencencias acrescentar: http: ^0.13.3
// depois rode no terminal: flutter pub get
// Como estamos trabalhando com Api externa, execute o APP
// com o comando abaixo:
// Veja no pubspec.yaml se você tem a dependencia:
//  cupertino_icons: ^1.0.2
//  http: ^1.2.0
// flutter run --web-browser-flag "--disable-web-security"
// Se não desabilitar a segurança, não vai exibir os dados. Só no celular
// por causa do navegador
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.black,
          scaffoldBackgroundColor: Color.fromARGB(255, 214, 220, 234),
          iconTheme: IconThemeData(color: Colors.white)),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> dataList = [];

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('https://professorcelso.com.br/api_compras/getdata.php'),
      );

      if (response.statusCode == 200) {
        setState(() {
          dataList = List<Map<String, dynamic>>.from(
            json.decode(response.body),
          );
        });
      } else {
        throw Exception('Falha em ler');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> updateRecord(String id) async {
    try {
      final response = await http.post(
        Uri.parse('https://professorcelso.com.br/api_compras/updatedata.php'),
        body: {
          'id': id,
          'comprado': '1', // Defina o valor '1' para indicar que foi comprado
        },
      );
      if (response.statusCode == 200) {
        fetchData();
      } else {
        debugPrint('Erro ao atualizar registro: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro: $e');
    }
  }

  Future<void> addRecord(String produto, String qtde) async {
    try {
      final response = await http.post(
        Uri.parse('https://professorcelso.com.br/api_compras/adddata.php'),
        body: {
          'produto': produto,
          'qtde': qtde,
        },
      );

      if (response.statusCode == 200) {
        fetchData();
      } else {
        debugPrint('Erro ao adicionar registro: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> showEditRecordDialog(
      String id, String produto, String qtde) async {
    final TextEditingController produtoController =
        TextEditingController(text: produto);
    final TextEditingController qtdeController =
        TextEditingController(text: qtde);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Produto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: produtoController,
                decoration: const InputDecoration(labelText: 'Produto'),
              ),
              TextField(
                controller: qtdeController,
                decoration: const InputDecoration(labelText: 'Qtde'),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                final produto = produtoController.text;
                final qtde = qtdeController.text;

                if (produto.isNotEmpty && qtde.isNotEmpty) {
                  if (id.isNotEmpty) {
                    await editRecord(id, produto, qtde);
                  } else {
                    await addRecord(produto, qtde);
                  }
                }

                Navigator.of(context).pop();
              },
              child: const Text('Salvar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showAddRecordDialog(
      String id, String produto, String qtde) async {
    final TextEditingController produtoController =
        TextEditingController(text: produto);
    final TextEditingController qtdeController =
        TextEditingController(text: qtde);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Produto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: produtoController,
                decoration: const InputDecoration(labelText: 'Produto'),
              ),
              TextField(
                controller: qtdeController,
                decoration: const InputDecoration(labelText: 'Qtde'),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                final produto = produtoController.text;
                final qtde = qtdeController.text;

                if (produto.isNotEmpty && qtde.isNotEmpty) {
                  if (id.isNotEmpty) {
                    await editRecord(id, produto, qtde);
                  } else {
                    await addRecord(produto, qtde);
                  }
                }

                Navigator.of(context).pop();
              },
              child: const Text('Salvar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> editRecord(String id, String produto, String qtde) async {
    try {
      final response = await http.post(
        Uri.parse('https://professorcelso.com.br/api_compras/editdata.php'),
        body: {
          'id': id,
          'produto': produto,
          'qtde': qtde,
        },
      );

      if (response.statusCode == 200) {
        fetchData();
      } else {
        debugPrint('Erro ao atualizar registro: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro: $e');
    }
  }

  Future<void> deleteAllRecords() async {
    // Exibe um diálogo de confirmação
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: const Text(
              'Tem certeza de que deseja excluir todos os registros?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirma a exclusão
              },
              child: const Text('Sim'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancela a exclusão
              },
              child: const Text('Não'),
            ),
          ],
        );
      },
    );

    // Se o usuário confirmar a exclusão, prossegue com a exclusão dos registros
    if (confirm == true) {
      try {
        final response = await http.delete(
          Uri.parse('https://professorcelso.com.br/api_compras/deleteall.php'),
        );

        if (response.statusCode == 200) {
          fetchData();
        } else {
          debugPrint(
              'Erro ao excluir todos os registros: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Erro: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Compras'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              deleteAllRecords();
            },
          ),
        ],
      ),
      body: dataList.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (BuildContext context, int index) {
                final compras = dataList[index];
                final bool comprado = compras['comprado'] == '1';

                return ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(
                    'Produto: ${compras['produto']}',
                    style: comprado
                        ? TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.red,
                          )
                        : TextStyle(),
                  ),
                  subtitle: Text('Qtde: ${compras['qtde']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons
                        .shopping_cart), // Ícone para indicar que foi comprado]
                    color: Color.fromARGB(255, 49, 28, 120),
                    onPressed: () {
                      updateRecord(compras['id']);
                    },
                  ),
                  onTap: () {
                    showEditRecordDialog(
                      compras['id'],
                      compras['produto'],
                      compras['qtde'],
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddRecordDialog('', '', '');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
