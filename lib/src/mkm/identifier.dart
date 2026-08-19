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
import 'package:dimp/mkm.dart';
import 'package:dimp/ext.dart';

import '../mem/ext.dart';


///
/// General ID Factory
/// ~~~~~~~~~~~~~~~~~~
///
class IdentifierFactory implements IDFactory {

  @override
  ID generateID(Meta meta, int? network) {
    Address address = Address.generate(meta, network);
    return ID.create(name: meta.seed, address: address);
  }

  @override
  ID createID({String? name, required Address address, String? terminal}) {
    String identifier = Identifier.concat(name: name, address: address, terminal: terminal);
    var cache = sharedAccountExtensions.idCache;
    ID? did = cache.get(identifier);
    if (did == null) {
      did = newID(identifier, name: name, address: address, terminal: terminal);
      cache.put(identifier, did);
    }
    return did;
  }

  @override
  ID? parseID(String identifier) {
    var cache = sharedAccountExtensions.idCache;
    ID? did = cache.get(identifier);
    if (did == null) {
      did = parse(identifier);
      if (did != null) {
        cache.put(identifier, did);
      }
    }
    return did;
  }

  // protected
  ID newID(String identifier, {String? name, required Address address, String? terminal}) {
    /// override for customized ID
    return Identifier(identifier, name: name, address: address, terminal: terminal);
  }

  // protected
  ID? parse(String identifier) {
    // split for "terminal"
    List<String> pair = identifier.split('/');
    int cnt = pair.length;
    String? terminal = cnt == 1 ? null : pair.last;
    // split for "name" @ "address"
    pair = pair.first.split('@');
    cnt = pair.length;
    String? name = cnt == 1 ? null : pair.first;
    Address? address = Address.parse(pair.last);
    // done
    if (address == null) {
      assert(false, 'cannot get address from ID: $identifier');
      return null;
    }
    return newID(identifier, name: name, address: address, terminal: terminal);
  }
}
