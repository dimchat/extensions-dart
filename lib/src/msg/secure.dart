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
import 'dart:typed_data';

import 'package:dimp/crypto.dart';
import 'package:dimp/protocol.dart';
import 'package:dimp/dkd.dart';
import 'package:dimp/msg.dart';
import 'package:dimp/ext.dart';


/// SecureMessage Factory
class GeneralSecureMessageFactory implements SecureMessageFactory {

  @override
  SecureMessage createSecureMessage(InstantMessage iMsg, Uint8List ciphertext, Map<ID, EncryptedBundle>? keyBundles) {
    final helper = sharedMessageExtensions.handler;
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
      msgKeys = {};
      assert(!helper.isBroadcast(iMsg), 'broadcast message should not contains keys: $iMsg');
      keyBundles.forEach((ID receiver, EncryptedBundle bundle) {
        final encodedKeys = bundle.encode(receiver);
        if (encodedKeys.isEmpty) {
          assert(false, 'failed to encode key data: $receiver');
          return;
        }
        msgKeys!.addAll(encodedKeys);
      });
    }
    MutableMapping info = iMsg.toMap();
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

}
