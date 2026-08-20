/// Ming-Ke-Ming
/// ~~~~~~~~~~~~
/// Decentralized User Identity Authentication
library dimax;

export 'package:dimp/mkm.dart' hide BaseMeta, BaseDocument, BaseVisa, BaseBulletin;

//
//  Address
//
export 'src/mkm/btc.dart';
export 'src/mkm/eth.dart';

export 'src/mkm/address_factory.dart';

//
//  ID
//
export 'src/mkm/id_factory.dart';

//
//  Meta
//
export 'src/mkm/meta.dart';
export 'src/mkm/meta_factory.dart';

//
//  Document
//
export 'src/mkm/document.dart';
export 'src/mkm/docs.dart';
export 'src/mkm/document_factory.dart';
