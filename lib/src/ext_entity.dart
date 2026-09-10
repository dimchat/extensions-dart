/* license: https://mit-license.org
 * ==============================================================================
 * The MIT License (MIT)
 *
 * Copyright (c) 2026 Albert Moky
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

import 'protocol/version.dart';
import 'mkm/address_factory.dart';
import 'mkm/document_factory.dart';
import 'mkm/id_factory.dart';
import 'mkm/meta_factory.dart';


/// Entity extensions.
///
/// Registers the default factories for address, ID, meta and document,
/// so that entities can be created/parsed by type automatically.
mixin EntityExtensions {

  /// Register the default [IDFactory].
  ///
  /// Sets [IdentifierFactory] as the global ID factory.
  // protected
  void registerIDFactory() {

    ID.setFactory(IdentifierFactory());

  }

  /// Register the default [AddressFactory].
  ///
  /// Sets [BaseAddressFactory] as the global address factory.
  // protected
  void registerAddressFactory() {

    Address.setFactory(BaseAddressFactory());

  }

  /// Register the default meta factories (MKM/BTC/ETH).
  // protected
  void registerMetaFactories() {

    setMetaFactory(MetaType.MKM);
    setMetaFactory(MetaType.BTC);
    setMetaFactory(MetaType.ETH);

  }

  /// Register a meta factory for the given [type].
  ///
  /// [type] is the meta algorithm type, such as "mkm"/"btc"/"eth".
  /// [factory] is the factory instance; if null, a new
  /// [BaseMetaFactory] for [type] will be created.
  // protected
  void setMetaFactory(String type, {MetaFactory? factory}) {
    factory ??= BaseMetaFactory(type);
    Meta.setFactory(type, factory);
  }

  /// Register the default document factories.
  ///
  /// Registers factories for VISA, PROFILE, BULLETIN and the
  /// wildcard type '*' (fallback for unknown document types).
  // protected
  void registerDocumentFactories() {

    setDocumentFactory('*');
    setDocumentFactory(DocumentType.VISA);
    setDocumentFactory(DocumentType.PROFILE);
    setDocumentFactory(DocumentType.BULLETIN);

  }

  /// Register a document factory for the given [type].
  ///
  /// [type] is the document type, such as "visa"/"profile"/"bulletin";
  /// use '*' to register the default factory for unknown types.
  /// [factory] is the factory instance; if null, a new
  /// [GeneralDocumentFactory] for [type] will be created.
  // protected
  void setDocumentFactory(String type, {DocumentFactory? factory}) {
    factory ??= GeneralDocumentFactory(type);
    Document.setFactory(type, factory);
  }

}
