class FarmNode {
  final String id;
  final double gasCh4;
  final double gasMq135;
  final double humidity;
  final double lux;
  final double pressure;
  final int rssi;
  final double temperature;
  final int timestamp;

  FarmNode({
    required this.id,
    required this.gasCh4,
    required this.gasMq135,
    required this.humidity,
    required this.lux,
    required this.pressure,
    required this.rssi,
    required this.temperature,
    required this.timestamp,
  });

  factory FarmNode.fromEntry(String key, Map<dynamic, dynamic> value) {
    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is int) return val.toDouble();
      if (val is double) return val;
      return 0.0;
    }

    int toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return 0;
    }

    return FarmNode(
      id: key,
      gasCh4: toDouble(value['gas_ch4']),
      gasMq135: toDouble(value['gas_mq135']),
      humidity: toDouble(value['humidity']),
      lux: toDouble(value['lux']),
      pressure: toDouble(value['pressure']),
      rssi: toInt(value['rssi']),
      temperature: toDouble(value['temperature']),
      timestamp: toInt(value['timestamp']),
    );
  }
}