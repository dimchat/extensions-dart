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
import 'package:dimp/protocol.dart';

import '../protocol/groups.dart';
import '../dkd/base.dart';


class BaseHistoryCommand extends BaseCommand implements HistoryCommand {

  /// Create history command with a raw map.
  ///
  /// [dict] is the raw command map.
  BaseHistoryCommand([super.dict]);

  /// Create history command with the given command [cmd].
  BaseHistoryCommand.fromCmd(String cmd)
      : super.fromType(ContentType.HISTORY, cmd);
}


class BaseGroupCommand extends BaseHistoryCommand implements GroupCommand {

  /// Create group command with a raw map.
  ///
  /// [dict] is the raw command map.
  BaseGroupCommand([super.dict]);

  /// Create group command with the given [cmd], [group] and [members].
  ///
  /// [cmd] is the group command name; [group] is the group ID;
  /// [members] are the member IDs (optional).
  BaseGroupCommand.fromCmd(String cmd, ID group, {List<ID>? members})
      : super.fromCmd(cmd) {
    this.group = group;
    if (members != null) {
      this.members = members;
    }
  }

  @override
  List<ID>? get members {
    var array = this['members'];
    if (array is List) {
      // convert all items to ID objects
      return ID.convert(array);
    }
    // get from 'member'
    ID? single = ID.parse(this['member']);
    assert(single != null, 'failed to get group members');
    return single == null ? [] : [single];
  }

  @override
  set members(List<ID>? users) {
    if (users == null) {
      remove('members');
    } else {
      this['members'] = ID.revert(users);
    }
    remove('member');
  }

}


class InviteGroupCommand extends BaseGroupCommand implements InviteCommand {

  /// Create invite command with a raw map.
  ///
  /// [dict] is the raw command map.
  InviteGroupCommand([super.dict]);

  /// Create invite command with the given [group] and [members].
  ///
  /// [group] is the group ID; [members] are the member IDs to invite.
  InviteGroupCommand.from(ID group, {List<ID>? members})
      : super.fromCmd(GroupCommand.INVITE, group, members: members);

  @override
  String get welcome => getString('text') ?? '';
}


///
/// ExpelCommand (Deprecated, use 'reset' instead)
///
class ExpelGroupCommand extends BaseGroupCommand implements ExpelCommand {

  /// Create expel command with a raw map.
  ///
  /// [dict] is the raw command map.
  ExpelGroupCommand([super.dict]);

  /// Create expel command with the given [group] and [members].
  ///
  /// [group] is the group ID; [members] are the member IDs to expel.
  ExpelGroupCommand.from(ID group, {List<ID>? members})
      : super.fromCmd(GroupCommand.EXPEL, group, members: members);

  @override
  String get away => getString('text') ?? '';
}


class JoinGroupCommand extends BaseGroupCommand implements JoinCommand {

  /// Create join command with a raw map.
  ///
  /// [dict] is the raw command map.
  JoinGroupCommand([super.dict]);

  /// Create join command with the given [group].
  JoinGroupCommand.from(ID group) : super.fromCmd(GroupCommand.JOIN, group);

  @override
  String get ask => getString('text') ?? '';
}


class QuitGroupCommand extends BaseGroupCommand implements QuitCommand {

  /// Create quit command with a raw map.
  ///
  /// [dict] is the raw command map.
  QuitGroupCommand([super.dict]);

  /// Create quit command with the given [group].
  QuitGroupCommand.from(ID group) : super.fromCmd(GroupCommand.QUIT, group);

  @override
  String get bye => getString('text') ?? '';
}


class ResetGroupCommand extends BaseGroupCommand implements ResetCommand {

  /// Create reset command with a raw map.
  ///
  /// [dict] is the raw command map.
  ResetGroupCommand([super.dict]);

  /// Create reset command with the given [group] and [members].
  ///
  /// [group] is the group ID; [members] are all members after reset.
  ResetGroupCommand.from(ID group, {required List<ID> members})
      : super.fromCmd(GroupCommand.RESET, group, members: members);

  @override
  String get confirm => getString('text') ?? '';
}
