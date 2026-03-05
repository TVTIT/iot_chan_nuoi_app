import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../model/sensors_model.dart';
import '../main.dart';

class ListNodesScreen extends StatefulWidget {
  const ListNodesScreen({super.key});

  @override
  State<ListNodesScreen> createState() => _ListNodesScreenState();
}

class _ListNodesScreenState extends State<ListNodesScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref(
    'farm_monitor',
  );

  //theo dõi có mạng hay không
  final ValueNotifier<bool> _isOnline = ValueNotifier(true);
  Timer? delayOfflineTimer;

  late StreamSubscription<List<ConnectivityResult>> _networkSubscription;

  @override
  void initState() {
    super.initState();
    _khoiTaoLangNgheMang();
  }

  void _khoiTaoLangNgheMang() {
    _networkSubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      _isOnline.value = !results.contains(ConnectivityResult.none);

      if (!_isOnline.value) {
        delayOfflineTimer?.cancel();
        delayOfflineTimer = Timer(const Duration(seconds: 1), () {
          if (mounted && !_isOnline.value) {
            _lostConnectionDialogBuilder(context);
          }
        });
      } else {
        delayOfflineTimer?.cancel();
      }
    });
  }

  Future<void> _lostConnectionDialogBuilder(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mất kết nối'),
          content: const Text('Mất kết nối Internet. Vui lòng kiểm tra lại'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _networkSubscription.cancel();
    delayOfflineTimer?.cancel();
    _isOnline.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Danh sách các Node"),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isOnline,
            builder: (context, isOnline, child) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Text(
                      isOnline ? "Online" : "Offline",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 8),

                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline ? Colors.green : Colors.red,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          if (isOnline)
                            //phát sáng
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.6),
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder(
        stream: _databaseRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            //convert json
            final rawData =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            List<FarmNode> sensors = [];
            rawData.forEach((key, value) {
              final node = FarmNode.fromEntry(key.toString(), value as Map);
              sensors.add(node);
            });

            //sắp xếp node theo id
            sensors.sort((a, b) => a.id.compareTo(b.id));

            return ListView.builder(
              itemCount: sensors.length,
              itemBuilder: (context, index) {
                final sensor = sensors[index];
                checkAndShowNotification(sensor);
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      "Trạm: ${sensor.id}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nhiệt độ: ${sensor.temperature.toStringAsFixed(2)} °C",
                        ),
                        Text("Độ ẩm: ${sensor.humidity.toStringAsFixed(2)} %"),
                        Text("Khí Gas: ${sensor.gasCh4}"),
                        Text("Tín hiệu (RSSI): ${sensor.rssi}"),
                      ],
                    ),
                    trailing: _buildStatusIcon(sensor.temperature),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<void> checkAndShowNotification(FarmNode node) async {
    if (node.temperature > 40 &&
        node.temperature < 100) {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'iot_chan_nuoi_alert',
            'Cảnh báo nhiệt độ quá ngưỡng',
            channelDescription:
                'Nhận cảnh báo khẩn cấp khi nhiệt độ vượt ngưỡng an toàn',
            importance: Importance.max,
            priority: Priority.high,
            icon: 'ic_stat_sanslab_logo',
            ticker: 'Có cảnh báo chuồng chăn nuôi',
          );
      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );
      return flutterLocalNotificationsPlugin.show(
        id: 0,
        title: 'Cảnh báo nhiệt độ vượt ngưỡng',
        body:
            'Nhiệt độ hiện tại ở node ${node.id} '
            'đang ở mức cao: ${node.temperature} °C',
        notificationDetails: notificationDetails,
        payload: 'item x',
      );
    }
  }

  Widget _buildStatusIcon(double temp) {
    if (temp > 40 && temp < 100) {
      return const Icon(Icons.warning, color: Colors.red);
    }
    return const Icon(Icons.check_circle, color: Colors.green);
  }
}
