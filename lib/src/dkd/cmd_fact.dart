/* license: https://mit-license.org
 *
 *  Dao-Ke-Dao: Universal Message Module
 *
 *                               Written in 2023 by Moky <albert.moky@gmail.com>
 *
 * =============================================================================
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
 * =============================================================================
 */
import 'package:dimp/crypto.dart';
import 'package:dimp/dkd.dart';
import 'package:dimp/ext.dart';

import 'groups.dart';


///  General Command Factory
///  ~~~~~~~~~~~~~~~~~~~~~~~

class GeneralCommandFactory implements ContentFactory, CommandFactory {

  @override
  Content? parseContent(Mapping content) {
    GeneralCommandHelper? helper = sharedMessageExtensions.cmdHelper;
    CommandHelper? cmdHelper = sharedMessageExtensions.commandHelper;
    // get factory by command name
    String? cmd = helper?.getCmd(content);
    CommandFactory? factory = cmd == null ? null : cmdHelper?.getCommandFactory(cmd);
    if (factory == null) {
      // check for group command
      if (content.containsKey('group')/* && cmd != 'group'*/) {
        factory = cmdHelper?.getCommandFactory('group');
      }
      factory ??= this;
    }
    return factory.parseCommand(content);
  }

  @override
  Command? parseCommand(Mapping content) {
    // check 'sn', 'command'
    if (!content.containsKey('sn') || !content.containsKey('command')) {
      // content.sn should not be empty
      // content.command should not be empty
      assert(false, 'command error: $content');
      return null;
    }
    return BaseCommand(content);
  }

}


class HistoryCommandFactory extends GeneralCommandFactory {

  @override
  Command? parseCommand(Mapping content) {
    // check 'sn', 'command', 'time'
    if (!content.containsKey('sn') || !content.containsKey('command') || !content.containsKey('time')) {
      // content.sn should not be empty
      // content.command should not be empty
      // content.time should not be empty
      assert(false, 'command error: $content');
      return null;
    }
    return BaseHistoryCommand(content);
  }

}


class GroupCommandFactory extends HistoryCommandFactory {

  @override
  Content? parseContent(Mapping content) {
    GeneralCommandHelper? helper = sharedMessageExtensions.cmdHelper;
    CommandHelper? cmdHelper = sharedMessageExtensions.commandHelper;
    // get factory by command name
    String? cmd = helper?.getCmd(content);
    CommandFactory? factory = cmd == null ? null : cmdHelper?.getCommandFactory(cmd);
    factory ??= this;
    return factory.parseCommand(content);
  }

  @override
  Command? parseCommand(Mapping content) {
    // check 'sn', 'command', 'group'
    if (!content.containsKey('sn') || !content.containsKey('command') || !content.containsKey('group')) {
      // content.sn should not be empty
      // content.command should not be empty
      // content.group should not be empty
      assert(false, 'group command error: $content');
      return null;
    }
    return BaseGroupCommand(content);
  }

}
