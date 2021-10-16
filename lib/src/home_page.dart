import 'dart:io';

import 'package:flutter/material.dart';
import 'package:health/health.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<HealthDataPoint> _healthDataList = [];
  HealthFactory health = HealthFactory();

  List<HealthDataType> types = [
    HealthDataType.STEPS,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.DISTANCE_WALKING_RUNNING,
  ];

  Future onFetchHealthData() async {
    if (Platform.isAndroid) {
      types.remove(HealthDataType.DISTANCE_WALKING_RUNNING);
    }
    bool accessWasGranted = await health.requestAuthorization(types);
    DateTime startDate = DateTime(2020);
    DateTime endDate = DateTime(2022);

    if (accessWasGranted) {
      print("Access granted");
      try {
        List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(startDate, endDate, types);
        print(healthData.length);
        _healthDataList.addAll(healthData);
        _healthDataList = HealthFactory.removeDuplicates(_healthDataList);
        setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      print("Access not granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Sokapheap"),
        actions: [
          IconButton(
            onPressed: onFetchHealthData,
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: _healthDataList.isNotEmpty
          ? Column(
              children: [
                for (var data in _healthDataList)
                  ListTile(
                    title: Text("Source: ${data.sourceName}"),
                    subtitle: Text("${data.typeString}: ${data.value} ${data.unitString}"),
                  ),
              ],
            )
          : const Center(
              child: Text("Press download button to download health data"),
            ),
    );
  }
}
