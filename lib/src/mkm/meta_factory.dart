/* license: https://mit-license.org
 *
 *  Ming-Ke-Ming : Decentralized User Identity Authentication
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
import 'package:dimp/mkm.dart';
import 'package:dimp/ext.dart';

import '../protocol/version.dart';

import 'btc.dart';
import 'eth.dart';
import 'meta.dart';


///  Default Meta to build ID with 'name@address'
///
///  version:
///      1 = MKM
///
///  algorithm:
///      CT      = fingerprint = sKey.sign(seed);
///      hash    = ripemd160(sha256(CT));
///      code    = sha256(sha256(network + hash)).prefix(4);
///      address = base58_encode(network + hash + code);
class DefaultMeta extends BaseMeta {
  DefaultMeta([super.dict]);

  DefaultMeta.from(String type, VerifyKey key, String seed, TransportableData fingerprint)
      : super.fromType(type, key, seed: seed, fingerprint: fingerprint);

  @override
  bool get hasSeed => true;

  @override
  Address generateAddress(int? network) {
    // assert(type == Meta.MKM || type == '1', 'meta type error: $type');
    assert(network != null, 'address type should not be empty');
    var data = fingerprint?.bytes;
    assert(data != null && data.isNotEmpty, 'meta.fingerprint empty');
    // generate BTC address with fingerprint
    return BTCAddress.generate(data!, network!);
  }

}


///  Meta to build BTC address for ID
///
///  version:
///      2 = BTC
///
///  algorithm:
///      CT      = key.data;
///      hash    = ripemd160(sha256(CT));
///      code    = sha256(sha256(network + hash)).prefix(4);
///      address = base58_encode(network + hash + code);
class BTCMeta extends BaseMeta {
  BTCMeta([super.dict]);

  BTCMeta.from(String type, VerifyKey key, {String? seed, TransportableData? fingerprint})
      : super.fromType(type, key, seed: seed, fingerprint: fingerprint);

  @override
  bool get hasSeed => false;

  @override
  Address generateAddress(int? network) {
    // assert(type == Meta.BTC || type == '2', 'meta type error: $type');
    assert(network != null, 'address type should not be empty');
    VerifyKey key = publicKey;
    // TODO: compress public key?
    var data = key.data.bytes;
    assert(data != null && data.isNotEmpty, 'key data empty');
    // generate BTC address with public key data
    return BTCAddress.generate(data!, network!);
  }
}


///  Meta to build ETH address for ID
///
///  version:
///      4 = ETH
///
///  algorithm:
///      CT      = key.data;  // without prefix byte
///      digest  = keccak256(CT);
///      address = hex_encode(digest.suffix(20));
class ETHMeta extends BaseMeta {
  ETHMeta([super.dict]);

  ETHMeta.from(String type, VerifyKey key, {String? seed, TransportableData? fingerprint})
      : super.fromType(type, key, seed: seed, fingerprint: fingerprint);

  @override
  bool get hasSeed => false;

  @override
  Address generateAddress(int? network) {
    assert(type == MetaType.ETH || type == '4', 'meta type error: $type');
    assert(network == EntityType.USER, 'address type error: $network');
    VerifyKey key = publicKey;
    // 64 bytes key data without prefix 0x04
    var data = key.data.bytes;
    assert(data != null && data.isNotEmpty, 'key data empty');
    // generate ETH address with public key data
    return ETHAddress.generate(data!);
  }
}


/// Base meta factory.
///
/// Creates/parses metas by [type] (mkm/btc/eth/...).
class BaseMetaFactory implements MetaFactory {

  /// Create factory for the given meta [type].
  BaseMetaFactory(this.type);

  // protected
  final String type;

  @override
  Meta generateMeta(SignKey sKey, {String? seed}) {
    TransportableData? fingerprint;
    if (seed == null || seed.isEmpty) {
      fingerprint = null;
    } else {
      Uint8List data = UTF8.encode(seed);
      Uint8List sig = sKey.sign(data);
      fingerprint = TransportableData.create(sig);
    }
    VerifyKey pKey = (sKey as PrivateKey).publicKey;
    return createMeta(pKey, seed: seed, fingerprint: fingerprint);
  }

  @override
  Meta createMeta(VerifyKey pKey, {String? seed, TransportableData? fingerprint}) {
    Meta out;
    switch (type) {

      case MetaType.MKM:
        out = DefaultMeta.from(type, pKey, seed!, fingerprint!);
        break;

      case MetaType.BTC:
        out = BTCMeta.from(type, pKey);
        break;

      case MetaType.ETH:
        out = ETHMeta.from(type, pKey);
        break;

      default:
        throw Exception('unknown meta type: $type');
    }
    assert(out.isValid, 'meta error: $out');
    return out;
  }

  @override
  Meta? parseMeta(Mapping meta) {
    // check 'type', 'key', 'seed', 'fingerprint'
    if (!meta.containsKey('type') || !meta.containsKey('key')) {
      // meta.type should not be empty
      // meta.key should not be empty
      assert(false, 'meta error: $meta');
      return null;
    } else if (!meta.containsKey('seed')) {
      if (meta.containsKey('fingerprint')) {
        assert(false, 'meta error: $meta');
        return null;
      }
    } else if (!meta.containsKey('fingerprint')) {
      assert(false, 'meta error: $meta');
      return null;
    }
    final helper = sharedAccountExtensions.handler;
    // create meta for type
    Meta out;
    String? version = helper?.getMetaType(meta, '');
    switch (version) {

      case MetaType.MKM:
        out = DefaultMeta(meta);
        break;

      case MetaType.BTC:
        out = BTCMeta(meta);
        break;

      case MetaType.ETH:
        out = ETHMeta(meta);
        break;

      default:
        throw Exception('unknown meta type: $version');
    }
    if (out.isValid) {
      return out;
    }
    assert(false, 'meta error: $meta');
    return null;
  }

}
