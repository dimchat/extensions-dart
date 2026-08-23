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
import 'package:dimp/ext.dart';


/// Format GeneralFactory
/// ~~~~~~~~~~~~~~~~~~~~~

class FormatGeneralFactory implements TransportableFileHelper,
    TransportableDataHelper {

  TransportableDataFactory? _tedFactory;

  TransportableFileFactory? _pnfFactory;

  // protected
  String getString(Object str) {
    String? text = Wrapper.getString(str);
    return text ?? '';
  }

  ///
  ///   TED - Transportable Encoded Data
  ///

  @override
  void setTransportableDataFactory(TransportableDataFactory factory) {
    _tedFactory = factory;
  }

  @override
  TransportableDataFactory? getTransportableDataFactory() {
    return _tedFactory;
  }

  @override
  TransportableData? parseTransportableData(Object? ted) {
    if (ted == null) {
      return null;
    } else if (ted is TransportableData) {
      return ted;
    }
    // unwrap
    String text = getString(ted);
    if (text.isEmpty) {
      assert(false, 'TED error: $ted');
      return null;
    }
    final factory = getTransportableDataFactory();
    assert(factory != null, 'default TED factory not found');
    return factory?.parseTransportableData(text);
  }

  ///
  ///   PNF - Portable Network File
  ///

  @override
  void setTransportableFileFactory(TransportableFileFactory factory) {
    _pnfFactory = factory;
  }

  @override
  TransportableFileFactory? getTransportableFileFactory() {
    return _pnfFactory;
  }

  @override
  TransportableFile createTransportableFile(TransportableData? data, String? filename,
      Uri? url, DecryptKey? password) {
    TransportableFileFactory? factory = getTransportableFileFactory();
    assert(factory != null, 'PNF factory not ready');
    return factory!.createTransportableFile(data, filename, url, password);
  }

  @override
  TransportableFile? parseTransportableFile(Object? pnf) {
    if (pnf == null) {
      return null;
    } else if (pnf is TransportableFile) {
      return pnf;
    }
    // unwrap
    Mapping? info = getTransportableFileContent(pnf);
    if (info == null) {
      // assert(false, 'PNF error: $pnf');
      return null;
    }
    TransportableFileFactory? factory = getTransportableFileFactory();
    assert(factory != null, 'PNF factory not ready');
    return factory?.parseTransportableFile(info);
  }

  // protected
  Mapping? getTransportableFileContent(Object pnf) {
    if (pnf is Mapper) {
      return pnf.toMap();
    } else if (pnf is Map) {
      return pnf.asMapping();
    }
    String text = getString(pnf);
    if (text.length < 8) {
      // assert(false, 'PNF error: $pnf');
      return null;
    } else if (text.startsWith('{')) {
      // decode JSON string
      assert(text.endsWith('}'), 'PNF json error: $pnf');
      Map? info = JSONMap.decode(text);
      return info?.asMapping();
    }
    Map<String, dynamic> content = {};

    // 1. check for URL: 'http://...'
    int pos = text.indexOf('://');
    if (0 < pos && pos < 8) {
      content['URL'] = text;
      return content.asMapping();
    }

    content['data'] = text;
    // 2. check for data URI: 'data:image/jpeg;base64,...'
    UriData? uri = UriData.parse(text);
    // if (uri != null) {
    String? filename = uri.parameters['filename'];
    if (filename != null) {
      content['filename'] = filename;
    }
    // } else {
    //   // 3. check for Base-64 encoded string?
    // }

    return content.asMapping();
  }

}
