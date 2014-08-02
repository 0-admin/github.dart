// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library http_multi_server;

import 'dart:async';
import 'dart:io';

import 'src/utils.dart';

/// An implementation of `dart:io`'s [HttpServer] that wraps multiple servers
/// and forwards methods to all of them.
///
/// This is useful for serving the same application on multiple network
/// interfaces while still having a unified way of controlling the servers. In
/// particular, it supports serving on both the IPv4 and IPv6 loopback addresses
/// using [HttpMultiServer.loopback].
class HttpMultiServer extends StreamView<HttpRequest> implements HttpServer {
  /// The wrapped servers.
  final Set<HttpServer> _servers;

  String get serverHeader => _servers.first.serverHeader;
  set serverHeader(String value) {
    for (var server in _servers) {
      server.serverHeader = value;
    }
  }

  Duration get idleTimeout => _servers.first.idleTimeout;
  set idleTimeout(Duration value) {
    for (var server in _servers) {
      server.idleTimeout = value;
    }
  }

  /// Returns the port that one of the wrapped servers is listening on.
  ///
  /// If the wrapped servers are listening on different ports, it's not defined
  /// which port is returned.
  int get port => _servers.first.port;

  /// Returns the address that one of the wrapped servers is listening on.
  ///
  /// If the wrapped servers are listening on different addresses, it's not
  /// defined which address is returned.
  InternetAddress get address => _servers.first.address;

  set sessionTimeout(int value) {
    for (var server in _servers) {
      server.sessionTimeout = value;
    }
  }

  /// Creates an [HttpMultiServer] wrapping [servers].
  ///
  /// All [servers] should have the same configuration and none should be
  /// listened to when this is called.
  HttpMultiServer(Iterable<HttpServer> servers)
      : _servers = servers.toSet(),
        super(mergeStreams(servers));

  /// Creates an [HttpServer] listening on all available loopback addresses for
  /// this computer.
  ///
  /// If this computer supports both IPv4 and IPv6, this returns an
  /// [HttpMultiServer] listening to [port] on both loopback addresses.
  /// Otherwise, it returns a normal [HttpServer] listening only on the IPv4
  /// address.
  ///
  /// If [port] is 0, the same ephemeral port is used for both the IPv4 and IPv6
  /// addresses.
  static Future<HttpServer> loopback(int port, {int backlog}) {
    if (backlog == null) backlog = 0;

    return _loopback(port, (address, port) =>
        HttpServer.bind(address, port, backlog: backlog));
  }

  /// Like [loopback], but supports HTTPS requests.
  ///
  /// The certificate with nickname or distinguished name (DN) [certificateName]
  /// is looked up in the certificate database, and is used as the server
  /// certificate. If [requestClientCertificate] is true, the server will
  /// request clients to authenticate with a client certificate.
  static Future<HttpServer> loopbackSecure(int port, {int backlog,
      String certificateName, bool requestClientCertificate: false}) {
    if (backlog == null) backlog = 0;

    return _loopback(port, (address, port) =>
        HttpServer.bindSecure(address, port, backlog: backlog,
            certificateName: certificateName,
            requestClientCertificate: requestClientCertificate));
  }

  /// A helper method for initializing loopback servers.
  ///
  /// [bind] should forward to either [HttpServer.bind] or
  /// [HttpServer.bindSecure].
  static Future<HttpServer> _loopback(int port,
      Future<HttpServer> bind(InternetAddress address, int port)) {
    return bind(InternetAddress.LOOPBACK_IP_V4, port).then((v4Server) {
      // Reuse the IPv4 server's port so that if [port] is 0, both servers use
      // the same ephemeral port.
      return bind(InternetAddress.LOOPBACK_IP_V6, v4Server.port)
          .then((v6Server) => new HttpMultiServer([v4Server, v6Server]))
          .catchError((error) {
        // If we fail to bind to IPv6, just use IPv4.
        if (error is SocketException) return v4Server;
        throw error;
      });
    });
  }

  Future close({bool force: false}) =>
      Future.wait(_servers.map((server) => server.close(force: force)));

  /// Returns an HttpConnectionsInfo object summarizing the total number of
  /// current connections handled by all the servers.
  HttpConnectionsInfo connectionsInfo() {
    var info = new HttpConnectionsInfo();
    for (var server in _servers) {
      var subInfo = server.connectionsInfo();
      info.total += subInfo.total;
      info.active += subInfo.active;
      info.idle += subInfo.idle;
      info.closing += subInfo.closing;
    }
    return info;
  }
}