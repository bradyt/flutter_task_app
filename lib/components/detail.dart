import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:taskc/taskc.dart';

import 'package:flutter_task_app/shared/hive_data.dart';
import 'package:flutter_task_app/shared/misc.dart';

class Detail extends StatelessWidget {
  const Detail(this.uuid);

  final String uuid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(uuid.split('-').first),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              var task = await getTask(uuid);
              var newTask = task.copyWith(
                modified: () => DateTime.now().toUtc(),
                status: () => 'deleted',
              );
              await addTask(newTask);
            },
          ),
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () async {
              var task = await getTask(uuid);
              var newTask = task.copyWith(
                modified: () => DateTime.now().toUtc(),
                status: () => 'completed',
              );
              await addTask(newTask);
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: getDataBoxListenable(),
        builder: (context, box, _) {
          var task = Task.fromJson(box.get(uuid));

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var entry in {
                  'description: ': task.description,
                  'status:      ': task.status,
                  'entry:       ': task.entry,
                  'modified:    ': task.modified,
                  'end:         ': task.end,
                  'due:         ': task.due,
                  'priority:    ': task.priority,
                  'tags:        ': task.tags,
                }.entries)
                  DetailCard(
                    uuid: task.uuid,
                    name: entry.key,
                    value: entry.value != null
                        ? ((entry.value is DateTime)
                            // ignore: avoid_as
                            ? '${(entry.value as DateTime).toLocal()}'
                            : '${entry.value}')
                        : 'null',
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DetailCard extends StatelessWidget {
  const DetailCard({this.uuid, this.name, this.value});

  final String uuid;
  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Card(
        elevation: 0.1,
        child: InkWell(
          onLongPress: (name.startsWith('due'))
              ? () async {
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      scrollable: true,
                      content: Text('Clear due date?'),
                      actions: [
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        ElevatedButton(
                          child: Text('Clear'),
                          onPressed: () async {
                            var task = await getTask(uuid);
                            var newTask = task.copyWith(
                              modified: () => DateTime.now().toUtc(),
                              due: () => null,
                            );
                            await addTask(newTask);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                }
              : null,
          onTap: (name.startsWith('due'))
              ? () async {
                  var now =
                      DateTime.tryParse(value)?.toLocal() ?? DateTime.now();

                  var date = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2037),
                  );
                  if (date != null) {
                    var time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(now),
                    );
                    if (time != null) {
                      var due = date.add(
                        Duration(
                          hours: time.hour,
                          minutes: time.minute,
                        ),
                      );
                      var task = await getTask(uuid);
                      var newTask = task.copyWith(
                        modified: () => DateTime.now().toUtc(),
                        due: () => due.toUtc(),
                      );
                      await addTask(newTask);
                    }
                  }
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  name,
                  style: GoogleFonts.firaMono(),
                ),
                if (name.startsWith('priority'))
                  DropdownButton(
                      value: (value == 'null') ? '' : value,
                      items: [
                        for (var priority in ['H', 'M', 'L', ''])
                          DropdownMenuItem(
                            child: Text(priority),
                            value: priority,
                            onTap: null,
                          ),
                      ],
                      onChanged: (priority) async {
                        var task = await getTask(uuid);
                        var newTask = task.copyWith(
                          modified: () => DateTime.now().toUtc(),
                          priority: () => (priority == '') ? null : priority,
                        );
                        await addTask(newTask);
                      })
                else
                  Text(
                    value,
                    style: GoogleFonts.firaMono(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
