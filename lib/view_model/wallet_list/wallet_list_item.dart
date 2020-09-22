import 'package:flutter/foundation.dart';
import 'package:cake_wallet/entities/wallet_type.dart';

class WalletListItem {
  const WalletListItem(
      {@required this.name, @required this.type, @required this.key, this.isCurrent = false});

  final String name;
  final WalletType type;
  final bool isCurrent;
  final dynamic key;
}
