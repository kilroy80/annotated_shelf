import 'package:shelf/shelf.dart';

import '../errors/path.error.dart';
import '../models/enums/http_verbs.dart';
import '../core.dart';

dynamic deleteHandler(
    Uri urlUri, Request request, Function deleteFunction) async {
  if (request.method.toLowerCase() == HttpVerbs.delete.name &&
      isSameLink(urlUri.pathSegments, request.url.pathSegments)) {
    var pathParameters =
        getPathParamsMap(urlUri.pathSegments, request.url.pathSegments);
    Map<String, dynamic> parameters = {
      ...pathParameters,
      'shelf_request': request
    };
    var response = await deleteFunction(parameters);
    return response;
  } else {
    throw PathError('');
  }
}

/// Represents the delete http verb.
///
/// This is used to annotated a handler method as a Delete
class DELETE {
  final String url;

  const DELETE({this.url = ''});

  Future<Cascade> execute(
      Function deleteFunction, Cascade router, String baseUrl, List<Middleware>? middlewares) async {
    var completeUrl = baseUrl + url;
    Uri urlUri = Uri.parse(completeUrl);
    print('adding delete $completeUrl');
    if (middlewares != null && middlewares.isNotEmpty) {
      var pipeline = Pipeline();
      for (var element in middlewares) {
        pipeline = pipeline.addMiddleware(element);
      }
      return router.add(pipeline.addHandler((Request request) async {
        try {
          return await deleteHandler(urlUri, request, deleteFunction);
        } on PathError catch (_) {
          return Response.notFound('not found');
        }
      }));
    } else {
      return router.add((Request request) async {
        try {
          return await deleteHandler(urlUri, request, deleteFunction);
        } on PathError catch (_) {
          return Response.notFound('not found');
        }
      });
    }
  }
}
