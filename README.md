
This package makes it easy to use the supabase database. It provides generic methods
for performing CRUD operations (Create, Read, Update and Delete).
See the example package to see a complete example of using the package.

## Features

* Provide authentication for logging in and creating a new user.
* Provide generic methods to perform CRUD operations.

## Getting started

Add the package:
```shell
flutter pub add supa_manager
```

## Usage
To start using this package, you need to create an instance of the Configuration class:
```dart
  final configuration = Configuration();
  await configuration.initialize('supabase url', 'supabase api key', 'supabase API secret');
```
This will initialize the Supabase client with the provided url, api key and api secret.

### Authentication
To log in, use the following code:
```dart
 configuration.supaAuthManager.login('email', 'password');
```
To load an existing user, use the following code:
```dart
 final databaseUser = configuration.supaAuthManager.loadUser();
```
If the user session is valid, the user will be returned. Otherwise, null will be returned.

This package allows you to handle all the CRUD operations you need:
Obtain the database repository:
```dart
 final databaseRepository = configuration.supaDatabaseRepository;
```
You will need to subclass the TableData class to provide the table name and the columns in the table.
Something like this:
```dart
class TaskTableData extends TableData<Task> {
  TaskTableData() {
    tableName = taskTableName;
  }

  @override
  Task fromJson(Map<String, dynamic> json) {
    return Task.fromJson(json);
  }
}
```
```dart
### Creation
`databaseRepository.addEntry(tableData, TableEntry(item));`
### Reading
`databaseRepository.readEntries(tableData)`
### Updating
`databaseRepository.updateTableEntry(tableData, TableEntry(item));`
### Deletion
`databaseRepository.deleteTableEntry(tableData, TableEntry(item));`


## Additional information

See the example to see a complete example of using the package.
For more information on **Supabase**, go to https://supabase.com
For a video tutorial, see https://www.kodeco.com/33619647-supabase-with-flutter
