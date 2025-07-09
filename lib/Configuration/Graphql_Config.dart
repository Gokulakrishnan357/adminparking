import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'dart:io';
import 'package:http/io_client.dart';

class GraphQLConfig {
  static final HttpLink httpLink = HttpLink(
    'https://crestparkzapidev.crestclimbers.com/graphql/',
    httpClient: IOClient(
      HttpClient()
        ..connectionTimeout = const Duration(seconds: 20),
    ),
  );

  ValueNotifier<GraphQLClient> get client => ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: HiveStore()),
    ),
  );
}

