import 'package:flutter/material.dart';
import 'package:hive_crud/Boxes.dart';
import 'package:hive_crud/Comm/getTextFormField.dart';
import 'package:hive_crud/Model/userModel.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveDBPage extends StatefulWidget {
  const HiveDBPage({Key? key}) : super(key: key);

  @override
  State<HiveDBPage> createState() => _HiveDBPageState();
}

class _HiveDBPageState extends State<HiveDBPage> {
  final _formKey = GlobalKey<FormState>();

  final conId = TextEditingController();
  final conName = TextEditingController();
  final conEmail = TextEditingController();

  @override
  void dispose() {
    Hive.close(); // Closing All Boxes

    //Hive.box('users').close();// Closing Selected Box

    super.dispose();
  }

  Future<void> addUser(String uId, String uName, String uEmail) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = UserModel()
        ..user_id = uId
        ..user_name = uName
        ..email = uEmail;

      final box = Boxes.getUsers();
      //Key Auto Increment
      box.add(user).then((value) => clearPage());
    }
  }

  Future<void> editUser(UserModel userModel) async {
    conId.text = userModel.user_id;
    conName.text = userModel.user_name;
    conEmail.text = userModel.email;

    deleteUser(userModel);

    // if you want to do with key you can use that too.

    //box.put("myKey", user);
    //final myBox = Boxes.getUsers();
    //final myUser = myBox.get("myKey");
    //myBox.values; // Access All Values
    //myBox.keys; // Access By Key
  }

  Future<void> deleteUser(UserModel userModel) async {
    userModel.delete();
  }

  clearPage() {
    conId.text = '';
    conName.text = '';
    conEmail.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Hive DB CRUD'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                genTextFormField(
                    controller: conId,
                    hintName: "User ID",
                    iconData: Icons.person),
                SizedBox(height: 10),
                genTextFormField(
                    controller: conName,
                    hintName: "User Name",
                    iconData: Icons.person_outline),
                SizedBox(height: 10),
                genTextFormField(
                    controller: conEmail,
                    textInputType: TextInputType.emailAddress,
                    hintName: "Email",
                    iconData: Icons.email),
                SizedBox(height: 10),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                            onPressed: () => addUser(
                                conId.text, conName.text, conEmail.text),
                            child: Text("Add"),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black))),
                      ),
                      SizedBox(width: 5.0),
                      Expanded(
                          child: TextButton(
                              onPressed: () => clearPage(),
                              child: Text("Clear"),
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.black))))
                    ],
                  ),
                ),
                SizedBox(
                    height: 500,
                    child: ValueListenableBuilder(
                      valueListenable: Boxes.getUsers().listenable(),
                      builder: (BuildContext context, Box box, Widget? child) {
                        final users = box.values.toList().cast<UserModel>();

                        return genContent(users);
                      },
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget genContent(List<UserModel> user) {
    if (user.isEmpty) {
      return Center(
        child: Text(
          "No Users Found",
          style: TextStyle(fontSize: 20),
        ),
      );
    } else {
      return ListView.builder(
          itemCount: user.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              color: Colors.white,
              child: ExpansionTile(
                title: Text(
                  "${user[index].user_id} (${user[index].email})",
                  maxLines: 2,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text(user[index].user_name),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                        onPressed: () => editUser(user[index]),
                        icon: Icon(
                          Icons.edit,
                          color: Colors.amber,
                        ),
                        label: Text(
                          "Edit",
                          style: TextStyle(color: Colors.amber),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => deleteUser(user[index]),
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        label: Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    ],
                  )
                ],
              ),
            );
          });
    }
  }
}
