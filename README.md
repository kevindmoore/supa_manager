
This package makes it easy to use the supabase database. It provides generic methods
for performing CRUD operations (Create, Read, Update and Delete).

## Features

* Provide authentication for logging in and creating a new user.
* Provide generic methods to perform CRUD operations.

## Getting started

Add the package:
```shell
flutter pub add supa_manager
```

## Usage

This package allows you to handle all the CRUD operations you need:
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
