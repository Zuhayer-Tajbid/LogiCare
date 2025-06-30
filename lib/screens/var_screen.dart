import 'package:flutter/material.dart';
import 'package:truth_table/colors.dart';
import 'package:truth_table/screens/main_screen.dart';

class VarScreen extends StatelessWidget {
  const VarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<int> varNum = [2, 3, 4, 5];

    List<List<String>> variableList = [
      ['A', 'B'],
      ['A', 'B', 'C'],
      ['A', 'B', 'C', 'D'],
      ['A', 'B', 'C', 'D', 'E'],
    ];

    return Scaffold(
      body: Container(
         color: backC1,
        child: Column(
         
          children: [
            const SizedBox(height: 160,),
            Text('Welcome to LogiCare',style: TextStyle(
              color: mainC,
              fontFamily: 'almendra',
              fontSize: 35
            ),),
            Expanded(
              child: ListView.builder(
                      itemCount: varNum.length,
                      itemBuilder:
                (context, index) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bodyC,
                        elevation: 3,
                        minimumSize: Size(250, 90),
                      
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MainScreen(
                                  numOfVAr: varNum[index],
                                  variable: variableList[index],
                                ),
                          ),
                        );
                      },
                      child: Text('${varNum[index]} variable',style: TextStyle(
              color: backC1,
              fontFamily: 'almendra',
              fontSize: 30
            ),),
                    ),
                  ),
                ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
