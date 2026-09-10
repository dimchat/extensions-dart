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
import 'package:dimp/ext.dart';
import 'package:dimp/protocol.dart';


class BaseContent extends Dictionary implements Content {

  /// Create content with a raw map.
  ///
  /// [dict] is the raw content map, usually from network or storage.
  BaseContent([super.dict]);

  /// message type: text, image, ...
  String? _type;

  /// serial number: random number to identify message content
  int? _sn;

  /// message time
  DateTime? _time;

  /// Create content with the given [msgType].
  ///
  /// Generates a new serial number and message time automatically.
  BaseContent.fromType(String msgType) {
    DateTime now = DateTime.now();
    _type = msgType;
    _sn = InstantMessage.generateSerialNumber(msgType, now);
    _time = now;
    this['type'] = _type;
    this['sn'] = _sn;
    setDateTime('time', _time);
  }

  @override
  String get type {
    if (_type == null) {
      final helper = sharedMessageExtensions.handler;
      _type = helper!.getContentType(super.toMap()) ?? '';
      // _type = getInt('type', 0);
      assert(_type != null, 'message type error: ${super.toMap()}');
    }
    return _type ?? '';
  }

  @override
  int get sn {
    _sn ??= getInt('sn', 0);
    assert(_sn! > 0, 'serial number error: ${super.toMap()}');
    return _sn ?? 0;
  }

  @override
  DateTime? get time {
    _time ??= getDateTime('time');
    return _time;
  }

  @override
  ID? get group => ID.parse(this['group']);

  @override
  set group(ID? gid) => setString('group', gid);
}


class BaseCommand extends BaseContent implements Command  {

  /// Create command with a raw map.
  ///
  /// [dict] is the raw command map.
  BaseCommand([super.dict]);

  /// Create command with the given [msgType] and command [cmd].
  BaseCommand.fromType(String msgType, String cmd) : super.fromType(msgType) {
    this['command'] = cmd;
  }

  /// Create command with the given command [cmd].
  ///
  /// The message type will be set to [ContentType.COMMAND] automatically.
  BaseCommand.fromCmd(String cmd) : this.fromType(ContentType.COMMAND, cmd);

  @override
  String get cmd {
    final helper = sharedMessageExtensions.commandHandler;
    return helper!.getCmd(super.toMap()) ?? '';
    // return getString('command') ?? '';
  }
}
