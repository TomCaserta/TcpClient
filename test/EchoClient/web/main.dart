library ChromeClientTest;
import "dart:convert";
import 'packages/tcpclient/tcpclient.dart';
import "package:chrome/chrome_app.dart";
import "package:unittest/unittest.dart";

void main () {
  print("Starting");
  TcpClient testClient = new TcpClient("127.0.0.1", 3738);
  print("Got here");
  testClient.onReceiveError.listen((ReceiveErrorInfo rev) {
    print(rev.toString());
  });
  testClient.connect().then((int readyCode) { 
    print("Another location!");
    testClient.onReceive.transform(new Utf8Decoder()).transform(new LineSplitter()).listen((String data) { 
      print("Received > $data");
    });
    testClient.write(UTF8.encode("Hello!\n"));
  });
  print("Exit");
}