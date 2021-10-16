import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:health/health.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<HealthDataPoint> _healthDataList = [];
  HealthFactory health = HealthFactory();
  bool loading = false;

  List<HealthDataType> types = [
    HealthDataType.STEPS,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.DISTANCE_WALKING_RUNNING,
  ];

  Future onFetchHealthData() async {
    setState(() {
      loading = true;
    });
    if (Platform.isAndroid) {
      types.remove(HealthDataType.DISTANCE_WALKING_RUNNING);
    }
    bool accessWasGranted = await health.requestAuthorization(types);
    DateTime startDate = DateTime(2020);
    DateTime endDate = DateTime(2022);

    if (accessWasGranted) {
      try {
        List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(startDate, endDate, types);
        _healthDataList.addAll(healthData);
        _healthDataList = HealthFactory.removeDuplicates(_healthDataList);
        if (_healthDataList.isEmpty) {
          showToast("You don't have any health data");
        }
        setState(() {});
      } catch (e) {
        showToast(e);
      }
    } else {
      showToast("Access not granted");
    }
    setState(() {
      loading = false;
    });
  }

  void showToast(dynamic message) {
    Fluttertoast.showToast(
      msg: message.toString(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : _healthDataList.isNotEmpty
              ? ListView.separated(
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: _healthDataList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final data = _healthDataList[index];
                    return ListTile(
                      leading: Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      title: Text("Source: ${data.sourceName}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text("${data.dateFrom.toLocal()}"),
                          const SizedBox(height: 8),
                          Text("${data.typeString}: ${data.value} ${data.unitString}"),
                        ],
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text("Press download button to download health data"),
                ),
    );
  }
}
