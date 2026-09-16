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

import 'package:dimp/crypto.dart';
import 'package:dimp/protocol.dart';
import 'package:dimp/dkd.dart';
import 'package:dimp/msg.dart';


/// InstantMessage Factory
class GeneralInstantMessageFactory implements InstantMessageFactory {

  /// Initialize the factory with a random starting serial number.
  GeneralInstantMessageFactory() {
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

}
