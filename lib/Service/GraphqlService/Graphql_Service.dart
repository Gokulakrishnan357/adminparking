import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  final GraphQLClient client;

  GraphQLService(this.client);

  Future<QueryResult> performQuery(String query,
      {Map<String, dynamic>? variables}) async {
    final options = QueryOptions(
      document: gql(query),
      variables: variables ?? {},
      fetchPolicy: FetchPolicy.networkOnly,
    );
    return await client.query(options);
  }


  Future<QueryResult> performMutation(String mutation,
      {Map<String, dynamic>? variables}) async {
    final options = MutationOptions(document: gql(mutation), variables: variables ?? {});
    return await client.mutate(options);
  }

}
