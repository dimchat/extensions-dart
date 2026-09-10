/* license: https://mit-license.org
 *
 *  Dao-Ke-Dao: Universal Message Module
 *
 *                                Written in 2023 by Moky <albert.moky@gmail.com>
 *
 * ==============================================================================
 * The MIT License (MIT)
 *
 * Copyright (c) 2023 Albert Moky
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * ==============================================================================
 */
import 'dart:math';
import 'dart:typed_data';

import 'package:dimp/crypto.dart';
import 'package:dimp/protocol.dart';
import 'package:dimp/msg.dart';

import 'package:dkd/dkd.dart';  // FIXME: upgrade 'dkd'


/// Message factory.
///
/// Unified factory for [Envelope], [InstantMessage],
/// [SecureMessage] and [ReliableMessage].

class MessageFactory implements EnvelopeFactory, InstantMessageFactory, SecureMessageFactory, ReliableMessageFactory {

  /// Initialize the factory with a random starting serial number.
  MessageFactory() {
    Random random = Random(DateTime.now().microsecondsSinceEpoch);
    _sn = random.nextInt(0x80000000);  // 0 ~ 0x7fffffff
  }

  int _sn = 0;

  /// Get the next serial number.
  ///
  /// Returns 1 ~ 2^31-1.
  /* synchronized */int _next() {
    assert(_sn >= 0, 'serial number error: $_sn');
    if (_sn < 0x7fffffff) {  // 2 ** 31 - 1
      _sn += 1;
    } else {
      _sn = 1;
    }
    return _sn;
  }

  ///
  /// EnvelopeFactory
  ///

  @override
  Envelope createEnvelope({required ID sender, required ID receiver, DateTime? time}) {
    return MessageEnvelope.from(sender: sender, receiver: receiver, time: time);
  }

  @override
  Envelope? parseEnvelope(Mapping env) {
    // check 'sender'
    if (!env.containsKey('sender')) {
      // env.sender should not empty
      assert(false, 'envelope error: $env');
      return null;
    }
    return MessageEnvelope(env);
  }

  ///
  /// InstantMessageFactory
  ///

  @override
  int generateSerialNumber(String? msgType, DateTime? now) {
    // because we must make sure all messages in a same chat box won't have
    // same serial numbers, so we can't use time-related numbers, therefore
    // the best choice is a totally random number, maybe.
    return _next();
  }

  @override
  InstantMessage createInstantMessage(Envelope head, Content body) {
    return PlainMessage.from(head, body);
  }

  @override
  InstantMessage? parseInstantMessage(Mapping msg) {
    // check 'sender', 'content'
    if (!msg.containsKey('sender') || !msg.containsKey('content')) {
      // msg.sender should not be empty
      // msg.content should not be empty
      assert(false, 'message error: $msg');
      return null;
    }
    return PlainMessage(msg);
  }

  ///
  /// SecureMessageFactory
  ///

  @override
  SecureMessage createSecureMessage(InstantMessage iMsg, Uint8List ciphertext,
      Map<ID, EncryptedBundle>? keyBundles) {
    var helper = sharedMessageExtensions.handler;
    TransportableData encodedData;
    if (helper!.isBroadcast(iMsg)) {
      encodedData = PlainData.createWithBytes(ciphertext);  // UTF8.decode(ciphertext)
    } else {
      encodedData = TransportableData.create(ciphertext);
    }
    assert(encodedData.isNotEmpty, 'failed to encode content data: ${ciphertext.length} byte(s)');
    Map<String, Object>? msgKeys;
    if (keyBundles == null) {
      msgKeys = null;
    } else {
      msgKeys = <String, Object>{};
      assert(!helper.isBroadcast(iMsg), 'broadcast message should not contains keys: $iMsg');
      keyBundles.forEach((ID receiver, EncryptedBundle bundle) {
        Map<String, Object>? encodedKeys = bundle.encode(receiver);
        if (encodedKeys.isEmpty) {
          assert(false, 'failed to encode key data: $receiver');
          return;
        }
        msgKeys!.addAll(encodedKeys);
      });
    }
    Map info = iMsg.toMap();
    info.remove('content');
    info['data'] = encodedData.serialize();
    if (msgKeys != null && msgKeys.isNotEmpty) {
      info['keys'] = msgKeys;
    }
    return EncryptedMessage(info);
  }

  @override
  SecureMessage? parseSecureMessage(Mapping msg) {
    // check 'sender', 'data'
    if (!msg.containsKey('sender') || !msg.containsKey('data')) {
      // msg.sender should not be empty
      // msg.data should not be empty
      assert(false, 'message error: $msg');
      return null;
    }
    // check 'signature'
    if (msg.containsKey('signature')) {
      return NetworkMessage(msg);
    }
    return EncryptedMessage(msg);
  }

  ///
  /// ReliableMessageFactory
  ///

  @override
  ReliableMessage createReliableMessage(SecureMessage sMsg, Uint8List signature) {
    //
    //  1. encode signature
    //
    TransportableData base64 = TransportableData.create(signature);
    assert(base64.isNotEmpty, 'failed to encode signature: ${signature.length} byte(s) '
        '${sMsg.sender} => ${sMsg.receiver}, ${sMsg.group}');
    //
    //  2. create message
    //
    Map info = sMsg.toMap();
    info['signature'] = base64.serialize();
    return NetworkMessage(info);
  }

  @override
  ReliableMessage? parseReliableMessage(Mapping msg) {
    // check 'sender', 'data', 'signature',
    if (!msg.containsKey('sender') || !msg.containsKey('data') || !msg.containsKey('signature')) {
      // msg.sender should not be empty
      // msg.data should not be empty
      // msg.signature should not be empty
      assert(false, 'message error: $msg');
      return null;
    }
    return NetworkMessage(msg);
  }
}
