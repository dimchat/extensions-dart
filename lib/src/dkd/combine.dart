/* license: https://mit-license.org
 *
 *  DIMP : Decentralized Instant Messaging Protocol
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
import 'package:dimp/crypto.dart';
import 'package:dimp/dkd.dart' hide CombineContent, CombineForwardContent;

import '../protocol/combine.dart';


/// CombineContent
class CombineForwardContent extends BaseContent implements CombineContent {
  CombineForwardContent([super.dict]);

  List<InstantMessage>? _history;

  CombineForwardContent.fromTitle(String title, List<InstantMessage> messages)
      : super.fromType(ContentType.COMBINE_FORWARD) {
    // chat name
    this['title'] = title;
    // chat history
    _history = messages;
    // this['messages'] = InstantMessage.revert(messages);
  }

  @override
  MutableMapping<String, dynamic> toMap() {
    // serialize 'messages' messages
    var messages = _history;
    if (messages != null && !containsKey('messages')) {
      this['messages'] = InstantMessage.revert(messages);
    }
    // OK
    return super.toMap();
  }

  @override
  String get title => getString('title') ?? '';

  @override
  List<InstantMessage> get messages {
    List<InstantMessage>? array = _history;
    if (array == null) {
      var info = this['messages'];
      if (info is List) {
        array = InstantMessage.convert(info);
      } else {
        assert(info == null, 'combined messages error: $info');
        array = [];
      }
      _history = array;
    }
    return array;
  }

}
