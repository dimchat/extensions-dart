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
import 'package:dimp/crypto.dart';
import 'package:dimp/mkm.dart';
import 'package:dimp/ext.dart';

/// Account GeneralFactory
class AccountGeneralFactory implements GeneralAccountHelper,
                                       AddressHelper, IDHelper,
                                       MetaHelper, DocumentHelper {

  AddressFactory?                    _addressFactory;
  IDFactory?                         _idFactory;
  final Map<String, MetaFactory>     _metaFactories = {};
  final Map<String, DocumentFactory> _docsFactories = {};

  @override
  String? getMetaType(Mapping meta, [String? defaultValue]) {
    return Converter.getString(meta['type'], defaultValue);
  }

  @override
  String? getDocumentType(Mapping doc, [String? defaultValue]) {
    final docType = doc['type'];
    if (docType != null) {
      return Converter.getString(docType, defaultValue);
    } else if (defaultValue != null) {
      return defaultValue;
    }
    // get type for did
    final did = getDocumentID(doc);
    if (did == null) {
      assert(false, 'document error: $doc');
      return null;
    } else if (did.isUser) {
      return DocumentType.VISA;
    } else if (did.isGroup) {
      return DocumentType.BULLETIN;
    } else {
      return DocumentType.PROFILE;
    }
  }

  @override
  ID? getDocumentID(Mapping doc) {
    return ID.parse(doc['did']);
  }

  // protected
  MutableMapping? getMap(Object dict) {
    Map? info = Wrapper.getMap(dict);
    return info?.asMutableMapping();
  }

  // protected
  String getString(Object str) {
    String? text = Wrapper.getString(str);
    return text ?? '';
  }

  ///
  ///   Address
  ///

  @override
  void setAddressFactory(AddressFactory factory) {
    _addressFactory = factory;
  }

  @override
  AddressFactory? getAddressFactory() {
    return _addressFactory;
  }

  @override
  Address? parseAddress(Object? address) {
    if (address == null) {
      return null;
    } else if (address is Address) {
      return address;
    }
    final text = getString(address);
    if (text.isEmpty) {
      assert(false, 'address error: $address');
      return null;
    }
    AddressFactory? factory = getAddressFactory();
    assert(factory != null, 'address factory not ready');
    return factory?.parseAddress(text);
  }

  @override
  Address generateAddress(Meta meta, int? network) {
    AddressFactory? factory = getAddressFactory();
    assert(factory != null, 'address factory not ready');
    return factory!.generateAddress(meta, network);
  }

  ///
  ///   ID
  ///

  @override
  void setIDFactory(IDFactory factory) {
    _idFactory = factory;
  }

  @override
  IDFactory? getIDFactory() {
    return _idFactory;
  }

  @override
  ID? parseID(Object? identifier) {
    if (identifier == null) {
      return null;
    } else if (identifier is ID) {
      return identifier;
    }
    String? text = getString(identifier);
    if (text.isEmpty) {
      assert(false, 'ID error: $identifier');
      return null;
    }
    IDFactory? factory = getIDFactory();
    assert(factory != null, 'ID factory not ready');
    return factory?.parseID(text);
  }

  @override
  ID createID({String? name, required Address address, String? terminal}) {
    IDFactory? factory = getIDFactory();
    assert(factory != null, 'ID factory not ready');
    return factory!.createID(name: name, address: address, terminal: terminal);
  }

  @override
  ID generateID(Meta meta, int? network) {
    IDFactory? factory = getIDFactory();
    assert(factory != null, 'ID factory not ready');
    return factory!.generateID(meta, network);
  }

  ///
  ///   Meta
  ///

  @override
  void setMetaFactory(String type, MetaFactory factory) {
    _metaFactories[type] = factory;
  }

  @override
  MetaFactory? getMetaFactory(String type) {
    return _metaFactories[type];
  }

  @override
  Meta createMeta(String type, VerifyKey pKey, {String? seed, TransportableData? fingerprint}) {
    MetaFactory? factory = getMetaFactory(type);
    assert(factory != null, 'meta type not supported: $type');
    return factory!.createMeta(pKey, seed: seed, fingerprint: fingerprint);
  }

  @override
  Meta generateMeta(String type, SignKey sKey, {String? seed}) {
    MetaFactory? factory = getMetaFactory(type);
    assert(factory != null, 'meta type not supported: $type');
    return factory!.generateMeta(sKey, seed: seed);
  }

  @override
  Meta? parseMeta(Object? meta) {
    if (meta == null) {
      return null;
    } else if (meta is Meta) {
      return meta;
    }
    MutableMapping? info = getMap(meta);
    if (info == null) {
      assert(false, 'meta error: $meta');
      return null;
    }
    String? type = getMetaType(info);
    assert(type != null, 'meta error: $meta');
    MetaFactory? factory = type == null ? null : getMetaFactory(type);
    if (factory == null) {
      // unknown meta type, get default meta factory
      factory = getMetaFactory('*');  // unknown
      assert(factory != null, 'default meta factory not found');
    }
    return factory?.parseMeta(info);
  }

  //
  //  Document
  //

  @override
  void setDocumentFactory(String docType, DocumentFactory factory) {
    _docsFactories[docType] = factory;
  }

  @override
  DocumentFactory? getDocumentFactory(String docType) {
    return _docsFactories[docType];
  }

  @override
  Document createDocument(String docType, {String? data, TransportableData? signature}) {
    DocumentFactory? factory = getDocumentFactory(docType);
    assert(factory != null, 'document type not supported: $docType');
    return factory!.createDocument(data: data, signature: signature);
  }

  @override
  Document? parseDocument(Object? doc) {
    if (doc == null) {
      return null;
    } else if (doc is Document) {
      return doc;
    }
    MutableMapping? info = getMap(doc);
    if (info == null) {
      assert(false, 'document error: $doc');
      return null;
    }
    String? type = getDocumentType(info);
    //assert(type != null, 'document error: $doc');
    DocumentFactory? factory = type == null ? null : getDocumentFactory(type);
    if (factory == null) {
      // unknown document type, get default document factory
      factory = getDocumentFactory('*');  // unknown
      assert(factory != null, 'default document factory not found');
    }
    return factory?.parseDocument(info);
  }

}
