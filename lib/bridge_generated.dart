// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.82.6.
// ignore_for_file: non_constant_identifier_names, unused_element, duplicate_ignore, directives_ordering, curly_braces_in_flow_control_structures, unnecessary_lambdas, slash_for_doc_comments, prefer_const_literals_to_create_immutables, implicit_dynamic_list_literal, duplicate_import, unused_import, unnecessary_import, prefer_single_quotes, prefer_const_constructors, use_super_parameters, always_use_package_imports, annotate_overrides, invalid_use_of_protected_member, constant_identifier_names, invalid_use_of_internal_member, prefer_is_empty, unnecessary_const

import "bridge_definitions.dart";
import 'dart:convert';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:uuid/uuid.dart';
import 'bridge_generated.io.dart'
    if (dart.library.html) 'bridge_generated.web.dart';

class RustImpl implements Rust {
  final RustPlatform _platform;
  factory RustImpl(ExternalLibrary dylib) => RustImpl.raw(RustPlatform(dylib));

  /// Only valid on web/WASM platforms.
  factory RustImpl.wasm(FutureOr<WasmModule> module) =>
      RustImpl(module as ExternalLibrary);
  RustImpl.raw(this._platform);
  Future<String> getNodeInfo({required NetworkInfo networkInfo, dynamic hint}) {
    var arg0 = _platform.api2wire_box_autoadd_network_info(networkInfo);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) => _platform.inner.wire_get_node_info(port_, arg0),
      parseSuccessData: _wire2api_String,
      parseErrorData: _wire2api_FrbAnyhowException,
      constMeta: kGetNodeInfoConstMeta,
      argValues: [networkInfo],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kGetNodeInfoConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "get_node_info",
        argNames: ["networkInfo"],
      );

  Future<String> generateMnemonic({dynamic hint}) {
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) => _platform.inner.wire_generate_mnemonic(port_),
      parseSuccessData: _wire2api_String,
      parseErrorData: null,
      constMeta: kGenerateMnemonicConstMeta,
      argValues: [],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kGenerateMnemonicConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "generate_mnemonic",
        argNames: [],
      );

  Future<String> requestFunds(
      {required NetworkInfo networkInfo,
      required WalletInfo walletInfo,
      dynamic hint}) {
    var arg0 = _platform.api2wire_box_autoadd_network_info(networkInfo);
    var arg1 = _platform.api2wire_box_autoadd_wallet_info(walletInfo);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) => _platform.inner.wire_request_funds(port_, arg0, arg1),
      parseSuccessData: _wire2api_String,
      parseErrorData: _wire2api_FrbAnyhowException,
      constMeta: kRequestFundsConstMeta,
      argValues: [networkInfo, walletInfo],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kRequestFundsConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "request_funds",
        argNames: ["networkInfo", "walletInfo"],
      );

  Future<String> createIotaAccount(
      {required NetworkInfo networkInfo,
      required WalletInfo walletInfo,
      dynamic hint}) {
    var arg0 = _platform.api2wire_box_autoadd_network_info(networkInfo);
    var arg1 = _platform.api2wire_box_autoadd_wallet_info(walletInfo);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) =>
          _platform.inner.wire_create_iota_account(port_, arg0, arg1),
      parseSuccessData: _wire2api_String,
      parseErrorData: _wire2api_FrbAnyhowException,
      constMeta: kCreateIotaAccountConstMeta,
      argValues: [networkInfo, walletInfo],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kCreateIotaAccountConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "create_iota_account",
        argNames: ["networkInfo", "walletInfo"],
      );

  Future<String> writeAdvancedTransaction(
      {required TransactionParams transactionParams,
      required WalletInfo walletInfo,
      dynamic hint}) {
    var arg0 =
        _platform.api2wire_box_autoadd_transaction_params(transactionParams);
    var arg1 = _platform.api2wire_box_autoadd_wallet_info(walletInfo);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) =>
          _platform.inner.wire_write_advanced_transaction(port_, arg0, arg1),
      parseSuccessData: _wire2api_String,
      parseErrorData: _wire2api_FrbAnyhowException,
      constMeta: kWriteAdvancedTransactionConstMeta,
      argValues: [transactionParams, walletInfo],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kWriteAdvancedTransactionConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "write_advanced_transaction",
        argNames: ["transactionParams", "walletInfo"],
      );

  Future<String> readIncomingTransactions(
      {required WalletInfo walletInfo, dynamic hint}) {
    var arg0 = _platform.api2wire_box_autoadd_wallet_info(walletInfo);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) =>
          _platform.inner.wire_read_incoming_transactions(port_, arg0),
      parseSuccessData: _wire2api_String,
      parseErrorData: _wire2api_FrbAnyhowException,
      constMeta: kReadIncomingTransactionsConstMeta,
      argValues: [walletInfo],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kReadIncomingTransactionsConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "read_incoming_transactions",
        argNames: ["walletInfo"],
      );

  Future<String> readOutgoingTransactions(
      {required WalletInfo walletInfo, dynamic hint}) {
    var arg0 = _platform.api2wire_box_autoadd_wallet_info(walletInfo);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) =>
          _platform.inner.wire_read_outgoing_transactions(port_, arg0),
      parseSuccessData: _wire2api_String,
      parseErrorData: _wire2api_FrbAnyhowException,
      constMeta: kReadOutgoingTransactionsConstMeta,
      argValues: [walletInfo],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kReadOutgoingTransactionsConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "read_outgoing_transactions",
        argNames: ["walletInfo"],
      );

  Future<String> getBalance({required WalletInfo walletInfo, dynamic hint}) {
    var arg0 = _platform.api2wire_box_autoadd_wallet_info(walletInfo);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) => _platform.inner.wire_get_balance(port_, arg0),
      parseSuccessData: _wire2api_String,
      parseErrorData: _wire2api_FrbAnyhowException,
      constMeta: kGetBalanceConstMeta,
      argValues: [walletInfo],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kGetBalanceConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "get_balance",
        argNames: ["walletInfo"],
      );

  Future<String> getAddresses({required WalletInfo walletInfo, dynamic hint}) {
    var arg0 = _platform.api2wire_box_autoadd_wallet_info(walletInfo);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) => _platform.inner.wire_get_addresses(port_, arg0),
      parseSuccessData: _wire2api_String,
      parseErrorData: _wire2api_FrbAnyhowException,
      constMeta: kGetAddressesConstMeta,
      argValues: [walletInfo],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kGetAddressesConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "get_addresses",
        argNames: ["walletInfo"],
      );

  void dispose() {
    _platform.dispose();
  }
// Section: wire2api

  FrbAnyhowException _wire2api_FrbAnyhowException(dynamic raw) {
    return FrbAnyhowException(raw as String);
  }

  String _wire2api_String(dynamic raw) {
    return raw as String;
  }

  int _wire2api_u8(dynamic raw) {
    return raw as int;
  }

  Uint8List _wire2api_uint_8_list(dynamic raw) {
    return raw as Uint8List;
  }
}

// Section: api2wire

@protected
int api2wire_u8(int raw) {
  return raw;
}

// Section: finalizer
