import 'package:cake_wallet/entities/balance_display_mode.dart';
import 'package:cake_wallet/entities/fiat_currency.dart';
import 'package:cake_wallet/ethereum/ethereum.dart';
import 'package:cake_wallet/generated/i18n.dart';
import 'package:cake_wallet/nano/nano.dart';
import 'package:cake_wallet/polygon/polygon.dart';
import 'package:cake_wallet/reactions/wallet_connect.dart';
import 'package:cake_wallet/solana/solana.dart';
import 'package:cake_wallet/tron/tron.dart';
import 'package:cake_wallet/wownero/wownero.dart';
import 'package:cw_core/crypto_currency.dart';
import 'package:cw_core/transaction_direction.dart';
import 'package:cw_core/transaction_info.dart';
import 'package:cake_wallet/store/settings_store.dart';
import 'package:cake_wallet/view_model/dashboard/action_list_item.dart';
import 'package:cake_wallet/monero/monero.dart';
import 'package:cake_wallet/haven/haven.dart';
import 'package:cake_wallet/bitcoin/bitcoin.dart';
import 'package:cake_wallet/entities/calculate_fiat_amount_raw.dart';
import 'package:cake_wallet/view_model/dashboard/balance_view_model.dart';
import 'package:cw_core/keyable.dart';
import 'package:cw_core/wallet_type.dart';

class TransactionListItem extends ActionListItem with Keyable {
  TransactionListItem({
    required this.transaction,
    required this.balanceViewModel,
    required this.settingsStore,
    required super.key,
  });

  final TransactionInfo transaction;
  final BalanceViewModel balanceViewModel;
  final SettingsStore settingsStore;

  double get price => balanceViewModel.price;

  FiatCurrency get fiatCurrency => settingsStore.fiatCurrency;

  BalanceDisplayMode get displayMode => balanceViewModel.displayMode;

  @override
  dynamic get keyIndex => transaction.id;

  bool get hasTokens =>
      isEVMCompatibleChain(balanceViewModel.wallet.type) ||
      balanceViewModel.wallet.type == WalletType.solana ||
      balanceViewModel.wallet.type == WalletType.tron;

  String get formattedCryptoAmount {
    return displayMode == BalanceDisplayMode.hiddenBalance ? '---' : transaction.amountFormatted();
  }

  String get formattedTitle {
    if (transaction.direction == TransactionDirection.incoming) {
      return S.current.received;
    }

    return S.current.sent;
  }

  String get formattedPendingStatus {
    if (balanceViewModel.wallet.type == WalletType.monero ||
        balanceViewModel.wallet.type == WalletType.haven) {
      if (transaction.confirmations >= 0 && transaction.confirmations < 10) {
        return ' (${transaction.confirmations}/10)';
      }
    } else if (balanceViewModel.wallet.type == WalletType.wownero) {
      if (transaction.confirmations >= 0 && transaction.confirmations < 3) {
        return ' (${transaction.confirmations}/3)';
      }
    }
    return '';
  }

  String get formattedStatus {
    if (balanceViewModel.wallet.type == WalletType.monero ||
        balanceViewModel.wallet.type == WalletType.wownero ||
        balanceViewModel.wallet.type == WalletType.haven) {
      return formattedPendingStatus;
    }
    return transaction.isPending ? S.current.pending : '';
  }

  String get formattedType {
    if (transaction.evmSignatureName == 'approval') {
      return ' (${transaction.evmSignatureName})';
    }
    return '';
  }

  CryptoCurrency? get assetOfTransaction {
    try {
      if (balanceViewModel.wallet.type == WalletType.ethereum) {
        final asset = ethereum!.assetOfTransaction(balanceViewModel.wallet, transaction);
        return asset;
      }

      if (balanceViewModel.wallet.type == WalletType.polygon) {
        final asset = polygon!.assetOfTransaction(balanceViewModel.wallet, transaction);
        return asset;
      }

      if (balanceViewModel.wallet.type == WalletType.solana) {
        final asset = solana!.assetOfTransaction(balanceViewModel.wallet, transaction);
        return asset;
      }

      if (balanceViewModel.wallet.type == WalletType.tron) {
        final asset = tron!.assetOfTransaction(balanceViewModel.wallet, transaction);
        return asset;
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  String get formattedFiatAmount {
    var amount = '';

    switch (balanceViewModel.wallet.type) {
      case WalletType.monero:
        amount = calculateFiatAmountRaw(
            cryptoAmount: monero!.formatterMoneroAmountToDouble(amount: transaction.amount),
            price: price);
        break;
      case WalletType.wownero:
        amount = calculateFiatAmountRaw(
            cryptoAmount: wownero!.formatterWowneroAmountToDouble(amount: transaction.amount),
            price: price);
        break;
      case WalletType.bitcoin:
      case WalletType.litecoin:
      case WalletType.bitcoinCash:
        amount = calculateFiatAmountRaw(
            cryptoAmount: bitcoin!.formatterBitcoinAmountToDouble(amount: transaction.amount),
            price: price);
        break;
      case WalletType.haven:
        final asset = haven!.assetOfTransaction(transaction);
        final price = balanceViewModel.fiatConvertationStore.prices[asset];
        amount = calculateFiatAmountRaw(
            cryptoAmount: haven!.formatterMoneroAmountToDouble(amount: transaction.amount),
            price: price);
        break;
      case WalletType.ethereum:
        final asset = ethereum!.assetOfTransaction(balanceViewModel.wallet, transaction);
        final price = balanceViewModel.fiatConvertationStore.prices[asset];
        amount = calculateFiatAmountRaw(
            cryptoAmount: ethereum!.formatterEthereumAmountToDouble(transaction: transaction),
            price: price);
        break;
      case WalletType.polygon:
        final asset = polygon!.assetOfTransaction(balanceViewModel.wallet, transaction);
        final price = balanceViewModel.fiatConvertationStore.prices[asset];
        amount = calculateFiatAmountRaw(
            cryptoAmount: polygon!.formatterPolygonAmountToDouble(transaction: transaction),
            price: price);
        break;
      case WalletType.nano:
        amount = calculateFiatAmountRaw(
            cryptoAmount: double.parse(nanoUtil!.getRawAsUsableString(
                nano!.getTransactionAmountRaw(transaction).toString(), nanoUtil!.rawPerNano)),
            price: price);
        break;
      case WalletType.solana:
        final asset = solana!.assetOfTransaction(balanceViewModel.wallet, transaction);
        final price = balanceViewModel.fiatConvertationStore.prices[asset];
        amount = calculateFiatAmountRaw(
          cryptoAmount: solana!.getTransactionAmountRaw(transaction),
          price: price,
        );
        break;

      case WalletType.tron:
        final asset = tron!.assetOfTransaction(balanceViewModel.wallet, transaction);
        final price = balanceViewModel.fiatConvertationStore.prices[asset];
        final cryptoAmount = tron!.getTransactionAmountRaw(transaction);
        amount = calculateFiatAmountRaw(
          cryptoAmount: cryptoAmount,
          price: price,
        );
        break;
      default:
        break;
    }

    transaction.changeFiatAmount(amount);
    return displayMode == BalanceDisplayMode.hiddenBalance
        ? '---'
        : fiatCurrency.title + ' ' + transaction.fiatAmount();
  }

  @override
  DateTime get date => transaction.date;
}
