import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/network_constants.dart';
import '../../data/models/transaction.dart';
import '../../services/transaction_service.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionService _transactionService;

  String? _privateKey;
  String? _publicKey;
  UnsignedTransaction? _unsignedTransaction;

  TransactionBloc({
    required TransactionService transactionService,
  })  : _transactionService = transactionService,
        super(const TransactionInitial()) {
    on<BuildTransactionEvent>(_onBuildTransaction);
    on<SignTransactionEvent>(_onSignTransaction);
    on<BroadcastTransactionEvent>(_onBroadcastTransaction);
    on<ResetTransactionEvent>(_onResetTransaction);
    on<SetFeeRateEvent>(_onSetFeeRate);
  }

  Future<void> _onBuildTransaction(
    BuildTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionBuilding());

    try {
      _privateKey = event.privateKey;
      _publicKey = event.publicKey;

      final chain = NetworkConstants.chainFor(event.isTestnet);
      final unsignedTx = await _transactionService.buildTransaction(
        toAddress: event.toAddress,
        sendAmount: event.sendAmount,
        fromAddress: event.fromAddress,
        feeRate: event.feeRate,
        chain: chain,
      );

      _unsignedTransaction = unsignedTx;
      final preview = _transactionService.createPreview(
        unsignedTx,
        network: chain.network,
      );

      emit(TransactionBuilt(transaction: unsignedTx, preview: preview));
    } on TransactionException catch (error) {
      emit(TransactionError(message: error.message));
    } catch (error) {
      emit(TransactionError(message: 'Failed to build transaction: $error'));
    }
  }

  Future<void> _onSignTransaction(
    SignTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    if (_unsignedTransaction == null || _privateKey == null || _publicKey == null) {
      emit(const TransactionError(message: 'No transaction to sign'));
      return;
    }

    emit(const TransactionSigning());

    try {
      final txid = await _transactionService.signAndBroadcast(
        unsignedTx: _unsignedTransaction!,
        privateKeyHex: _privateKey!,
        publicKeyHex: _publicKey!,
      );

      emit(TransactionBroadcasted(txid: txid));
    } on TransactionException catch (error) {
      emit(TransactionError(message: error.message));
    } catch (error) {
      emit(TransactionError(message: 'Failed to sign transaction: $error'));
    }
  }

  Future<void> _onBroadcastTransaction(
    BroadcastTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionBroadcasting());

    try {
      if (_unsignedTransaction == null) {
        emit(const TransactionError(message: 'No transaction to broadcast'));
        return;
      }

      final txid = await _transactionService.broadcastTransaction(
        _unsignedTransaction!.rawHex,
      );

      emit(TransactionBroadcasted(txid: txid));
    } on TransactionException catch (error) {
      emit(TransactionError(message: error.message));
    } catch (error) {
      emit(TransactionError(message: 'Failed to broadcast transaction: $error'));
    }
  }

  void _onResetTransaction(
    ResetTransactionEvent event,
    Emitter<TransactionState> emit,
  ) {
    _privateKey = null;
    _publicKey = null;
    _unsignedTransaction = null;
    emit(const TransactionInitial());
  }

  void _onSetFeeRate(
    SetFeeRateEvent event,
    Emitter<TransactionState> emit,
  ) {
    emit(
      TransactionFeeRateSet(
        feeLevel: event.feeLevel,
        feeRate: TransactionConstants.getFeeRate(event.feeLevel),
      ),
    );
  }

  int calculateDonationFee(int amount) {
    return _transactionService.calculateDonationFee(amount);
  }
}
