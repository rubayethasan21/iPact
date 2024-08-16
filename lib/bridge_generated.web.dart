// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.82.6.
// ignore_for_file: non_constant_identifier_names, unused_element, duplicate_ignore, directives_ordering, curly_braces_in_flow_control_structures, unnecessary_lambdas, slash_for_doc_comments, prefer_const_literals_to_create_immutables, implicit_dynamic_list_literal, duplicate_import, unused_import, unnecessary_import, prefer_single_quotes, prefer_const_constructors, use_super_parameters, always_use_package_imports, annotate_overrides, invalid_use_of_protected_member, constant_identifier_names, invalid_use_of_internal_member, prefer_is_empty, unnecessary_const

import "bridge_definitions.dart";
import 'dart:convert';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:uuid/uuid.dart';
import 'bridge_generated.dart';
export 'bridge_generated.dart';

class RustPlatform extends FlutterRustBridgeBase<RustWire>
    with FlutterRustBridgeSetupMixin {
  RustPlatform(FutureOr<WasmModule> dylib) : super(RustWire(dylib)) {
    setupMixinConstructor();
  }
  Future<void> setup() => inner.init;

// Section: api2wire

  @protected
  String api2wire_String(String raw) {
    return raw;
  }

  @protected
  List<dynamic> api2wire_box_autoadd_network_info(NetworkInfo raw) {
    return api2wire_network_info(raw);
  }

  @protected
  List<dynamic> api2wire_box_autoadd_transaction_params(TransactionParams raw) {
    return api2wire_transaction_params(raw);
  }

  @protected
  List<dynamic> api2wire_box_autoadd_wallet_info(WalletInfo raw) {
    return api2wire_wallet_info(raw);
  }

  @protected
  List<dynamic> api2wire_network_info(NetworkInfo raw) {
    return [api2wire_String(raw.nodeUrl), api2wire_String(raw.faucetUrl)];
  }

  @protected
  List<dynamic> api2wire_transaction_params(TransactionParams raw) {
    return [
      api2wire_String(raw.transactionTag),
      api2wire_String(raw.transactionMetadata),
      api2wire_String(raw.receiverAddress),
      api2wire_String(raw.storageDepositReturnAddress)
    ];
  }

  @protected
  Uint8List api2wire_uint_8_list(Uint8List raw) {
    return raw;
  }

  @protected
  List<dynamic> api2wire_wallet_info(WalletInfo raw) {
    return [
      api2wire_String(raw.alias),
      api2wire_String(raw.mnemonic),
      api2wire_String(raw.strongholdPassword),
      api2wire_String(raw.strongholdFilepath),
      api2wire_String(raw.lastAddress)
    ];
  }
// Section: finalizer
}

// Section: WASM wire module

@JS('wasm_bindgen')
external RustWasmModule get wasmModule;

@JS()
@anonymous
class RustWasmModule implements WasmModule {
  external Object /* Promise */ call([String? moduleName]);
  external RustWasmModule bind(dynamic thisArg, String moduleName);
  external dynamic /* void */ wire_get_node_info(
      NativePortType port_, List<dynamic> network_info);

  external dynamic /* void */ wire_generate_mnemonic(NativePortType port_);

  external dynamic /* void */ wire_create_wallet_account(NativePortType port_,
      List<dynamic> network_info, List<dynamic> wallet_info);

  external dynamic /* void */ wire_get_addresses(
      NativePortType port_, List<dynamic> wallet_info);

  external dynamic /* void */ wire_create_transaction(NativePortType port_,
      List<dynamic> wallet_info, List<dynamic> transaction_params);

  external dynamic /* void */ wire_create_advanced_transaction(
      NativePortType port_,
      List<dynamic> wallet_info,
      List<dynamic> transaction_params);

  external dynamic /* void */ wire_generate_address(
      NativePortType port_, List<dynamic> wallet_info);

  external dynamic /* void */ wire_get_sent_transactions(
      NativePortType port_, List<dynamic> wallet_info);

  external dynamic /* void */ wire_get_received_transactions(
      NativePortType port_, List<dynamic> wallet_info);

  external dynamic /* void */ wire_get_single_transaction(
      NativePortType port_, List<dynamic> wallet_info, String transaction_id);

  external dynamic /* void */ wire_check_balance(
      NativePortType port_, List<dynamic> wallet_info);

  external dynamic /* void */ wire_request_funds(NativePortType port_,
      List<dynamic> network_info, List<dynamic> wallet_info);

