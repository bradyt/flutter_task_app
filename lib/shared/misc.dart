import 'dart:convert';
import 'dart:io';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter_task_app/shared/hive_data.dart';
import 'package:hive/hive.dart';
import 'package:taskc/taskc.dart';
import 'package:uuid/uuid.dart';

Future<String> getFileFromDialog() async {
  FileInfo fi;
  File f;
  String data = await FilePickerWritable().openFile((fileInfo, file) async {
    fi = fileInfo;
    f = file;
    return await f.readAsString();
  });
  if (fi == null)
    return null;
  else {
    return data;
  }
}

final String server = "inthe.am";
final int port = 53589;
final String cred = "inthe_am/sauravk865/14d86820-40db-4291-9725-ea91573285fc";

Task generateNewTask(String desc) {
  var time = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  return Task(
      status: 'pending',
      uuid: Uuid().v1(),
      entry: time,
      description: desc,
      modified: time,
      priority: '0');
}

Future<void> syncData({String task}) async {
  try {
    var box = Hive.box('box');
    var userKey = await readFileFromBoxBox('userKey');
    var payload;
    if (task != null)
      payload = Payload(tasks: <Task>[generateNewTask(task)], userKey: userKey);
    var connection = Connection(
        address: server,
        port: port,
        context: SecurityContext()
          ..useCertificateChainBytes(utf8.encode(box.get('2')))
          ..usePrivateKeyBytes(utf8.encode(box.get('1'))),
        onBadCertificate: (_) => true);
    var credentials = Credentials.fromString(cred);
    var response = await synchronize(
        connection: connection, credentials: credentials, payload: payload);
    print(response.header);
    await saveFileToBoxBox(name: 'userKey', data: response.payload.userKey);
    for (var task in response.payload.tasks) {
      print(task.description);
    }
    if (task == null) {
      await saveFileToDataBox(
          name: 'todos',
          data:
              response.payload.tasks.map((task) => task.description).toList());
    }
  } on Exception catch (e) {
    print(e);
  }
}
