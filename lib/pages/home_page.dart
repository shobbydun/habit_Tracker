import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/util/habit_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //init state
  @override
  void initState() {
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  //text editing controller
  final TextEditingController textController = TextEditingController();

  //createNewHabit function
  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: InputDecoration(hintText: "Add new Habit🎉"),
          keyboardType: TextInputType.multiline,
          maxLines: null, // Allow multiple lines
        ),
        actions: [
          //save button
          MaterialButton(
            onPressed: () {
              // GET THE NEW HABIT NAME
              String newHabitName = textController.text;

              // SAVE TO DB
              context.read<HabitDatabase>().addHabit(newHabitName);

              // POP BOX
              Navigator.pop(context);

              // CLEAR CONTROLLER
              textController.clear();
            },
            child: const Text("Save"),
          ),

          // cancel button
          MaterialButton(
            onPressed: () {
              // POP BOX
              Navigator.pop(context);

              // CLEAR CONTROLLER
              textController.clear();
            },
            child: const Text("Cancel"),
          )
        ],
      ),
    );
  }

  // check habit on/off
  void checkHabitOnOff(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  // edit habit box
  void editHabitBox(Habit habit) {
    // set the controller's text to the habit's current name
    textController.text = habit.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.multiline,
          maxLines: null, // Allow multiple lines
        ),
        actions: [
          // save button
          MaterialButton(
            onPressed: () {
              // GET THE NEW HABIT NAME
              String newHabitName = textController.text;

              // UPDATE TO DB
              context
                  .read<HabitDatabase>()
                  .updateHabitName(habit.id, newHabitName);

              // POP BOX
              Navigator.pop(context);

              // CLEAR CONTROLLER
              textController.clear();
            },
            child: const Text("Save"),
          ),

          // cancel button
          MaterialButton(
            onPressed: () {
              // POP BOX
              Navigator.pop(context);

              // CLEAR CONTROLLER
              textController.clear();
            },
            child: const Text("Cancel"),
          )
        ],
      ),
    );
  }

  // delete habit box
  void deleteHabitBox(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure you want to delete?❌"),
        actions: [
          // delete button
          MaterialButton(
            onPressed: () {
              // DELETE FROM DB
              context.read<HabitDatabase>().deleteHabit(habit.id);

              // POP BOX
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),

          // cancel button
          MaterialButton(
            onPressed: () {
              // POP BOX
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 158, 213, 239),
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      body: ListView(
        children: [
          // heat map
          _buildHeatMap(),

          // habit list
          _buildHabitList(),
        ],
      ),
    );
  }

  // build _buildHeatMap
  Widget _buildHeatMap() {
    // habit database
    final habitDatabase = context.watch<HabitDatabase>();

    // current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    // return heat map UI
    return FutureBuilder(
      future: habitDatabase.getFirstLaunchDte(),
      builder: (context, snapshot) {
        // once the data is available -> build heatmap
        if (snapshot.hasData) {
          return MyHeatMap(
            startDate: snapshot.data!,
            datasets: prepHeatMapDataset(currentHabits),
          );
        } else {
          // handle case
          return Container();
        }
      },
    );
  }

  // build habit list
  Widget _buildHabitList() {
    // habit database
    final habitDatabase = context.watch<HabitDatabase>();

    // current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    // return list of habits UI
    return ListView.builder(
      itemCount: currentHabits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        // get each individual habit
        final habit = currentHabits[index];

        // check if habit is completed today
        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

        // return habit tile UI
        return MyHabitTile(
          text: habit.name,
          isCompleted: isCompletedToday,
          onChanged: (value) => checkHabitOnOff(value, habit),
          editHabit: (context) => editHabitBox(habit),
          deleteHabit: (context) => deleteHabitBox(habit),
        );
      },
    );
  }
}
