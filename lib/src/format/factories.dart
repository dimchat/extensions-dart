/* license: https://mit-license.org
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

import 'pnf.dart';


class BaseNetworkDataFactory implements TransportableDataFactory {

  @override
  TransportableData? parseTransportableData(String ted) {
    // check data uri
    if (ted.startsWith('data:')) {
      // "data:image/jpeg;base64,..."
      var uri = UriData.parse(ted);
      return EmbedData.createWithUri(uri);
    }
    // TODO: check Base-64 format
    // "{BASE64_ENCODED}"
    return Base64Data.createWithString(ted);
  }

}


class BaseNetworkFileFactory implements TransportableFileFactory {

  @override
  TransportableFile createTransportableFile(TransportableData? data, String? filename,
      Uri? url, DecryptKey? password) {
    return PortableNetworkFile(null,
      data: data, filename: filename,
      url: url, password: password,
    );
  }

  @override
  TransportableFile? parseTransportableFile(Mapping pnf) {
    // check 'data', 'URL', 'filename'
    if (!pnf.containsKey('data') && !pnf.containsKey('URL') && !pnf.containsKey('filename')) {
      // pnf.data and pnf.URL and pnf.filename should not be empty at the same time
      assert(false, 'PNF error: $pnf');
      return null;
    }
    return PortableNetworkFile(pnf);
  }

}
