import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController bookpageController = TextEditingController();
  TextEditingController readinghourController = TextEditingController();

  int selectspeed = 1;
  List<int> speedlist =[
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
  ];

  String result = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Reading Time Estimator'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
          
              TextField(
                controller: bookpageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Number of page of the book',
                ),
              ),
          
              DropdownButton<int>(
                value: selectspeed,
                onChanged: (int? newValue) {
                  setState((){
                    selectspeed = newValue!;
                  });
                },
                items: speedlist.map((int speed){
                  return DropdownMenuItem<int>(
                    value: speed,
                    child: Text(
                      speed.toString(),
                    ),
                  );
                }).toList(),
              ),
          
              TextField(
                controller: readinghourController,
                decoration: const InputDecoration(
                  hintText: 'Hour of reading per day',
                ),
                keyboardType: TextInputType.number,
              ),
          
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: calculateDialog, child: Text('Calculate'),)
              ),

              SizedBox(height: 30),

              Container(
                width: double.infinity,
                child: Text(result),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void calculateDialog() {
    int bookpage = int.tryParse(bookpageController.text.trim()) ?? 0;
    int readinghour = int.tryParse(readinghourController.text.trim()) ?? 0;

    int speed = selectspeed;

    if (bookpage > 0 && readinghour > 0 && speed > 0) {
      double totalhour = bookpage / speed;
      double totalday = totalhour / readinghour;

      setState(() {
        result = 'It will take ${totalday.toStringAsFixed(1)} days';
      });
    } else {
      setState(() {
        result = 'Please enter a valid numbers (greater than 0).';
      });
    }

  }
}
