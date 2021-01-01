import 'package:flutter/material.dart';

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
              'Description': task.description,
              'Due': task.due,
              'End': task.end,
              'Entry': task.entry,
              'Modified': task.modified,
              'Priority': task.priority,
            }.entries)
              DetailCard(
                uuid: task.uuid,
                desc: entry.key,
                value: entry.value != null
                    ? ((entry.value is DateTime)
                        // ignore: avoid_as
                        ? '${(entry.value as DateTime).toLocal()}'
                        : '${entry.value}')
                    : 'Nil',
              ),
          ],
        ),
      ),
    );
  }
}

class DetailCard extends StatelessWidget {
  const DetailCard({this.uuid, this.desc, this.value});

  final String uuid;
  final String desc;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Card(
        elevation: 0.1,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                desc,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              if (desc == 'Priority')
                DropdownButton(
                    value: (value == 'Nil') ? '' : value,
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
                Container(padding: EdgeInsets.all(20), child: Text(value))
            ],
          ),
        ),
      ),
    );
  }
}
