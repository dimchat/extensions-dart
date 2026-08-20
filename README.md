# DIM Application eXtensions (Dart)

[![License](https://img.shields.io/github/license/dimchat/extensions-dart)](https://github.com/dimchat/extensions-dart/blob/main/LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/dimchat/extensions-dart/pulls)
[![Platform](https://img.shields.io/badge/Platform-Dart%203-brightgreen.svg)](https://github.com/dimchat/extensions-dart/wiki)
[![Issues](https://img.shields.io/github/issues/dimchat/extensions-dart)](https://github.com/dimchat/extensions-dart/issues)
[![Repo Size](https://img.shields.io/github/repo-size/dimchat/extensions-dart)](https://github.com/dimchat/extensions-dart/archive/refs/heads/main.zip)
[![Tags](https://img.shields.io/github/tag/dimchat/extensions-dart)](https://github.com/dimchat/extensions-dart/tags)
[![Version](https://img.shields.io/pub/v/dimax)](https://pub.dev/packages/dimax)

[![Watchers](https://img.shields.io/github/watchers/dimchat/extensions-dart)](https://github.com/dimchat/extensions-dart/watchers)
[![Forks](https://img.shields.io/github/forks/dimchat/extensions-dart)](https://github.com/dimchat/extensions-dart/forks)
[![Stars](https://img.shields.io/github/stars/dimchat/extensions-dart)](https://github.com/dimchat/extensions-dart/stargazers)
[![Followers](https://img.shields.io/github/followers/dimchat)](https://github.com/orgs/dimchat/followers)

## Dependencies

* Latest Versions

| Name | Version | Description |
|------|---------|-------------|
| [Ming Ke Ming (名可名)](https://github.com/dimchat/mkm-dart) | [![Version](https://img.shields.io/pub/v/mkm)](https://pub.dev/packages/mkm) | Decentralized User Identity Authentication |
| [Dao Ke Dao (道可道)](https://github.com/dimchat/dkd-dart) | [![Version](https://img.shields.io/pub/v/dkd)](https://pub.dev/packages/dkd) | Universal Message Module |
| [DIMP (去中心化通讯协议)](https://github.com/dimchat/core-dart) | [![Version](https://img.shields.io/pub/v/dimp)](https://pub.dev/packages/dimp) | Decentralized Instant Messaging Protocol |

## Extensions

1. Account
   * Address
	   * BTC
	   * ETH
   * Meta
	   * MKM _(Default)_
	   * BTC
	   * ETH
   * Document
	   * Visa __(User)__
	   * Profile
	   * Bulletin __(Group)__
2. Message Contents
   * Text Content
   * File Content
	   * Image Content
	   * Audio Content
	   * Video Content
   * Page Content
   * Name Card
   * Quote Content
   * Money Content
	   * Transfer Money
   * Combine Forward
3. System Commands
   * Meta Command
   * Document Command
   * Receipt Command
   * History Command
   * Group Command
	   * Invite
	   * Expel
	   * Query
	   * Quit
	   * Join

## Examples

### Address

```dart
import 'package:dimp/crypto.dart';
import 'package:dimax/mkm.dart';
import 'package:dimax/ext.dart';


class CompatibleAddressFactory extends BaseAddressFactory {

  /// Call it when received 'UIApplicationDidReceiveMemoryWarningNotification',
  /// this will remove 50% of cached objects
  ///
  /// @return number of survivors
  int reduceMemory() {
    var cache = sharedAccountExtensions.addressCache;
    return cache.reduceMemory();
  }

  @override
  Address? parse(String address) {
    try {
      var res = super.parse(address);
      if (res != null) {
        return res;
      }
    } catch (e, st) {
      // FIXME:
      assert(false, 'invalid address: $address, error: $e, $st');
    }
    //
    //  TODO: parse for other types of address
    //
    int len = address.length;
    if (4 <= len && len <= 64) {
      return UnknownAddress(address);
    }
    assert(false, 'invalid address: $address');
    return null;
  }

}


/// Unsupported Address
/// ~~~~~~~~~~~~~~~~~~~
class UnknownAddress extends ConstantString implements Address {
  UnknownAddress(super.string);

  @override
  int get network => 0;  // EntityType.USER;

}
```

### Meta

```dart
import 'package:dimp/crypto.dart';
import 'package:dimp/mkm.dart';
import 'package:dimp/ext.dart';
import 'package:dimap/mkm.dart';


class CompatibleMetaFactory extends BaseMetaFactory {
  CompatibleMetaFactory(super.type);

  @override
  Meta? parseMeta(Map meta) {
    Meta out;
    var helper = sharedAccountExtensions.helper;
    String? version = helper?.getMetaType(meta);
    switch (version) {

      case 'MKM':
      case 'mkm':
      case '1':
        out = DefaultMeta(meta);
        break;

      case 'BTC':
      case 'btc':
      case '2':
        out = BTCMeta(meta);
        break;

      case 'ETH':
      case 'eth':
      case '4':
        out = ETHMeta(meta);
        break;

      default:
        // TODO: other types of meta
        throw Exception('unknown meta type: $type');
    }
    return out.isValid ? out : null;
  }

}
```

### ExtensionLoader

```dart
import 'package:dimp/dimp.dart';
import 'package:dimax/dimax.dart';

import 'compat/address.dart';
import 'compat/meta.dart';
import 'protocol/handshake.dart';
import 'protocol/customized.dart';


/// Extensions Loader
/// ~~~~~~~~~~~~~~~~~
class CommonExtensionLoader extends ExtensionLoader {

  @override
  void registerAddressFactory() {

    Address.setFactory(CompatibleAddressFactory());

  }

  @override
  void registerMetaFactories() {

    var mkm = CompatibleMetaFactory(Meta.MKM);
    var btc = CompatibleMetaFactory(Meta.BTC);
    var eth = CompatibleMetaFactory(Meta.ETH);

    Meta.setFactory('1', mkm);
    Meta.setFactory('2', btc);
    Meta.setFactory('4', eth);

    Meta.setFactory('mkm', mkm);
    Meta.setFactory('btc', btc);
    Meta.setFactory('eth', eth);

    Meta.setFactory('MKM', mkm);
    Meta.setFactory('BTC', btc);
    Meta.setFactory('ETH', eth);

  }

  @override
  void registerContentFactories() {
    super.registerContentFactories();

    registerCustomizedFactories();

  }

  void registerCustomizedFactories() {

    // Application Customized
    var factory = ContentParser((dict) => AppCustomizedContent(dict));
    setContentFactory(ContentType.APPLICATION, factory: factory);
    setContentFactory(ContentType.CUSTOMIZED, factory: factory);
    
  }

  @override
  void registerCommandFactories() {
    super.registerCommandFactories();

    // Handshake
    setCommandFactory(HandshakeCommand.HANDSHAKE, creator: (dict) => BaseHandshakeCommand(dict));

  }

}
```

You must ensure that every ```Address``` you extend has a ```Meta``` type that can correspond to it one by one.

----

Copyright &copy; 2018-2026 Albert Moky
[![Followers](https://img.shields.io/github/followers/moky)](https://github.com/moky?tab=followers)

