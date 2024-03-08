import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:typed_data';
import 'dart:convert';

import 'package:sizer/sizer.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? selectedImage;
  String? message = "";
  String? message2 = "";
  String? message3 = "이미지 업로드 전";
  String? base64Text = "";
  String? imageName = "";
  String ServerPath = "http://3.15.46.167:5000";

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          color: Colors.white,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 800),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        height: 25,
                      ),
                      message == ""
                          ? const Text(
                              "전송아직 안됨",
                              style: TextStyle(color: Colors.black),
                            )
                          : Text(
                              message!,
                              style: const TextStyle(color: Colors.black),
                            ),
                      selectedImage == null
                          ? const Text("이미지를 선택 해주세요")
                          : Image.file(selectedImage!),
                      TextButton.icon(
                        style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.orangeAccent),
                        ),
                        onPressed: uploadImage,
                        icon: const Icon(
                          Icons.upload_file,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "업로드",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        "전송한 이미지 변환 보기",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextButton.icon(
                        style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.orangeAccent),
                        ),
                        onPressed: postUseHttpClient_GetImage,
                        icon: const Icon(
                          Icons.upload_file,
                          color: Colors.white,
                        ),
                        label: Text(
                          message2!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      base64Text == ""
                          ? Text(message3!)
                          : Image.memory(
                              Uri.parse(base64Text!).data!.contentAsBytes()),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: getImage,
              child: const Icon(
                Icons.add_a_photo,
              ),
            ),
          ),
        );
      },
    );
  }

  Future getImage() async {
    XFile? ximage = await ImagePicker().pickImage(source: ImageSource.camera);
    selectedImage = File(ximage!.path);
    setState(() {});
  }

  uploadImage() async {
    if (selectedImage != null) {
      final request = http.MultipartRequest("POST", Uri.parse(ServerPath));
      final headers = {"Content-type": "multipart/form-data"};

      request.files.add(http.MultipartFile("image",
          selectedImage!.readAsBytes().asStream(), selectedImage!.lengthSync(),
          filename: selectedImage!.path.split("/").last));

      request.headers.addAll(headers);
      final response = await request.send();
      http.Response res = await http.Response.fromStream(response);

      final resJson = jsonDecode(res.body);
      message = resJson["message"];
      imageName = selectedImage!.path.split("/").last;
      setState(() {});
    } else {
      Fluttertoast.showToast(
          msg: "이미지를 먼저 선택 해주세요",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future postUseHttpClient() async {
    // 클라이언트 인스턴스 생성
    final client = HttpClient();
    try {
      // API 요청
      final request = await client.postUrl(Uri.parse(ServerPath + "/postTest"));

      // 파라미터 설정
      final body = {'param': 'Tests Json'};
      // 헤더에 포함할 콘텐츠 유형 설정 (Json)
      request.headers.contentType = ContentType.json;
      // json.encode 함수를 사용하여 body 라는 Map 객체를 Json 문자열로 인코딩
      // write 메소드를 통해 HTTP 요청의 본문에 작성
      request.write(json.encode(body));

      // 요청 종료
      final response = await request.close();

      // 요청 성공일 경우
      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        final parseResponse = json.decode(responseBody);
        message2 = 'POST parseResponse : $parseResponse';
        final resultValue = parseResponse['result'];
        message2 = 'POST resultValue : $resultValue';
      }
      // 요청 실패 일 경우
      else {
        message2 = 'Request failed with status : ${response.statusCode}';
      }
    }
    // 클라이언트 접속 오류일 경우
    catch (e) {
      message2 = 'Error : $e';
    } finally {
      // 클라이언트 연결 정료
      client.close();
    }
    setState(() {});
  }

  Future postUseHttpClient_GetImage() async {
    // 클라이언트 인스턴스 생성
    if (imageName != "") {
      final client = HttpClient();
      try {
        // API 요청
        final request =
            await client.postUrl(Uri.parse(ServerPath + "/uploaded"));

        // 파라미터 설정
        final body = {'param': imageName};
        // 헤더에 포함할 콘텐츠 유형 설정 (Json)
        request.headers.contentType = ContentType.json;
        // json.encode 함수를 사용하여 body 라는 Map 객체를 Json 문자열로 인코딩
        // write 메소드를 통해 HTTP 요청의 본문에 작성
        request.write(json.encode(body));

        // 요청 종료
        final response = await request.close();

        // 요청 성공일 경우
        if (response.statusCode == HttpStatus.ok) {
          String temp = await response.transform(base64.encoder).join();
          base64Text = "data:image/png;base64," + temp;
        }
        // 요청 실패 일 경우
        else {
          message3 = 'Request failed with status : ${response.statusCode}';
        }
      }
      // 클라이언트 접속 오류일 경우
      catch (e) {
        message3 = 'Error : $e';
      } finally {
        // 클라이언트 연결 정료
        client.close();
      }
      setState(() {});
    } else {
      Fluttertoast.showToast(
          msg: "이미지를 먼저 올려주세요",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
