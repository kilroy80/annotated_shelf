import 'package:shelf/shelf.dart';

import '../errors/path.error.dart';
import '../models/enums/http_verbs.dart';
import '../core.dart';

dynamic getHandler(Uri urlUri, Request request, Function getFunction) async {
  if (request.method.toLowerCase() == HttpVerbs.get.name &&
      isSameLink(urlUri.pathSegments, request.url.pathSegments)) {
    var pathParameters =
        getPathParamsMap(urlUri.pathSegments, request.url.pathSegments);
    Map<String, dynamic> parameters = {
      ...pathParameters,
      'shelf_request': request
    };
    var response = await getFunction(parameters);
    return response;
  } else {
    throw PathError('GET HANDLER ERROR');
  }
}

/// Represents the get http verb.
///
/// This is used to annotated a handler method as a Get
class GET {
  final String url;

  const GET({this.url = ''});

  Future<Cascade> execute(
      Function getFunction, Cascade router, String baseUrl, List<Middleware>? middlewares) async {
    var completeUrl = baseUrl + url;
    Uri urlUri = Uri.parse(completeUrl);
    print('adding get $completeUrl');
    if (middlewares != null && middlewares.isNotEmpty) {
      var pipeline = Pipeline();
      for (var element in middlewares) {
        pipeline = pipeline.addMiddleware(element);
      }
      return router.add(pipeline.addHandler((Request request) async {
        try {
          return await getHandler(urlUri, request, getFunction);
        } on PathError catch (_) {
          return Response.notFound('not found');
        }
      }));
    } else {
      return router.add((Request request) async {
        try {
          return await getHandler(urlUri, request, getFunction);
        } on PathError catch (_) {
          return Response.notFound('not found');
        }
      });
    }
  }
}
