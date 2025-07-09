import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../Configuration/Graphql_Config.dart';
import '../../../../Controller/CompanyController.dart';
import '../../../../Controller/UserController.dart';
import '../../../../Model/CompanyModel.dart';
import '../../../../Service/GraphqlService/Graphql_Service.dart';
import '../BottomScreens/CompanyScreen/AddCompanyScreen.dart';
import 'CompanyCard.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  _CompanyListScreenState createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  late final CompanyController companyController;
  List<LogDetails> company = [];
  late UserController userController;
  late final String? companyId;

  @override
  void initState() {
    super.initState();

    // Use the centralized GraphQLClient from GraphQLConfig
    final graphqlService = GraphQLService(GraphQLConfig().client.value);
    companyController = CompanyController(graphqlService);

    final int? adminId = userController.userData.value.userid;
    if (adminId != null) {
      fetchLog(adminId: adminId);
    } else {
      print("Admin ID (userId) is null. Cannot fetch logs.");
    }
  }

  // Fetch visitors dynamically from GraphQL
  Future<void> fetchLog({required int adminId}) async {
    List<LogDetails>? fetched = await companyController.fetchLogs(
      adminId: adminId,
    );
    if (fetched != null) {
      setState(() {
        company = fetched;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Company List')),
      body:
          company.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: company.length,
                itemBuilder: (context, index) {
                  final item = company[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddCompanyForm(
                            entryId: item.entryId,
                          ),
                        ),
                      );
                    },


                    child: CompanyCard(company: item),
                  );
                },
              ),
    );
  }
}
