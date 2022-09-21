## Cookbook
All the snippets are from the example project.

### Starting out
Since this package uses the Supabase server, you'll need to have created an account
at https://supabase.com. You can read the docs at: https://supabase.com/docs

### Initialization

In order to start, you'll need to initialize supa_manager with your Supabase api key and secret. Since the example
uses an api key & secret and url that are in use, the example stores theses values in a secrets.json file stored in the assets
directory of the example project. You'll have to create your own to use the example project.
The example project uses Riverpod but you can use whatever state management system you'd like.
Here is the initialization in `maind.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final secrets = await SecretLoader(secretPath: 'assets/secrets.json').load();
  configuration = Configuration();
  await configuration.initialize(secrets.url, secrets.apiKey, secrets.apiSecret);
  runApp(const ProviderScope(child: MyApp()));
}

```

SecretLoader is a simple class used to load the supabase url, key & secret. Since these are sensitive values, this file
is not checked into source control. Create a Configuration class and initialize with the url, api key, and api secret.
This will create the supabase instance as well as the SupaAuthManager and SupaDatabaseManager.

This example also uses **go_router** for page handling.

### Authentication

In order to use a database, a user has to be authenticated. The **SupaAuthManager** class handles that. If you look at the **LoginDialog** class you will see
There are two important methods:

```dart
  Future<Result<DatabaseUser>> login(String email, String password);
```
and:
```dart
  Future<Result<bool>> createUser(String email, String password);
```

The **Result** class returns `Result.success`, `Result.failure` or `Result.errorMessage`. See the **LoginDialog** class for an example of how to use it.

### Database

In order to use the database you have to first create the tables in supabase. Since this package assumes that you have your tables based on userId's, you'll 
need to add a `userId` field in each table. This will will be of type `uuid`. Then you will need to create
two classes for each table:  One based on `TableData` which gives the table name and a `fromJson` method to convert JSON data to your class.
The second table is based on `TableEntry`. This class provides a `toJson`, and id and a `addUserId` method to create a copy of your class
with the userId set.

Here is the Task classes:

```dart
const taskTableName = 'TodayTasks';
const categoryTableName = 'TodayCategory';

class TaskTableData extends TableData<Task> {
  TaskTableData() {
    tableName = taskTableName;
  }

  @override
  Task fromJson(Map<String, dynamic> json) {
    return Task.fromJson(json);
  }
}

class TaskTableEntry with TableEntry<Task> {
  final Task task;

  TaskTableEntry(this.task);

  @override
  TaskTableEntry addUserId(String userId) {
    return TaskTableEntry(task.copyWith(userId: userId));
  }

  @override
  Map<String, dynamic> toJson() {
    return task.toJson();
  }

  @override
  int? get id => task.id;

  @override
  set id(int? id) {}
}
```
### Listing
To get the list of all entries, call the `readEntries` method:

```dart
Future<Result<List<Task>>> getTasks() async {
  return databaseRepository.readEntries(taskTableData);
}
 ```

For more complex calls you can use either
```dart
Future<Result<List<T>>> readEntriesWhere<T>(TableData<T> tableData, String columnName, int id);
 ```
or
```dart
Future<Result<List<T>>> selectEntriesWhere<T>(TableData<T> tableData, List<SelectEntry> selections);
 ```

The first one is for just selecting a specific column. The second one allows you to use **and**/**or** queries.
 
Here is an example of selecting tasks:
```dart
Future<Result<List<T>>> getTodaysTasks() async {
    return databaseRepository.selectEntriesWhere(taskTableData, [
      SelectEntry.and('done', 'false'),
      SelectEntry.and('doLater', 'false')
    ]);
  }
```

### Adding
To add data you would write something like:
```dart
Future<Result<Task?>> addTask(Task task) async {
    final result = await databaseRepository.addEntry(taskTableData, TaskTableEntry(task));
    notifyListeners();
    return result;
  }
 ```

This calls the `addEntry` method with the TableData class and a new TableEntry class.

### Deletion
To delete an entry, simply call `deleteTableEntry` like this:

```dart
Future<Result<Task?>> deleteTask(Task task) async {
    final result = await databaseRepository.deleteTableEntry(
        taskTableData, TaskTableEntry(task));
    notifyListeners();
    return result;
  }
```

### Updating

To update an entry, simply call `updateTableEntry` like this:

```dart
Future<Result<Task?>> updateTask(Task task) async {
  final result = await databaseRepository.updateTableEntry(
      taskTableData, TaskTableEntry(task));
  notifyListeners();
  return result;
}
```
