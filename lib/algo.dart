import 'dart:math';
import 'dart:io';

class TableAlgo {
  const TableAlgo({
    required this.numVars,
    required this.variables,
    required this.numMinterms,
    required this.minterms,
    required this.numDontcares,
    required this.dontcares,
    
  }) ;

  final int numVars;
  final List<String> variables;
  final int numMinterms;
  final List<int> minterms;
  final int numDontcares;
  final List<int> dontcares;
  //final List<String> essentialPrimes;


// Function to check if two terms differ by exactly one bit
bool isGreyCode(String a, String b) {
  int diff = 0;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      diff++;
      if (diff > 1) return false;
    }
  }
  return diff == 1;
}

// Function to count the number of 1's in a number's binary representation
int countOnes(int n) {
  int count = 0;
  while (n > 0) {
    n &= (n - 1);
    count++;
  }
  return count;
}

// Function to combine two terms and mark them as used
String combineTerms(String a, String b) {
  String result = '';
  int diff = 0;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      result += '-';
      diff++;
    } else {
      result += a[i];
    }
  }
  return (diff == 1) ? result : '';
}

// Function to expand a term with don't cares into all possible minterms
List<int> expandTerm(String term) {
  List<int> minterms = [];
  List<int> dashIndices = [];

  // Find positions of don't cares
  for (int i = 0; i < term.length; i++) {
    if (term[i] == '-') {
      dashIndices.add(i);
    }
  }

  int combinations = 1 << dashIndices.length;

  for (int i = 0; i < combinations; i++) {
    String temp = term;
    for (int j = 0; j < dashIndices.length; j++) {
      int pos = dashIndices[j];
      temp = temp.substring(0, pos) +
          (((i >> j) & 1) == 1 ? '1' : '0') +
          temp.substring(pos + 1);
    }
    minterms.add(int.parse(temp, radix: 2));
  }

  return minterms;
}

// Quine-McCluskey algorithm implementation
List<String> quineMcCluskey({required List<int> minterms,required List<int> dontcares, required int numVars}) {
  // Combine minterms and don't cares for the first step
  List<int> allTerms = [...minterms, ...dontcares];
  allTerms.sort();
  allTerms = allTerms.toSet().toList();

  // Group terms by the number of 1's in their binary representation
  Map<int, List<String>> groups = {};
  for (int term in allTerms) {
    int ones = countOnes(term);
    String binary = term.toRadixString(2).padLeft(numVars, '0');
    if (!groups.containsKey(ones)) {
      groups[ones] = [];
    }
    groups[ones]!.add(binary);
  }

  // Perform the combining process
  List<String> primeImplicants = [];
  bool changed = true;

  while (changed) {
    changed = false;
    Map<int, List<String>> newGroups = {};
    Set<String> marked = {};

    // Compare adjacent groups
    var groupKeys = groups.keys.toList()..sort();
    for (int i = 0; i < groupKeys.length - 1; i++) {
      int currentOnes = groupKeys[i];
      int nextOnes = groupKeys[i + 1];
      List<String> currentGroup = groups[currentOnes]!;
      List<String> nextGroup = groups[nextOnes]!;

      for (String term1 in currentGroup) {
        for (String term2 in nextGroup) {
          if (isGreyCode(term1, term2)) {
            String combined = combineTerms(term1, term2);
            if (combined.isNotEmpty) {
              if (!newGroups.containsKey(currentOnes)) {
                newGroups[currentOnes] = [];
              }
              newGroups[currentOnes]!.add(combined);
              marked.add(term1);
              marked.add(term2);
              changed = true;
            }
          }
        }
      }
    }

    // Add unmarked terms to prime implicants
    for (var group in groups.entries) {
      for (String term in group.value) {
        if (!marked.contains(term)) {
          primeImplicants.add(term);
        }
      }
    }

    groups = newGroups;
  }

  // Add any remaining terms in groups to prime implicants
  for (var group in groups.entries) {
    for (String term in group.value) {
      primeImplicants.add(term);
    }
  }

  // Remove duplicate prime implicants
  primeImplicants = primeImplicants.toSet().toList();
  primeImplicants.sort();

  // Create the prime implicant chart
  Map<String, List<int>> primeImplicantChart = {};
  for (String pi in primeImplicants) {
    List<int> coveredMinterms = [];
    List<int> expanded = expandTerm(pi);
    for (int m in expanded) {
      if (minterms.contains(m)) {
        coveredMinterms.add(m);
      }
    }
    if (coveredMinterms.isNotEmpty) {
      primeImplicantChart[pi] = coveredMinterms;
    }
  }

  // Find essential prime implicants
  List<String> essentialPrimes = [];
  Map<int, List<String>> mintermCoverage = {};

  for (var entry in primeImplicantChart.entries) {
    for (int m in entry.value) {
      if (!mintermCoverage.containsKey(m)) {
        mintermCoverage[m] = [];
      }
      mintermCoverage[m]!.add(entry.key);
    }
  }

  // First pass: find primes that are the only cover for some minterm
  for (var entry in mintermCoverage.entries) {
    if (entry.value.length == 1) {
      String essential = entry.value[0];
      if (!essentialPrimes.contains(essential)) {
        essentialPrimes.add(essential);
      }
    }
  }

  // Second pass: handle remaining minterms
  Set<int> coveredMinterms = {};
  for (String ep in essentialPrimes) {
    coveredMinterms.addAll(primeImplicantChart[ep]!);
  }

  List<int> remainingMinterms = [];
  for (int m in minterms) {
    if (!coveredMinterms.contains(m)) {
      remainingMinterms.add(m);
    }
  }

  if (remainingMinterms.isNotEmpty) {
    Map<String, int> primeCoverage = {};
    for (var entry in primeImplicantChart.entries) {
      if (!essentialPrimes.contains(entry.key)) {
        int count = 0;
        for (int m in entry.value) {
          if (remainingMinterms.contains(m)) {
            count++;
          }
        }
        if (count > 0) {
          primeCoverage[entry.key] = count;
        }
      }
    }

    while (remainingMinterms.isNotEmpty) {
      String bestPrime = '';
      int maxCoverage = -1;
      for (var entry in primeCoverage.entries) {
        if (entry.value > maxCoverage) {
          maxCoverage = entry.value;
          bestPrime = entry.key;
        }
      }

      if (maxCoverage == -1) break;

      essentialPrimes.add(bestPrime);

      List<int> newRemaining = [];
      for (int m in remainingMinterms) {
        bool covered = primeImplicantChart[bestPrime]!.contains(m);
        if (!covered) newRemaining.add(m);
      }
      remainingMinterms = newRemaining;

      primeCoverage.clear();
      for (var entry in primeImplicantChart.entries) {
        if (!essentialPrimes.contains(entry.key)) {
          int count = 0;
          for (int m in entry.value) {
            if (remainingMinterms.contains(m)) {
              count++;
            }
          }
          if (count > 0) {
            primeCoverage[entry.key] = count;
          }
        }
      }
    }
  }

  return essentialPrimes;
}

// Function to convert binary string to SOP expression
String getSOPExpression({required List<String> primeImplicants,required List<String> variables}) {
  String expression = '';
  for (String pi in primeImplicants) {
    if (expression.isNotEmpty) {
      expression += ' + ';
    }
    for (int i = 0; i < pi.length; i++) {
      if (pi[i] == '0') {
        expression += '${variables[i]}\'';
      } else if (pi[i] == '1') {
        expression += variables[i];
      }
    }
  }
  return expression.isEmpty ? '1' : expression;
}


}
