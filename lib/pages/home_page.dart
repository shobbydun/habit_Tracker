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

  //texteditting controller
  final TextEditingController textController = TextEditingController();

  //createNewHbit function
  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: InputDecoration(hintText: "Add new Habit🎉"),
        ),
        actions: [
          //save buttn
          MaterialButton(
            onPressed: () {
              //GET THE NEW HABIT NAME
              String newHabitName = textController.text;

              //save to db
              context.read<HabitDatabase>().addHabit(newHabitName);

              //pop box
              Navigator.pop(context);

              //clear controller
              textController.clear();
            },
            child: const Text("Save"),
          ),

          //cancel btn
          MaterialButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);

              //clear controller
              textController.clear();
            },
            child: const Text("Cancel"),
          )
        ],
      ),
    );
  }

  //check habit on off
  void checkHabitOnOff(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  //edit habit box
  void editHabitBox(Habit habit) {
    //set the controllers text to the habit current name
    textController.text = habit.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          //save buttn
          MaterialButton(
            onPressed: () {
              //GET THE NEW HABIT NAME
              String newHabitName = textController.text;

              //update to db
              context
                  .read<HabitDatabase>()
                  .updateHabitName(habit.id, newHabitName);

              //pop box
              Navigator.pop(context);

              //clear controller
              textController.clear();
            },
            child: const Text("Save"),
          ),

          //cancel btn
          MaterialButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);

              //clear controller
              textController.clear();
            },
            child: const Text("Cancel"),
          )
        ],
      ),
    );
  }

  //delete habit box
  void deleteHabitBox(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure you want to delete?❌"),
        actions: [
          //delete buttn
          MaterialButton(
            onPressed: () {
              //delete from db
              context.read<HabitDatabase>().deleteHabit(habit.id);

              //pop box
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),

          //cancel btn
          MaterialButton(
            onPressed: () {
              //pop box
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
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(
          Icons.add,
        color: Colors.black,
        ),
      ),
      body: ListView(
        children: [
          //heat Map
          _buildHeatMap(),

          //habit list
          _buiildHabitList()
        ],
      ),
    );
  }

  //build _buildHeatMap
  Widget _buildHeatMap(){
    //habit databse
    final habitDatabse = context.watch<HabitDatabase>();

    //current habits
    List<Habit> currentHabits = habitDatabse.currentHabits;

    //return heat map UI
    return FutureBuilder(future: habitDatabse.getFirstLaunchDte(), 
    builder: (context, snapshot){
      //once the data is available -> build heatmap
      if(snapshot.hasData){
        return MyHeatMap(
          startDate: snapshot.data!,
          datasets: prepHeatMapDataset(currentHabits),
        );
      }

      //handle case
      else{
        return Container();
      }
    },
    );
  }

  //buld habit list
  Widget _buiildHabitList() {
    //habit db
    final habitDatabase = context.watch<HabitDatabase>();

    //current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    //return lists of habits UI
    return ListView.builder(
      itemCount: currentHabits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        //get each individual habit
        final habit = currentHabits[index];

        //check if habit is completd today
        bool isCompletetedToday = isHabitCompletedToday(habit.completedDays);

        //return habit tile UI
        return MyHabitTile(
          text: habit.name,
          isCompleted: isCompletetedToday,
          onChanged: (value) => checkHabitOnOff(value, habit),
          editHabit: (context) => editHabitBox(habit),
          deleteHabit: (context) => deleteHabitBox(habit),
        );
      },
    );
  }
}
