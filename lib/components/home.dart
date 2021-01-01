import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task_app/components/detail.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info/package_info.dart';
import 'package:taskc/taskc.dart';

import 'package:flutter_task_app/shared/errors/taskd_exception.dart';
import 'package:flutter_task_app/shared/hive_data.dart';
import 'package:flutter_task_app/shared/misc.dart';

class Home extends StatelessWidget {
  final String title =
      'task${kDebugMode ? ' \u{1f41e}' : (kProfileMode ? ' \u{1f680}' : '')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (kDebugMode)
            IconButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    scrollable: true,
                    title: Text('Reset database'),
                    content: Text(
                      // ignore: lines_longer_than_80_chars
                      'This will remove your local tasks and configuration. Are you sure?',
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        child: Text('Reset'),
                        onPressed: () async {
                          await resetDatabase();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.warning),
            ),
          Builder(
            builder: (context) => IconButton(
                onPressed: () async {
                  try {
                    var header = await syncData();
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${header['code']}: ${header['status']}'),
                      ),
                    );
                  } on TaskdException catch (e, trace) {
                    print(e);
                    var hasTrace = '$trace'.isNotEmpty;
                    if (hasTrace) {
                      print(trace);
                    }
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        scrollable: true,
                        title: Text('${e.runtimeType}'),
                        content: Column(
                          children: [
                            SelectableText(
                              '${e.header['code']}: ${e.header['status']}',
                            ),
                            // Divider(),
                            // SelectableText(
                            //   'Compare: https://taskwarrior.org/docs/design/protocol.html',
                            // ),
                          ],
                        ),
                      ),
                    );
                  } on Exception catch (e, trace) {
                    print(e);
                    var hasTrace = '$trace'.isNotEmpty;
                    if (hasTrace) {
                      print(trace);
                    }
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        scrollable: true,
                        title: Text('${e.runtimeType}'),
                        content: Column(
                          children: [
                            SelectableText('$e'),
                            if (hasTrace) ...[
                              ExpansionTile(
                                title: Text('StackTrace'),
                                children: [
                                  SelectableText('$trace'),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  }
                },
                icon: Icon(Icons.sync)),
          ),
          IconButton(
              onPressed: () async {
                var packageInfo = await PackageInfo.fromPlatform();
                showAboutDialog(
                    context: context,
                    applicationName: packageInfo.appName,
                    applicationVersion: packageInfo.version);
              },
              icon: Icon(Icons.info)),
          IconButton(
            icon: Icon(
              Icons.settings,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/config');
            },
          )
        ],
        title: Text(title),
      ),
      body: ValueListenableBuilder(
        valueListenable: getDataBoxListenable(),
        builder: (context, box, _) {
          var tasks = box
              .toMap()
              .map((key, value) => MapEntry(key, Task.fromJson(value)))
              .entries
              .where((entry) => entry.value.status == 'pending')
              .toList()
                ..sort((a, b) {
                  if (urgency(a.value) > urgency(b.value)) {
                    return -1;
                  } else if (urgency(a.value) == urgency(b.value)) {
                    return 0;
                  } else {
                    return 1;
                  }
                });

          return Scrollbar(
            child: Container(
              margin: EdgeInsets.all(5),
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (buildContext, i) {
                  return TodoCard(task: tasks.elementAt(i).value);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return TaskForm();
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class TodoCard extends StatelessWidget {
  const TodoCard({@required this.task});

  final Task task;

  static final titleStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (ctx) => Detail(task)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text.rich(
                            TextSpan(
                              style: GoogleFonts.firaMono(),
                              children: [
                                TextSpan(
                                  text: '/',
                                  style: TextStyle(
                                    color: (Theme.of(context).brightness ==
                                            Brightness.dark)
                                        ? Color(0xffa9a9a9)
                                        : Color(0xffd3d3d3),
                                  ),
                                ),
                                TextSpan(
                                  text: task.description,
                                ),
                                TextSpan(
                                  text: '/',
                                  style: TextStyle(
                                    color: (Theme.of(context).brightness ==
                                            Brightness.dark)
                                        ? Color(0xffa9a9a9)
                                        : Color(0xffd3d3d3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${age(task.entry)} ${task.tags}',
                        ),
                      ),
                      Text(
                        '${urgency(task)}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskForm extends StatefulWidget {
  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final TextEditingController _taskNameController =
      TextEditingController(text: '');

  Future<void> _addData(context) async {
    var task = generateNewTask(_taskNameController.text);
    await addTask(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Description', style: Theme.of(context).textTheme.headline5),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: TextFormField(controller: _taskNameController),
            ),
            SizedBox(height: 20),
            RaisedButton.icon(
              onPressed: () => _addData(context),
              label: Text('Add'),
              icon: Icon(Icons.add),
            )
          ],
        ),
      ),
    );
  }
}
