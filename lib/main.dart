import 'package:flutter/material.dart';
import 'database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.initDB();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController classController = TextEditingController();

  List<Map<String, dynamic>> records = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final data = await DatabaseHelper.instance.readData();
    setState(() => records = data);
  }

  Future<void> insertData() async {
    await DatabaseHelper.instance.insertData({
      'username': usernameController.text,
      'age': ageController.text,
      'class': classController.text,
    });
    fetchData();
    clearFields();
  }

  void clearFields() {
    usernameController.clear();
    ageController.clear();
    classController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SQLite CRUD App")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: "Age"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: classController,
              decoration: InputDecoration(labelText: "Class"),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: insertData,
              child: Text("Insert Data"),
            ),

            SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final item = records[index];

                  return Card(
                    child: ListTile(
                      title: Text(item['username']),
                      subtitle: Text(
                        "Age: ${item['age']} | Class: ${item['class']}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // UPDATE BUTTON
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              usernameController.text = item['username'];
                              ageController.text = item['age'];
                              classController.text = item['class'];

                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text("Update Record"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: usernameController,
                                        decoration:
                                        InputDecoration(labelText: "Username"),
                                      ),
                                      TextField(
                                        controller: ageController,
                                        decoration:
                                        InputDecoration(labelText: "Age"),
                                      ),
                                      TextField(
                                        controller: classController,
                                        decoration:
                                        InputDecoration(labelText: "Class"),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        await DatabaseHelper.instance.updateData({
                                          'id': item['id'],
                                          'username': usernameController.text,
                                          'age': ageController.text,
                                          'class': classController.text,
                                        });
                                        Navigator.pop(context);
                                        fetchData();
                                      },
                                      child: Text("Update"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // DELETE BUTTON
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await DatabaseHelper.instance.deleteData(item['id']);
                              fetchData();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
