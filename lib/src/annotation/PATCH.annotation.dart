import 'package:shelf/shelf.dart';

import '../errors/path.error.dart';
import '../models/enums/http_verbs.dart';
import '../core.dart';

dynamic patchHandler(
    Uri urlUri, Request request, Function patchFunction) async {
  if (request.method.toLowerCase() == HttpVerbs.patch.name &&
      isSameLink(urlUri.pathSegments, request.url.pathSegments)) {
    var pathParameters =
        getPathParamsMap(urlUri.pathSegments, request.url.pathSegments);
    Map<String, dynamic> parameters = {
      ...pathParameters,
      'shelf_request': request
    };
    parameters = await decodeBody(request, parameters);
    var response = await patchFunction(parameters);
    return response;
  } else {
    throw PathError('');
  }
}

/// Represents the patch http verb.
///
/// This is used to annotated a handler method as a Patch
class PATCH {
  final String url;

  const PATCH({this.url = ''});

  Future<Cascade> execute(
      Function patchFunction, Cascade router, String baseUrl, List<Middleware>? middlewares) async {
    var completeUrl = baseUrl + url;
    Uri urlUri = Uri.parse(completeUrl);
    print('adding patch $completeUrl');
    if (middlewares != null && middlewares.isNotEmpty) {
      var pipeline = Pipeline();
      for (var element in middlewares) {
        pipeline = pipeline.addMiddleware(element);
      }
      return router.add(pipeline.addHandler((Request request) async {
        try {
          return await patchHandler(urlUri, request, patchFunction);
        } on PathError catch (_) {
          return Response.notFound('');
        }
      }));
    } else {
      return router.add((Request request) async {
        try {
          return await patchHandler(urlUri, request, patchFunction);
        } on PathError catch (_) {
          return Response.notFound('');
        }
      });
    }
  }
}
