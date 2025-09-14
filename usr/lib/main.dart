import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Frankenstein's Elixir",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const FrankensteinPage(),
    );
  }
}

class FrankensteinPage extends StatefulWidget {
  const FrankensteinPage({super.key});

  @override
  State<FrankensteinPage> createState() => _FrankensteinPageState();
}

class _FrankensteinPageState extends State<FrankensteinPage> {
  final TextEditingController _recipesController = TextEditingController();
  final TextEditingController _potionController = TextEditingController();
  String _result = '';

  // Data structures to hold the parsed recipes and memoization cache for performance.
  final Map<String, List<List<String>>> _recipes = {};
  final Map<String, int> _memo = {};

  void _calculateMinimumOrbs() {
    // 1. Clear previous data and reset the UI
    _recipes.clear();
    _memo.clear();
    setState(() {
      _result = '';
    });

    final allRecipeLines = _recipesController.text.trim().split('\n');
    final targetPotion = _potionController.text.trim();

    if (allRecipeLines.isEmpty || targetPotion.isEmpty) {
      setState(() {
        _result = 'Please provide recipes and a target potion.';
      });
      return;
    }

    // 2. Parse the recipe strings into a more usable map structure.
    // Each potion can have multiple recipes (a list of lists of ingredients).
    for (final line in allRecipeLines) {
      if (!line.contains('=')) continue; // Skip non-recipe lines (like the count)
      
      final parts = line.split('=');
      if (parts.length != 2) continue; // Skip malformed lines

      final potion = parts[0].trim();
      final ingredients = parts[1].split('+').map((i) => i.trim()).toList();

      // Add the recipe to our map.
      if (_recipes.containsKey(potion)) {
        _recipes[potion]!.add(ingredients);
      } else {
        _recipes[potion] = [ingredients];
      }
    }

    // 3. Start the recursive calculation for the target potion.
    final int minOrbs = _getMinOrbs(targetPotion);

    // 4. Display the result.
    setState(() {
      _result = 'Minimum magical orbs required: $minOrbs';
    });
  }

  // Recursive function with memoization to find the minimum orbs.
  int _getMinOrbs(String potion) {
    // Memoization: If we've already calculated the cost for this potion,
    // return the cached value to avoid redundant computation.
    if (_memo.containsKey(potion)) {
      return _memo[potion]!;
    }

    // Base Case: If a potion is not in our recipe book, it's a base ingredient.
    // Base ingredients don't need to be brewed, so their cost is 0 orbs.
    if (!_recipes.containsKey(potion)) {
      return 0;
    }

    int minOrbs = 999999; // Initialize with a large value (infinity)

    // Explore all possible recipes for the current potion.
    for (var recipe in _recipes[potion]!) {
      // The cost for the current brewing step is (number of ingredients - 1).
      int currentRecipeOrbs = recipe.length - 1;

      // Recursively find the cost for each ingredient and add it to the total.
      for (var ingredient in recipe) {
        currentRecipeOrbs += _getMinOrbs(ingredient);
      }

      // Check if this recipe is cheaper than the best one found so far.
      minOrbs = min(minOrbs, currentRecipeOrbs);
    }

    // Cache the result for the current potion before returning.
    _memo[potion] = minOrbs;
    return minOrbs;
  }

  @override
  void dispose() {
    _recipesController.dispose();
    _potionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Frankenstein's Elixir Calculator"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Enter Recipes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _recipesController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'awakening=snakefangs+wolfbane\ndragontonic=awakening+veritaserum...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Target Potion',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _potionController,
                decoration: const InputDecoration(
                  hintText: 'e.g., dragontonic',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculateMinimumOrbs,
                child: const Text('Calculate Orbs'),
              ),
              const SizedBox(height: 20),
              if (_result.isNotEmpty)
                Text(
                  _result,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
