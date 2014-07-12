import 'dart:io';
import 'dart:convert';
int port = 3738;
void main () {
  print("Basic TCP Echo Server Starting on port $port");
  ServerSocket.bind("127.0.0.1", port).then((ServerSocket socket) { 
    socket.listen((Socket client) { 
      print("New Client ${client.address}");
      client.transform(new Utf8Decoder()).transform(new LineSplitter()).listen((String response) { 
        print("< $response");
        print("Echoed Back");
        client.add(UTF8.encode("$response\n"));        
      });
    });    
  });
}