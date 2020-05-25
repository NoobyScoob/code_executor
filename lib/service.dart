import 'dart:convert';
import 'package:http/http.dart' as http;

class _HttpService {
  static const _API_URL = "http://13.232.62.73:8080/api";

  Future<Map<String, dynamic>> postImageAndExtractCode(String filePath) async {
    var url = Uri.parse(_API_URL + "/upload");
    var req = http.MultipartRequest("POST", url);
    var file = await http.MultipartFile.fromPath('image', filePath);
    req.fields['language'] = 'c';
    req.fields['imageKey'] = file.filename;
    req.files.add(file);

    try {
      var res = await req.send();
      var jsonString = await res.stream.bytesToString();
      Map<String, dynamic> body = jsonDecode(jsonString);
      return body;
    } catch (err) {
      print(err);
      return null;
    }
  }

  Future<Map<String, dynamic>> compileAndExecute(String code, String input) async{
    try {
      var url = Uri.parse(_API_URL + '/execute');
      var body = {
        'lang': 'c',
        'code': code,
        'input': input
      };
      var jsonBody = jsonEncode(body);
      var res = await http.post(
        url,
        headers: {
          'Content-type': 'application/json'
        },
        body: jsonBody
      );
      if (res.statusCode == 200) {
        var jsonRes = jsonDecode(res.body);
        return jsonRes as Map<String, dynamic>;
      }
      return {'message': 'Internal server error'};
    } catch (err) {
      print(err);
      return {'message': err.toString()};
    }
  }
}

final httpService = _HttpService();