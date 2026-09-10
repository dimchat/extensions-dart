/* license: https://mit-license.org
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

import 'protocol/commands.dart';
import 'protocol/receipt.dart';
import 'protocol/groups.dart';

import 'dkd/base.dart';
import 'dkd/contents.dart';
import 'dkd/files.dart';
import 'dkd/assets.dart';
import 'dkd/combine.dart';
import 'dkd/quote.dart';
import 'dkd/array.dart';
import 'dkd/forward.dart';
import 'dkd/commands.dart';
import 'dkd/receipt.dart';
import 'dkd/groups.dart';

import 'dkd/cmd_fact.dart';
import 'msg/factory.dart';


/// Message factory extensions.
///
/// Registers the default factories for messages, contents, commands
/// and their subtypes, so that they can be parsed by type automatically.
mixin MessageFactoryExtensions {

  /// Register the default message factories.
  ///
  /// Sets a single [MessageFactory] as the factory for
  /// [Envelope], [InstantMessage], [SecureMessage] and [ReliableMessage].
  // protected
  void registerMessageFactories() {

    // Envelope factory
    MessageFactory factory = MessageFactory();
    Envelope.setFactory(factory);

    // Message factories
    InstantMessage.setFactory(factory);
    SecureMessage.setFactory(factory);
    ReliableMessage.setFactory(factory);

  }

  /// Register the default content factories.
  ///
  /// Maps each [ContentType] to its concrete [Content] implementation.
  // protected
  void registerContentFactories() {

    // Text
    setContentFactory(ContentType.TEXT, creator: (dict) => BaseTextContent(dict));

    // File
    setContentFactory(ContentType.FILE, creator: (dict) => BaseFileContent(dict));
    // Image
    setContentFactory(ContentType.IMAGE, creator: (dict) => ImageFileContent(dict));
    // Audio
    setContentFactory(ContentType.AUDIO, creator: (dict) => AudioFileContent(dict));
    // Video
    setContentFactory(ContentType.VIDEO, creator: (dict) => VideoFileContent(dict));

    // Web Page
    setContentFactory(ContentType.PAGE, creator: (dict) => WebPageContent(dict));

    // Name Card
    setContentFactory(ContentType.NAME_CARD, creator: (dict) => NameCardContent(dict));

    // Quote
    setContentFactory(ContentType.QUOTE, creator: (dict) => BaseQuoteContent(dict));

    // Money
    setContentFactory(ContentType.MONEY, creator: (dict) => BaseMoneyContent(dict));
    setContentFactory(ContentType.TRANSFER, creator: (dict) => TransferMoneyContent(dict));
    // ...

    // Command
    setContentFactory(ContentType.COMMAND, factory: GeneralCommandFactory());

    // History Command
    setContentFactory(ContentType.HISTORY, factory: HistoryCommandFactory());

    // Content Array
    setContentFactory(ContentType.ARRAY, creator: (dict) => ListContent(dict));

    // Combine and Forward
    setContentFactory(ContentType.COMBINE_FORWARD, creator: (dict) => CombineForwardContent(dict));

    // Top-Secret
    setContentFactory(ContentType.FORWARD, creator: (dict) => SecretContent(dict));

    // unknown content type
    setContentFactory(ContentType.ANY, creator: (dict) => BaseContent(dict));

  }

  /// Register the default command factories.
  ///
  /// Maps each command name to its concrete [Command] implementation.
  // protected
  void registerCommandFactories() {

    // Meta Command
    setCommandFactory(MetaCommand.META,      creator: (dict) => BaseMetaCommand(dict));
    // Document Command
    setCommandFactory(DocumentCommand.DOCUMENTS, creator: (dict) => BaseDocumentCommand(dict));
    // Receipt Command
    setCommandFactory(ReceiptCommand.RECEIPT,   creator: (dict) => BaseReceiptCommand(dict));

    // Group Commands
    setCommandFactory('group', factory: GroupCommandFactory());
    setCommandFactory(GroupCommand.INVITE,  creator: (dict) => InviteGroupCommand(dict));
    /// 'expel' is deprecated (use 'reset' instead)
    setCommandFactory(GroupCommand.EXPEL,   creator: (dict) => ExpelGroupCommand(dict));
    setCommandFactory(GroupCommand.JOIN,    creator: (dict) => JoinGroupCommand(dict));
    setCommandFactory(GroupCommand.QUIT,    creator: (dict) => QuitGroupCommand(dict));
    /// 'query' is deprecated
    //setCommandFactory(GroupCommand.QUERY, creator: (dict) => QueryGroupCommand(dict));
    setCommandFactory(GroupCommand.RESET,   creator: (dict) => ResetGroupCommand(dict));

  }

  /// Register a content factory for the given [msgType].
  ///
  /// [msgType] is the content type, such as "text"/"image"/"file".
  /// [factory] is a custom [ContentFactory]; [creator] is a builder
  /// wrapped into a [ContentParser] which checks 'sn' before creating.
  // protected
  void setContentFactory(String msgType, {ContentFactory? factory, ContentCreator? creator}) {
    if (factory != null) {
      Content.setFactory(msgType, factory);
    }
    if (creator != null) {
      Content.setFactory(msgType, ContentParser(creator));
    }
  }

  /// Register a command factory for the given [cmd].
  ///
  /// [cmd] is the command name, such as "meta"/"documents"/"receipt".
  /// [factory] is a custom [CommandFactory]; [creator] is a builder
  /// wrapped into a [CommandParser] which checks 'sn'/'command' before creating.
  // protected
  void setCommandFactory(String cmd, {CommandFactory? factory, CommandCreator? creator}) {
    if (factory != null) {
      Command.setFactory(cmd, factory);
    }
    if (creator != null) {
      Command.setFactory(cmd, CommandParser(creator));
    }
  }

}


/// Builder function to create a [Content] from a raw map.
typedef ContentCreator = Content? Function(Mapping dict);

/// Builder function to create a [Command] from a raw map.
typedef CommandCreator = Command? Function(Mapping dict);

/// Content factory that builds content from a raw map.
///
/// Wraps a [ContentCreator] and verifies that the map contains
/// a 'sn' field before creating the content instance.
class ContentParser implements ContentFactory {
  ContentParser(this._builder);
  final ContentCreator _builder;

  @override
  Content? parseContent(Mapping content) {
    // check 'sn'
    if (!content.containsKey('sn')) {
      // content.sn should not be empty
      assert(false, 'content error: $content');
      return null;
    }
    return _builder(content);
  }

}

/// Command factory that builds command from a raw map.
///
/// Wraps a [CommandCreator] and verifies that the map contains
/// both 'sn' and 'command' fields before creating the command instance.
class CommandParser implements CommandFactory {
  CommandParser(this._builder);
  final CommandCreator _builder;

  @override
  Command? parseCommand(Mapping content) {
    // check 'sn', 'command'
    if (!content.containsKey('sn') || !content.containsKey('command')) {
      // content.sn should not be empty
      // content.command should not be empty
      assert(false, 'command error: $content');
      return null;
    }
    return _builder(content);
  }

}
