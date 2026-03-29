import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/transaction_service.dart';
import '../../core/constants/donation_constants.dart';
import '../../data/models/transaction.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionService _transactionService;

  String? _toAddress;
  int? _amount;
  int? _feeRate;
  String? _fromAddress;
  String? _privateKey;
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
      _toAddress = event.toAddress;
      _amount = event.amount;
      _feeRate = event.feeRate;
      _fromAddress = event.fromAddress;
      _privateKey = event.privateKey;

      final unsignedTx = await _transactionService.buildTransaction(
        toAddress: event.toAddress,
        amount: event.amount,
        fromAddress: event.fromAddress,
        feeRate: event.feeRate,
      );

      _unsignedTransaction = unsignedTx;
      final preview = _transactionService.buildPreview(
        toAddress: event.toAddress,
        sendAmount: event.amount,
        donationAmount: unsignedTx.donationFee,
        fee: unsignedTx.fee,
        changeAmount: unsignedTx.changeAmount,
      );

      emit(TransactionBuilt(
        transaction: unsignedTx,
        preview: preview,
      ));
    } on TransactionException catch (e) {
      emit(TransactionError(message: e.message));
    } catch (e) {
      emit(TransactionError(message: 'Failed to build transaction: $e'));
    }
  }

  Future<void> _onSignTransaction(
    SignTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    if (_unsignedTransaction == null || _privateKey == null) {
      emit(const TransactionError(message: 'No transaction to sign'));
      return;
    }

    emit(const TransactionSigning());

    try {
      final txid = await _transactionService.signAndBroadcast(
        unsignedTx: _unsignedTransaction!,
        privateKeyHex: _privateKey!,
      );

      emit(TransactionBroadcasted(txid: txid));
    } on TransactionException catch (e) {
      emit(TransactionError(message: e.message));
    } catch (e) {
      emit(TransactionError(message: 'Failed to sign transaction: $e'));
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
    } on TransactionException catch (e) {
      emit(TransactionError(message: e.message));
    } catch (e) {
      emit(TransactionError(message: 'Failed to broadcast transaction: $e'));
    }
  }

  void _onResetTransaction(
    ResetTransactionEvent event,
    Emitter<TransactionState> emit,
  ) {
    _toAddress = null;
    _amount = null;
    _feeRate = null;
    _fromAddress = null;
    _privateKey = null;
    _unsignedTransaction = null;

    emit(const TransactionInitial());
  }

  void _onSetFeeRate(
    SetFeeRateEvent event,
    Emitter<TransactionState> emit,
  ) {
    _feeRate = TransactionConstants.getFeeRate(event.feeLevel);
    emit(TransactionFeeRateSet(
      feeLevel: event.feeLevel,
      feeRate: _feeRate!,
    ));
  }

  int calculateDonationFee(int amount) {
    return _transactionService.calculateDonationFee(amount);
  }
}
