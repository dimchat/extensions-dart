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


/// ReliableMessage Factory
class GeneralReliableMessageFactory implements ReliableMessageFactory {

  @override
  ReliableMessage createReliableMessage(SecureMessage sMsg, Uint8List signature) {
    //
    //  1. encode signature
    //
    TransportableData base64 = TransportableData.create(signature);
    assert(base64.isNotEmpty, 'failed to encode signature: ${signature.length} byte(s)'
        ' ${sMsg.sender} => ${sMsg.receiver}, ${sMsg.group}');
    //
    //  2. create message
    //
    MutableMapping info = sMsg.toMap();
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
