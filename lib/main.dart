import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

/// Mock data for locations and weather
final Map<String, Map<String, dynamic>> locationData = {
  'New York, USA': {
    'offset': -5.0,
    'country': 'USA',
    'capital': 'Washington, D.C.',
    'weather': {
      'temperature': 15,
      'condition': 'Cloudy',
      'humidity': 70,
      'windSpeed': 10,
      'icon': Icons.cloud,
    },
  },
  'London, UK': {
    'offset': 0.0,
    'country': 'UK',
    'capital': 'London',
    'weather': {
      'temperature': 10,
      'condition': 'Rainy',
      'humidity': 85,
      'windSpeed': 15,
      'icon': Icons.umbrella,
    },
  },
  'Tokyo, Japan': {
    'offset': 9.0,
    'country': 'Japan',
    'capital': 'Tokyo',
    'weather': {
      'temperature': 20,
      'condition': 'Sunny',
      'humidity': 60,
      'windSpeed': 5,
      'icon': Icons.wb_sunny,
    },
  },
  'Sydney, Australia': {
    'offset': 10.0,
    'country': 'Australia',
    'capital': 'Canberra',
    'weather': {
      'temperature': 25,
      'condition': 'Partly Cloudy',
      'humidity': 65,
      'windSpeed': 12,
      'icon': Icons.cloud_queue,
    },
  },
  'Paris, France': {
    'offset': 1.0,
    'country': 'France',
    'capital': 'Paris',
    'weather': {
      'temperature': 18,
      'condition': 'Overcast',
      'humidity': 75,
      'windSpeed': 8,
      'icon': Icons.cloud,
    },
  },
};

void main() => runApp(const WorldTimeApp());

class WorldTimeApp extends StatelessWidget {
  const WorldTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Time & Weather',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const WorldTimeHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WorldTimeHome extends StatefulWidget {
  const WorldTimeHome({super.key});

  @override
  State<WorldTimeHome> createState() => _WorldTimeHomeState();
}

class _WorldTimeHomeState extends State<WorldTimeHome> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedLocation;
  DateTime? _locationDateTime;
  Timer? _timer;
  Map<String, dynamic>? _weather;

  void _updateLocation(String input) {
    final place = locationData[input.trim()];
    if (place != null) {
      final nowUtc = DateTime.now().toUtc();
      final offset = place['offset'] as double;
      _locationDateTime = nowUtc.add(
        Duration(
          hours: offset.truncate(),
          minutes: ((offset - offset.truncate()) * 60).round(),
        ),
      );
      _weather = place['weather'] as Map<String, dynamic>;
      _selectedLocation = input;

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(
          () => _locationDateTime = _locationDateTime!.add(
            const Duration(seconds: 1),
          ),
        );
      });
    } else {
      _locationDateTime = null;
      _weather = null;
      _selectedLocation = input;
      _timer?.cancel();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Global Time & Weather')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter City, Country',
                border: OutlineInputBorder(),
              ),
              onSubmitted: _updateLocation,
            ),
            const SizedBox(height: 24),
            if (_locationDateTime != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Time Info for $_selectedLocation',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Country: ${locationData[_selectedLocation]!['country']}',
                      ),
                      Text(
                        'Capital: ${locationData[_selectedLocation]!['capital']}',
                      ),
                      Text(
                        'Date: ${_locationDateTime!.day}/${_locationDateTime!.month}/${_locationDateTime!.year}',
                      ),
                      Text(
                        'Day: ${['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][(_locationDateTime!.weekday - 1) % 7]}',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AnalogClockWidget(time: _locationDateTime!),
                          DigitalClockWidget(time: _locationDateTime!),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_weather != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weather Info',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(_weather!['icon'] as IconData, size: 40),
                            const SizedBox(width: 10),
                            Text(
                              '${_weather!['temperature']}°C',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        Text('Condition: ${_weather!['condition']}'),
                        Text('Humidity: ${_weather!['humidity']}%'),
                        Text('Wind Speed: ${_weather!['windSpeed']} km/h'),
                      ],
                    ),
                  ),
                ),
            ] else if (_selectedLocation != null &&
                _selectedLocation!.isNotEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Location not found",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DigitalClockWidget extends StatelessWidget {
  final DateTime time;
  const DigitalClockWidget({required this.time, super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 120,
    alignment: Alignment.center,
    child: Text(
      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}",
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
  );
}

class AnalogClockWidget extends StatelessWidget {
  final DateTime time;
  const AnalogClockWidget({required this.time, super.key});

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: AnalogClockPainter(time),
    size: const Size(120, 120),
  );
}

class AnalogClockPainter extends CustomPainter {
  final DateTime time;
  AnalogClockPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Clock outline
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.blueGrey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Hour hand
    final hourAngle = ((time.hour % 12 + time.minute / 60.0) * 30) * pi / 180;
    canvas.drawLine(
      center,
      Offset(
        center.dx + 0.5 * radius * sin(hourAngle),
        center.dy - 0.5 * radius * cos(hourAngle),
      ),
      Paint()
        ..color = Colors.indigo
        ..strokeWidth = 6,
    );

    // Minute hand
    final minuteAngle = ((time.minute + time.second / 60.0) * 6) * pi / 180;
    canvas.drawLine(
      center,
      Offset(
        center.dx + 0.8 * radius * sin(minuteAngle),
        center.dy - 0.8 * radius * cos(minuteAngle),
      ),
      Paint()
        ..color = Colors.green
        ..strokeWidth = 4,
    );

    // Second hand
    final secondAngle = (time.second * 6) * pi / 180;
    canvas.drawLine(
      center,
      Offset(
        center.dx + 0.9 * radius * sin(secondAngle),
        center.dy - 0.9 * radius * cos(secondAngle),
      ),
      Paint()
        ..color = Colors.red
        ..strokeWidth = 2,
    );

    // Center dot
    canvas.drawCircle(center, 6, Paint()..color = Colors.amber);

    // Hour markers
    for (int i = 0; i < 12; i++) {
      final angle = i * 30 * pi / 180;
      canvas.drawLine(
        Offset(
          center.dx + radius * sin(angle),
          center.dy - radius * cos(angle),
        ),
        Offset(
          center.dx + (radius - 10) * sin(angle),
          center.dy - (radius - 10) * cos(angle),
        ),
        Paint()
          ..color = Colors.blueGrey
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AnalogClockPainter oldDelegate) => true;
}
