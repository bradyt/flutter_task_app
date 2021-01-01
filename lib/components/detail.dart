import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:taskc/taskc.dart';

import 'package:flutter_task_app/shared/hive_data.dart';
import 'package:flutter_task_app/shared/misc.dart';

class Detail extends StatelessWidget {
  const Detail(this.task);

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {},
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var entry in {
              'Description: ': task.description,
              'Due:         ': task.due,
              'End:         ': task.end,
              'Entry:       ': task.entry,
              'Modified:    ': task.modified,
              'Priority:    ': task.priority,
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(
                name,
                style: GoogleFonts.firaMono(),
              ),
              if (name.startsWith('Priority'))
                DropdownButton(
                    value: (value == 'null') ? '' : value,
                    items: [
                      for (var priority in ['H', 'M', 'L', ''])
                        DropdownMenuItem(
                          child: Text(priority),
                          value: priority,
                        ),
                    ],
                    onChanged: (priority) async {
                      var task = await getTask(uuid);
                      var newTask = task.copyWith(
                        priority: () => (priority == '') ? null : priority,
                      );
                      await addTask(newTask);
                    })
              else
                Container(
                  child: Text(
                    value,
                    style: GoogleFonts.firaMono(),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
