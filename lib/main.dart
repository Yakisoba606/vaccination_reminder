import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vaccination Reminder',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> vaccinations = [];

  @override
  void initState() {
    super.initState();
    loadVaccinations();
  }

  Future<void> loadVaccinations() async {
    final data = await DatabaseHelper.getVaccinations();

    setState(() {
      vaccinations = data;
    });
  }

  Future<void> deleteRecord(int id) async {
    await DatabaseHelper.deleteVaccination(id);
    loadVaccinations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vaccination Reminder"),
      ),
      body: vaccinations.isEmpty
          ? const Center(
              child: Text("No records yet"),
            )
          : ListView.builder(
              itemCount: vaccinations.length,
              itemBuilder: (context, index) {
                final item = vaccinations[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(item["personName"]),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Vaccine: ${item["vaccineName"]}"),
                        Text("Vaccination Date: ${item["vaccinationDate"]}"),
                        Text("Next Date: ${item["nextDate"]}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await deleteRecord(item["id"]);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddVaccinationScreen(),
            ),
          );

          loadVaccinations();
        },
      ),
    );
  }
}

class AddVaccinationScreen extends StatefulWidget {
  const AddVaccinationScreen({super.key});

  @override
  State<AddVaccinationScreen> createState() => _AddVaccinationScreenState();
}

class _AddVaccinationScreenState extends State<AddVaccinationScreen> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController vaccineController = TextEditingController();

  DateTime? vaccinationDate;
  DateTime? nextDate;

  Future<void> pickVaccinationDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        vaccinationDate = picked;
      });
    }
  }

  Future<void> pickNextDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        nextDate = picked;
      });
    }
  }

  Future<void> saveRecord() async {
    if (nameController.text.isEmpty ||
        vaccineController.text.isEmpty ||
        vaccinationDate == null ||
        nextDate == null) {
      return;
    }

    await DatabaseHelper.insertVaccination({
      "personName": nameController.text,
      "vaccineName": vaccineController.text,
      "vaccinationDate": vaccinationDate.toString(),
      "nextDate": nextDate.toString(),
    });

    await NotificationService.scheduleNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: "Vaccination Reminder",
      body: "${nameController.text} needs ${vaccineController.text}",
      scheduledDate: nextDate!,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Vaccination"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: vaccineController,
              decoration: const InputDecoration(
                labelText: "Vaccine Name",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickVaccinationDate,
              child: Text(
                vaccinationDate == null
                    ? "Select Vaccination Date"
                    : vaccinationDate.toString().split(" ")[0],
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: pickNextDate,
              child: Text(
                nextDate == null
                    ? "Select Next Vaccination Date"
                    : nextDate.toString().split(" ")[0],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: saveRecord,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
