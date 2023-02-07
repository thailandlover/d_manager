import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:d_manager/d_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _dManagerPlugin = DManager();
  List<Map<String, dynamic>> coreDataItems = [];

  @override
  void initState() {
    super.initState();
  }

  _getList() async {
    await _dManagerPlugin.getList().then((itemsString) {
      print(itemsString);
      if (itemsString != null) {
        setState(() {
          coreDataItems = List<Map<String, dynamic>>.from(
              jsonDecode(itemsString!).map((x) => x));
        });
      }
    });
  }

  _start() async {
    Map<String, dynamic> data = {
      "id": "205728",
      "link":
      "https://s-ed1.cloud.gcore.lu/video/m-159n/English/Animation&Family/Baby.Shark.Best.Kids.Song/S01/02.mp4",
      "fileName": "02.mp4",
      "savedDir": "77810/205728"
    };
    var list = await _dManagerPlugin.start(data);
    print(list);
  }

  _pause() async {
    Map<String, dynamic> data = {
      "id": "205728",
    };
    var list = await _dManagerPlugin.pause(data);
    print(list);
  }

  _resume() async {
    Map<String, dynamic> data = {"id": "205728", "savedDir": "77810/205728"};
    var list = await _dManagerPlugin.resume(data);
    print(list);
  }

  _cancel() async {
    Map<String, dynamic> data = {
      "id": "205728",
    };
    var list = await _dManagerPlugin.cancel(data);
    print(list);
  }

  _delete() async {
    Map<String, dynamic> data = {
      "id": "205728",
    };
    var list = await _dManagerPlugin.delete(data);
    print(list);
  }

  _retry() async {
    Map<String, dynamic> data = {"id": "205728", "savedDir": "77810/205728"};
    var list = await _dManagerPlugin.retry(data);
    print(list);
  }

  _deleteLocal() async {
    Map<String, dynamic> data = {
      "id": "205728",
    };
    var list = await _dManagerPlugin.deleteLocal(data);
    print(list);
  }

  _open() async {
    Map<String, dynamic> data = {
      "id": "205728",
    };
    var list = await _dManagerPlugin.openFile(data);
    print(list);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _start,
                    child: const Text('start'),
                  ),
                  ElevatedButton(
                    onPressed: _pause,
                    child: const Text('pause'),
                  ),
                  ElevatedButton(
                    onPressed: _resume,
                    child: const Text('resume'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _cancel,
                    child: const Text('cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _delete,
                    child: const Text('delete'),
                  ),
                  ElevatedButton(
                    onPressed: _retry,
                    child: const Text('retry'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _deleteLocal,
                    child: const Text('delete local file'),
                  ),
                  ElevatedButton(
                    onPressed: _open,
                    child: const Text('open local file'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _getList,
                child: const Text('get list'),
              ),
              Column(
                children: coreDataItems.map((value) {
                  return Text(
                      "${value['title']} \n ${value['status']} \n ${value['progress']} \n ${value['url']}\n\n\n");
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

