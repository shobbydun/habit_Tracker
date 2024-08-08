import 'package:flutter/material.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  /*
  SETUP
  */

  //INITIALIZE DATABASE

  static Future<void> intitialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar =
        await Isar.open([HabitSchema, AppSettingsSchema], directory: dir.path);
  }

  //SAVE first date of app startup for the heat map

  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  //get first date of app start up

  Future<DateTime?> getFirstLaunchDte() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  //CRUD OPERATIONS

  //list of habits
  final List<Habit> currentHabits = [];

  //create- add new habit
  Future<void> addHabit(String habitName) async {
    //..create a new habit
    final newHabit = Habit()..name = habitName;

    //saving to db
    await isar.writeTxn((() => isar.habits.put(newHabit)));

    //re-read from db
    readHabits();
  }

  //read - read saved habits from db
  Future<void> readHabits() async {
    //fetch all habits from db
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    //give to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    //update UI
    notifyListeners();
  }

  //updTE - -check completed or not
  Future<void> updateHabitCompletion(int id, bool isCompleteted) async {
    //find the specififc habit
    final habit = await isar.habits.get(id);

    //update the completion status
    if (habit != null) {
      await isar.writeTxn(() async {
        ///if habit is completed -> add the current date to the completeed days list
        if (isCompleteted && !habit.completedDays.contains(DateTime.now())) {
          //today
          final today = DateTime.now();

          //add the cureent date if not already on the list
          habit.completedDays.add(DateTime(
            today.year,
            today.month,
            today.day,
          ));
        }

        //if habit is not completed -> remove current date from list
        else {
          //remove the current date if habit marked as not completed
          habit.completedDays.removeWhere(
            (date) =>
                date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day,
          );
        }

        //save the updated habits back ti db
        await isar.habits.put(habit);
      });
    }

    //re-read from db
    readHabits();
  }

  //update - edit habit name
  Future<void> updateHabitName(int id, String newName) async {
    //find specififc habit to delete
    final habit = await isar.habits.get(id);

    //update habbit name
    if (habit != null) {
      //update name
      await isar.writeTxn(
        () async {
          habit.name = newName;

          //save updated habit back to db
          await isar.habits.put(habit);
        },
      );
    }

    //re-read from db
    readHabits();
  }

  ///delete habit
  
  Future<void> deleteHabit(int id) async {
    //perfoming the delete function
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    }
    );

    //re-read from db
    readHabits();
  }
}
