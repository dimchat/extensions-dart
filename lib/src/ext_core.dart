/* license: https://mit-license.org
 * =============================================================================
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
 * =============================================================================
 */
import 'package:dimp/ext.dart';

import 'ext/account.dart';
import 'ext/command.dart';
import 'ext/format.dart';
import 'ext/message.dart';


mixin CoreExtensions {

  // protected
  void registerAccountHelpers() {

    // mkm
    var accountHelper = AccountGeneralFactory();
    sharedAccountExtensions.addressHelper = accountHelper;
    sharedAccountExtensions.idHelper      = accountHelper;
    sharedAccountExtensions.metaHelper    = accountHelper;
    sharedAccountExtensions.docHelper     = accountHelper;
    sharedAccountExtensions.helper        = accountHelper;

  }

  // protected
  void registerMessageHelpers() {

    // dkd
    var msgHelper = MessageGeneralFactory();
    sharedMessageExtensions.contentHelper  = msgHelper;
    sharedMessageExtensions.envelopeHelper = msgHelper;
    sharedMessageExtensions.instantHelper  = msgHelper;
    sharedMessageExtensions.secureHelper   = msgHelper;
    sharedMessageExtensions.reliableHelper = msgHelper;
    sharedMessageExtensions.helper         = msgHelper;

  }

  // protected
  void registerCommandHelpers() {

    // cmd
    var cmdHelper = CommandGeneralFactory();
    sharedMessageExtensions.cmdHelper     = cmdHelper;
    sharedMessageExtensions.commandHelper = cmdHelper;

  }

  // protected
  void registerFormatHelpers() {

    // format
    var formatHelper = FormatGeneralFactory();
    sharedFormatExtensions.pnfHelper = formatHelper;
    sharedFormatExtensions.tedHelper = formatHelper;

  }

}
