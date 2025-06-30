import 'package:flutter/material.dart';
import 'package:truth_table/algo.dart';
import 'package:truth_table/colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.numOfVAr, required this.variable});
  final int numOfVAr;
  final List<String> variable;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int numVars;
  List<List<int>> truthTableInputs = [];

  final List<String> cyclevalues = ['X', '0', '1'];
  late List<String> gridValues;

  int numMinterm = 0;
  int numDontcares = 0;
  final List<int> minTerms = [];
  final List<int> dontCares = [];
  String expression = '';

  @override
  void initState() {
    super.initState();
    numVars = widget.numOfVAr;
    gridValues = List.generate(1 << widget.numOfVAr, (index) => 'X');
    _generateTable();
  }

  void _generateTable() {
    setState(() {
      truthTableInputs = generateTruthTable(numVars);
    });
  }

  //output 1,0,x change
  void updateOutput(int index) {
    setState(() {
      int currIndex = cyclevalues.indexOf(gridValues[index]);
      gridValues[index] = cyclevalues[(currIndex + 1) % cyclevalues.length];
    });
  }

  //binary combination creation
  List<List<int>> generateTruthTable(int numVars) {
    int totalCombination = 1 << numVars;

    return List.generate(totalCombination, (index) {
      return List.generate(
        numVars,
        (bit) => (index >> (numVars - bit - 1)) & 1,
      );
    });
  }

  //expression calculation
  void calculateTable() {
    setState(() {
      numMinterm = 0;
      numDontcares = 0;
      minTerms.clear();
      dontCares.clear();

      for (int i = 0; i < gridValues.length; i++) {
        if (gridValues[i] == '1') {
          numMinterm++;
          minTerms.add(i);
        } else if (gridValues[i] == 'X') {
          numDontcares++;
          dontCares.add(i);
        }
      }
      if (numMinterm == 0) {
        expression = '0';
      } else {
        final tableAlgo = TableAlgo(
          numVars: numVars,
          variables: widget.variable,
          numMinterms: numMinterm,
          minterms: minTerms,
          numDontcares: numDontcares,
          dontcares: dontCares,
        );

        List<String> essentialPrimes = tableAlgo.quineMcCluskey(
          dontcares: dontCares,
          minterms: minTerms,
          numVars: numVars,
        );

        expression = tableAlgo.getSOPExpression(
          primeImplicants: essentialPrimes,
          variables: widget.variable,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backC1,
        centerTitle: true,
        title: Text('$numVars Variable Truth Table',style: TextStyle(
         fontFamily: 'almendra',
              fontSize: 25,
              color: mainC
        ),),
      ),
      body: Container(
        color:backC,
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 55,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 55),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:  EdgeInsets.symmetric(vertical: numVars > 3 ? 40 : 0.0,horizontal:  numVars > 3 ? 15 : 0.0),
                    child: ClipRRect(
                       borderRadius: BorderRadius.circular(15),
                    clipBehavior: Clip.hardEdge,
                      child: SingleChildScrollView(
                      scrollDirection:Axis.horizontal ,
                        child: DataTable(
                            border: TableBorder.all( // Adds borders on all sides
                            color: Colors.grey, // Border color
                            width: 1.0, // Border thickness
                            borderRadius: BorderRadius.circular(15),
                             // Rounded corners
                          ),
                          //dividerThickness: 3,
                         headingRowHeight: 55,
                        showBottomBorder: true,
                        headingRowColor: WidgetStateProperty.all(bodyC),
                            columnSpacing: numVars > 4 ? 45 : null,
                          decoration: BoxDecoration(
                            color: backC1,
                         
                          ),
                          columns: [
                            for (int i = 0; i < numVars; i++)
                              DataColumn(label: Text(widget.variable[i],style: TextStyle(
                                color: backC1,
                                fontSize: 20
                              ),),),
                            DataColumn(label: Text('F',style: TextStyle(
                                color: backC1,
                                fontSize: 20
                              ),),
                             ),
                          ],
                        
                          rows:
                              truthTableInputs.asMap().entries.map((entry) {
                                final index = entry.key;
                                final input = entry.value;
                                return DataRow(

                                  cells: [
                        
                                    for (int bit in input) DataCell(Text('$bit',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 17))),
                                    DataCell(
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => updateOutput(index),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(gridValues[index],style: TextStyle(fontWeight: FontWeight.w600,fontSize: 17),),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25,),
                 Text('Simplified Expression',style: TextStyle(
         fontFamily: 'almendra',
              fontSize: 25,
              color: mainC
        ),),
        const SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(expression,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                             fontFamily: 'exp',
                                  fontSize: 30,
                                  color: Colors.black,
                                  //fontWeight: FontWeight.bold
                            ),),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainC,

                    ),
                    onPressed: calculateTable,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Calculate',style: TextStyle(
                         fontFamily: 'almendra',
                                    fontSize: 25,
                                    color: backC1
                      ),),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
