library tcpclient;

import "package:chrome/chrome_app.dart";
import "dart:async";

class TcpClient {
  int socketID;
  String address;
  int port;
  bool _paused = false;
  
  /// Listener for data receive events.
  Stream<List<int>> get onReceive => sockets.tcp.onReceive.where((ReceiveInfo recinf) { return recinf.socketId == this.socketID; }).transform(new StreamTransformer<ReceiveInfo,List<int>>
  (
      (Stream<ReceiveInfo> input, bool cancelOnError) {
        StreamController sc = new StreamController();
        input.listen((ReceiveInfo ri) {
          sc.add(ri.data.getBytes());
        }, onDone: sc.close, onError: sc.addError);
        return sc.stream.listen(null);
      }
  ));
  
  /// Listener for socket errors
  Stream<ReceiveErrorInfo> get onReceiveError => sockets.tcp.onReceiveError.where((ReceiveErrorInfo rei) { return rei.socketId == this.socketID; });
 
  bool get paused => _paused;
  
  set paused (bool value) { 
    if (_paused != value) { 
      this._setPaused(value);
    }
  }
   
  TcpClient (String this.address, int this.port);
  
  /***
   *  Connects to the specified [address] and [port]
   */
  Future<int> connect () {
    return sockets.tcp.create().then((CreateInfo ci) { 
      return this._onCreate(ci.socketId);
    });
  }
  Future _onCreate (int socketID)  {
      this.socketID = socketID;
      return sockets.tcp.connect(this.socketID, address, port).then((value) { 
        if (value >= 0) return value;
                 else throw new SocketConnectNetworkError(value);
      });
  }
  
 /***
  * Sends [data] down the TCP socket
  * @return {Future} Completes when data has been sucessfully sent, creates a SocketNotOpenError if method is called before the socket is created.
  */
 Future<SendInfo> write (List<int> data) {
   if (this.socketID != null) {
     return sockets.tcp.send(this.socketID, new ArrayBuffer.fromBytes(data));
   }
   else {
     return _errorFuture(new SocketNotOpenError());
   }
 }

 /***
  * Pauses the receive stream, used for throttling data
  */
 Future pause () {
    return this._setPaused(true);
 }
 
 /***
  * Resumes a paused receive stream
  */
 Future resume () {
   return this._setPaused(false);
 }
 
 /*** 
  * Disconnects the socket
  */
 void disconnect () {
   if (this.socketID != null) { 
     sockets.tcp.disconnect(this.socketID);
     this.socketID = null;
   }
   else {
     throw new SocketNotOpenError();
   }
 }
 
 Future<int> setKeepAlive (bool enable, [int delay = 0]) {
   return sockets.tcp.setKeepAlive(this.socketID, enable, delay).then((int value) {
     if (value >= 0) return value;
     else throw new SetKeepAliveNetworkError(value);
   });
 }
 
 
 Future<int> setNoDelay (bool noDelay) { 
    return sockets.tcp.setNoDelay(this.socketID, noDelay).then((int value) {
      if (value >= 0) return value;
           else throw new SetDelayNetworkError(value);
    });
 }
 
 Future _errorFuture (Error thrown) {
     Completer c = new Completer();
     c.completeError(thrown);
     return c.future;
 }
 
 Future _setPaused (bool shouldPause) {
   if (this.socketID != null) {
      return sockets.tcp.setPaused(this.socketID, shouldPause).then((s) { 
        this._paused = shouldPause;
      });
   }
   else { 
     return _errorFuture(new SocketNotOpenError());
   }
 }
}
abstract class NetworkError {
  int resultCode = 0;
  NetworkError(this.resultCode);
  toString() => "Network Error: ${resultCode}";
}
class SetDelayNetworkError extends NetworkError {
  SetDelayNetworkError(resultCode):super(resultCode);
}
class SetKeepAliveNetworkError extends NetworkError {
  SetKeepAliveNetworkError(resultCode):super(resultCode);
}
class SocketConnectNetworkError extends NetworkError {
  SocketConnectNetworkError(resultCode):super(resultCode);
}



class SocketNotOpenError extends Error {
 toString() => "Cannot write to unopened socket"; 
}