  external dynamic /* void */ wire_create_decentralized_identifier(
      NativePortType port_,
      List<dynamic> network_info,
      List<dynamic> wallet_info);

  external dynamic /* void */ wire_bin_to_hex(
      NativePortType port_, String val, int len);

  external dynamic /* void */ wire_create_iota_account(NativePortType port_,
      List<dynamic> network_info, List<dynamic> wallet_info);

  external dynamic /* void */ wire_write_advanced_transaction(
      NativePortType port_,
      List<dynamic> transaction_params,
      List<dynamic> wallet_info);

  external dynamic /* void */ wire_read_incoming_transactions(
      NativePortType port_, List<dynamic> wallet_info);

  external dynamic /* void */ wire_read_outgoing_transactions(
      NativePortType port_, List<dynamic> wallet_info);

  external dynamic /* void */ wire_get_balance(
      NativePortType port_, List<dynamic> wallet_info);
}

// Section: WASM wire connector

class RustWire extends FlutterRustBridgeWasmWireBase<RustWasmModule> {
  RustWire(FutureOr<WasmModule> module)
      : super(WasmModule.cast<RustWasmModule>(module));

  void wire_get_node_info(NativePortType port_, List<dynamic> network_info) =>
      wasmModule.wire_get_node_info(port_, network_info);

  void wire_generate_mnemonic(NativePortType port_) =>
      wasmModule.wire_generate_mnemonic(port_);

  void wire_create_wallet_account(NativePortType port_,
          List<dynamic> network_info, List<dynamic> wallet_info) =>
      wasmModule.wire_create_wallet_account(port_, network_info, wallet_info);

  void wire_get_addresses(NativePortType port_, List<dynamic> wallet_info) =>
      wasmModule.wire_get_addresses(port_, wallet_info);

  void wire_create_transaction(NativePortType port_, List<dynamic> wallet_info,
          List<dynamic> transaction_params) =>
      wasmModule.wire_create_transaction(
          port_, wallet_info, transaction_params);

  void wire_create_advanced_transaction(NativePortType port_,
          List<dynamic> wallet_info, List<dynamic> transaction_params) =>
      wasmModule.wire_create_advanced_transaction(
          port_, wallet_info, transaction_params);

  void wire_generate_address(NativePortType port_, List<dynamic> wallet_info) =>
      wasmModule.wire_generate_address(port_, wallet_info);

  void wire_get_sent_transactions(
          NativePortType port_, List<dynamic> wallet_info) =>
      wasmModule.wire_get_sent_transactions(port_, wallet_info);

  void wire_get_received_transactions(
          NativePortType port_, List<dynamic> wallet_info) =>
      wasmModule.wire_get_received_transactions(port_, wallet_info);

  void wire_get_single_transaction(NativePortType port_,
          List<dynamic> wallet_info, String transaction_id) =>
      wasmModule.wire_get_single_transaction(
          port_, wallet_info, transaction_id);

  void wire_check_balance(NativePortType port_, List<dynamic> wallet_info) =>
      wasmModule.wire_check_balance(port_, wallet_info);

  void wire_request_funds(NativePortType port_, List<dynamic> network_info,
          List<dynamic> wallet_info) =>
      wasmModule.wire_request_funds(port_, network_info, wallet_info);

  void wire_create_decentralized_identifier(NativePortType port_,
          List<dynamic> network_info, List<dynamic> wallet_info) =>
      wasmModule.wire_create_decentralized_identifier(
          port_, network_info, wallet_info);

  void wire_bin_to_hex(NativePortType port_, String val, int len) =>
      wasmModule.wire_bin_to_hex(port_, val, len);

  void wire_create_iota_account(NativePortType port_,
          List<dynamic> network_info, List<dynamic> wallet_info) =>
      wasmModule.wire_create_iota_account(port_, network_info, wallet_info);

  void wire_write_advanced_transaction(NativePortType port_,
          List<dynamic> transaction_params, List<dynamic> wallet_info) =>
      wasmModule.wire_write_advanced_transaction(
          port_, transaction_params, wallet_info);

  void wire_read_incoming_transactions(
          NativePortType port_, List<dynamic> wallet_info) =>
      wasmModule.wire_read_incoming_transactions(port_, wallet_info);

  void wire_read_outgoing_transactions(
          NativePortType port_, List<dynamic> wallet_info) =>
      wasmModule.wire_read_outgoing_transactions(port_, wallet_info);

  void wire_get_balance(NativePortType port_, List<dynamic> wallet_info) =>
      wasmModule.wire_get_balance(port_, wallet_info);
}
