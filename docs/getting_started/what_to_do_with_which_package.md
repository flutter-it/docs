---
title: What to do with which package?
---

# What to do with which package?

The current packages of Flutter_it are designed to make it eassier to structure your Flutter applications. Most of them fall into the category that is often called "state management" or "dependency injection". We will have a closer look at the different packages and what they are good for.

# Principles of good architecture 

This won't be a comprehensive guide on how to structure your Flutter application. But I will give you some principles that I think are important to keep in mind when developing Flutter applications. For a detailed discussion see my article https://blog.burkharts.net/practical-flutter-architecture

Here are some key principles that I think are important to keep in mind when developing Flutter applications:

## Separation of concerns
Different parts of the application should be responsible for different things. 
* For example, the UI should be responsible for displaying data, and the business logic should be responsible for handling the data. 
* So its not a good idea to store your data inside your widgets. Especially not if that data is used in multiple places.
* The same applies to the business logic. For example, if you have a function that is used in multiple places, you should not have multiple functions that do the same thing.

An approach that has been proven to work well is to split your application into multiple layers. 

* The UI layer is responsible for displaying the data.
* The business logic layer is responsible for handling the data.
* Servics layer is responsible to communicate with everything outside of your application. That can be a database, a web service, or device of the phone.

When doing this you want to avoid that the different have strong dependencies on each other. It should be possible to change one part of the application without having to change the other parts. And to test each your business logic without the UI.

## Single source of truth
There should be a single source of truth for the data that the application needs. For example, if you have a list of items, you should have a single list that contains all the items, and not have multiple lists that contain the same items.

## Testability
The application should be designed in a way that allows for easy testing. For example, if you have a list of items, you should be able to test the list component in isolation.


# Problems that need to be solved

If we want to follow the principles of good architecture, we need to solve some problems.

1. If we want to have a single source of truth, and not to store the data inside the UI, we need a way to access the data from the UI or how to access services from the business logic.
2. If the date lives outside of the UI, how can the UI be updated when the data changes? 
3. How can we avoid to manually implment common functionality like displaying a loading indicator, or showing an error message?

## get_it
Will help you with 1. [get_it](/documentation/get_it/getting_started) is a service locator that allows you to register objects and access them from anywhere in your application. Additionally it offers functionality to ensure that all your objects are ready to be used when you need them.

## watch_it
Will help you with 2. [watch_it](/documentation/watch_it/watch_it) is a library that allows you to watch a value and automatically rebuild your Widgets when the value changes. It can access data registered inside get_it.

## command_it
Will help you with 3. command_it is a library that allows you to implement the command pattern in your application. It encapsulates logic for loading state, enabling/diabling commands, and sophisticated error handling. A command can be observed with watch_it so that your UI can react to state changes of the command.

## listen_it
Allows you to logically combine multiple ValueListenables into a single ValueListenable. It also contains a `listen()` extension method to add and remove listeners from a ValueListenable like you would do with a Stream. 



