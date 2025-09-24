import 'package:flutter/material.dart';

class RequestDonorsPage extends StatefulWidget {
  const RequestDonorsPage({super.key});

  @override
  State<RequestDonorsPage> createState() => _RequestDonorsPageState();
}

class _RequestDonorsPageState extends State<RequestDonorsPage> {
  String? _selectedBloodType;
  String? _selectedGender;
  String? _selectedRelation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "Request Donors",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF94747),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Blood Type Section
              const Text(
                "Patient Blood Type",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: [
                  ...<String>[
                    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
                  ].map((bloodType) {
                    return ChoiceChip(
                      label: Text(bloodType),
                      selected: _selectedBloodType == bloodType,
                      onSelected: (selected) {
                        setState(() {
                          _selectedBloodType = selected ? bloodType : null;
                        });
                      },
                      selectedColor: Colors.red,
                      labelStyle: TextStyle(
                        color: _selectedBloodType == bloodType ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: _selectedBloodType == bloodType ? Colors.red : Colors.grey,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 20),
              // Patient Gender Section
              const Text(
                "Patient Gender",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text("Male"),
                      selected: _selectedGender == 'Male',
                      onSelected: (selected) {
                        setState(() {
                          _selectedGender = selected ? 'Male' : null;
                        });
                      },
                      selectedColor: Colors.red,
                      labelStyle: TextStyle(
                        color: _selectedGender == 'Male' ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: _selectedGender == 'Male' ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text("Female"),
                      selected: _selectedGender == 'Female',
                      onSelected: (selected) {
                        setState(() {
                          _selectedGender = selected ? 'Female' : null;
                        });
                      },
                      selectedColor: Colors.red,
                      labelStyle: TextStyle(
                        color: _selectedGender == 'Female' ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: _selectedGender == 'Female' ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Patient Relation Section
              const Text(
                "Patient Relation",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text("Family"),
                      selected: _selectedRelation == 'Family',
                      onSelected: (selected) {
                        setState(() {
                          _selectedRelation = selected ? 'Family' : null;
                        });
                      },
                      selectedColor: Colors.red,
                      labelStyle: TextStyle(
                        color: _selectedRelation == 'Family' ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: _selectedRelation == 'Family' ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text("Friend"),
                      selected: _selectedRelation == 'Friend',
                      onSelected: (selected) {
                        setState(() {
                          _selectedRelation = selected ? 'Friend' : null;
                        });
                      },
                      selectedColor: Colors.red,
                      labelStyle: TextStyle(
                        color: _selectedRelation == 'Friend' ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: _selectedRelation == 'Friend' ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text("Other"),
                      selected: _selectedRelation == 'Other',
                      onSelected: (selected) {
                        setState(() {
                          _selectedRelation = selected ? 'Other' : null;
                        });
                      },
                      selectedColor: Colors.red,
                      labelStyle: TextStyle(
                        color: _selectedRelation == 'Other' ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: _selectedRelation == 'Other' ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Patient Age Section
              const Text(
                "Patient Age",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              TextField(
                decoration: InputDecoration(
                  hintText: "18",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),
              const SizedBox(height: 20),
              // Patient Address Section
              const Text(
                "Patient Address",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Enter Your Address",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),
              const SizedBox(height: 40),
              // Send Requests Button
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement send request logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Send Requests",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}