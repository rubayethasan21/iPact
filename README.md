# unify_secret

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



## Generate model class by code

Run this command :
dart run build_runner build

If any conflicts Run this command :
dart run build_runner build --delete-conflicting-outputs


## But before that, you will have to import the generator.

Example: If your file name is project_database.dart, then in that file :

Import,

import 'package:hive/hive.dart';
part 'project_database.g.dart';
//this will show an error initially but if
// you run the above command, it will generate the generator file


[//]: # (      if&#40;iOTATransactionId.isEmpty&#41;)

[//]: # (        {)

[//]: # (          Column&#40;)

[//]: # (            mainAxisAlignment: MainAxisAlignment.center,)

[//]: # (            crossAxisAlignment: CrossAxisAlignment.center,)

[//]: # (            children: [)

[//]: # (              CircularProgressIndicator&#40;color: context.theme.focusColor&#41;,)

[//]: # (              vSpacer10&#40;&#41;,)

[//]: # (              const TextAutoMetropolis&#40;)

[//]: # (                "Please wait !.",)

[//]: # (                maxLines: 10,)

[//]: # (                fontSize: Dimens.fontSizeMid,)

[//]: # (                textAlign: TextAlign.center,)

[//]: # (              &#41;)

[//]: # (            ],)

[//]: # (          &#41;;)

[//]: # ()
[//]: # (        }else )
