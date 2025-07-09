import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'Configuration/Graphql_Config.dart';
import 'Controller/UserController.dart';
import 'Controller/CompanyController.dart';
import 'Service/GraphqlService/Graphql_Service.dart';
import 'View/Screens/MainWrapperScreen.dart';
import 'View/Screens/SplashScreen/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();

  final graphqlService = GraphQLService(GraphQLConfig().client.value);

  // Register controllers with GetX
  Get.put(CompanyController(graphqlService));
  Get.put(UserController(graphqlService));

  runApp(VisitorApp());
}


class VisitorApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client = GraphQLConfig().client;

  VisitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'CrestParkz',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: SplashScreen(
          onFinish: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainWrapperScreen()),
            );
          },
        ),
      ),
    );
  }
}
