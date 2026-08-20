import 'package:dimp/mkm.dart';
import 'package:dimax/ext.dart';

import 'address.dart';
import 'meta.dart';


/// Compatible Extensions
/// ~~~~~~~~~~~~~~~~~~~~~
class CommonExtensionLoader extends ExtensionLoader {

  @override
  void registerAddressFactory() {
    Address.setFactory(CompatibleAddressFactory());
  }

  @override
  void registerMetaFactories() {
    var mkm = CompatibleMetaFactory(MetaType.MKM);
    var btc = CompatibleMetaFactory(MetaType.BTC);
    var eth = CompatibleMetaFactory(MetaType.ETH);

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

}
