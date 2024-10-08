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
import 'dart:ffi' as ffi;

class RustPlatform extends FlutterRustBridgeBase<RustWire> {
  RustPlatform(ffi.DynamicLibrary dylib) : super(RustWire(dylib));

// Section: api2wire

  @protected
  ffi.Pointer<wire_uint_8_list> api2wire_String(String raw) {
    return api2wire_uint_8_list(utf8.encoder.convert(raw));
  }

  @protected
  ffi.Pointer<wire_NetworkInfo> api2wire_box_autoadd_network_info(
      NetworkInfo raw) {
    final ptr = inner.new_box_autoadd_network_info_0();
    _api_fill_to_wire_network_info(raw, ptr.ref);
    return ptr;
  }

  @protected
  ffi.Pointer<wire_TransactionParams> api2wire_box_autoadd_transaction_params(
      TransactionParams raw) {
    final ptr = inner.new_box_autoadd_transaction_params_0();
    _api_fill_to_wire_transaction_params(raw, ptr.ref);
    return ptr;
  }

  @protected
  ffi.Pointer<wire_WalletInfo> api2wire_box_autoadd_wallet_info(
      WalletInfo raw) {
    final ptr = inner.new_box_autoadd_wallet_info_0();
    _api_fill_to_wire_wallet_info(raw, ptr.ref);
    return ptr;
  }

  @protected
  ffi.Pointer<wire_uint_8_list> api2wire_uint_8_list(Uint8List raw) {
    final ans = inner.new_uint_8_list_0(raw.length);
    ans.ref.ptr.asTypedList(raw.length).setAll(0, raw);
    return ans;
  }

// Section: finalizer

// Section: api_fill_to_wire

  void _api_fill_to_wire_box_autoadd_network_info(
      NetworkInfo apiObj, ffi.Pointer<wire_NetworkInfo> wireObj) {
    _api_fill_to_wire_network_info(apiObj, wireObj.ref);
  }

  void _api_fill_to_wire_box_autoadd_transaction_params(
      TransactionParams apiObj, ffi.Pointer<wire_TransactionParams> wireObj) {
    _api_fill_to_wire_transaction_params(apiObj, wireObj.ref);
  }

  void _api_fill_to_wire_box_autoadd_wallet_info(
      WalletInfo apiObj, ffi.Pointer<wire_WalletInfo> wireObj) {
    _api_fill_to_wire_wallet_info(apiObj, wireObj.ref);
  }

  void _api_fill_to_wire_network_info(
      NetworkInfo apiObj, wire_NetworkInfo wireObj) {
    wireObj.node_url = api2wire_String(apiObj.nodeUrl);
    wireObj.faucet_url = api2wire_String(apiObj.faucetUrl);
  }

  void _api_fill_to_wire_transaction_params(
      TransactionParams apiObj, wire_TransactionParams wireObj) {
    wireObj.transaction_tag = api2wire_String(apiObj.transactionTag);
    wireObj.transaction_metadata = api2wire_String(apiObj.transactionMetadata);
    wireObj.receiver_address = api2wire_String(apiObj.receiverAddress);
    wireObj.storage_deposit_return_address =
        api2wire_String(apiObj.storageDepositReturnAddress);
  }

  void _api_fill_to_wire_wallet_info(
      WalletInfo apiObj, wire_WalletInfo wireObj) {
    wireObj.alias = api2wire_String(apiObj.alias);
    wireObj.mnemonic = api2wire_String(apiObj.mnemonic);
    wireObj.stronghold_password = api2wire_String(apiObj.strongholdPassword);
    wireObj.stronghold_filepath = api2wire_String(apiObj.strongholdFilepath);
    wireObj.last_address = api2wire_String(apiObj.lastAddress);
  }
}

// ignore_for_file: camel_case_types, non_constant_identifier_names, avoid_positional_boolean_parameters, annotate_overrides, constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint

/// generated by flutter_rust_bridge
class RustWire implements FlutterRustBridgeWireBase {
  @internal
  late final dartApi = DartApiDl(init_frb_dart_api_dl);

  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  RustWire(ffi.DynamicLibrary dynamicLibrary) : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  RustWire.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  void store_dart_post_cobject(
    DartPostCObjectFnType ptr,
  ) {
    return _store_dart_post_cobject(
      ptr,
    );
  }

  late final _store_dart_post_cobjectPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(DartPostCObjectFnType)>>(
          'store_dart_post_cobject');
  late final _store_dart_post_cobject = _store_dart_post_cobjectPtr
      .asFunction<void Function(DartPostCObjectFnType)>();

  Object get_dart_object(
    int ptr,
  ) {
    return _get_dart_object(
      ptr,
    );
  }

  late final _get_dart_objectPtr =
      _lookup<ffi.NativeFunction<ffi.Handle Function(ffi.UintPtr)>>(
          'get_dart_object');
  late final _get_dart_object =
      _get_dart_objectPtr.asFunction<Object Function(int)>();

  void drop_dart_object(
    int ptr,
  ) {
    return _drop_dart_object(
      ptr,
    );
  }

  late final _drop_dart_objectPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.UintPtr)>>(
          'drop_dart_object');
  late final _drop_dart_object =
      _drop_dart_objectPtr.asFunction<void Function(int)>();

  int new_dart_opaque(
    Object handle,
  ) {
    return _new_dart_opaque(
      handle,
    );
  }

  late final _new_dart_opaquePtr =
      _lookup<ffi.NativeFunction<ffi.UintPtr Function(ffi.Handle)>>(
          'new_dart_opaque');
  late final _new_dart_opaque =
      _new_dart_opaquePtr.asFunction<int Function(Object)>();

  int init_frb_dart_api_dl(
    ffi.Pointer<ffi.Void> obj,
  ) {
    return _init_frb_dart_api_dl(
      obj,
    );
  }

  late final _init_frb_dart_api_dlPtr =
      _lookup<ffi.NativeFunction<ffi.IntPtr Function(ffi.Pointer<ffi.Void>)>>(
          'init_frb_dart_api_dl');
  late final _init_frb_dart_api_dl = _init_frb_dart_api_dlPtr
      .asFunction<int Function(ffi.Pointer<ffi.Void>)>();

  void wire_get_node_info(
    int port_,
    ffi.Pointer<wire_NetworkInfo> network_info,
  ) {
    return _wire_get_node_info(
      port_,
      network_info,
    );
  }

  late final _wire_get_node_infoPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Int64, ffi.Pointer<wire_NetworkInfo>)>>('wire_get_node_info');
  late final _wire_get_node_info = _wire_get_node_infoPtr
      .asFunction<void Function(int, ffi.Pointer<wire_NetworkInfo>)>();

  void wire_generate_mnemonic(
    int port_,
  ) {
    return _wire_generate_mnemonic(
      port_,
    );
  }

  late final _wire_generate_mnemonicPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>(
          'wire_generate_mnemonic');
  late final _wire_generate_mnemonic =
      _wire_generate_mnemonicPtr.asFunction<void Function(int)>();

  void wire_request_funds(
    int port_,
    ffi.Pointer<wire_NetworkInfo> network_info,
    ffi.Pointer<wire_WalletInfo> wallet_info,
  ) {
    return _wire_request_funds(
      port_,
      network_info,
      wallet_info,
    );
  }

  late final _wire_request_fundsPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64, ffi.Pointer<wire_NetworkInfo>,
              ffi.Pointer<wire_WalletInfo>)>>('wire_request_funds');
  late final _wire_request_funds = _wire_request_fundsPtr.asFunction<
      void Function(
          int, ffi.Pointer<wire_NetworkInfo>, ffi.Pointer<wire_WalletInfo>)>();

  void wire_create_iota_account(
    int port_,
    ffi.Pointer<wire_NetworkInfo> network_info,
    ffi.Pointer<wire_WalletInfo> wallet_info,
  ) {
    return _wire_create_iota_account(
      port_,
      network_info,
      wallet_info,
    );
  }

  late final _wire_create_iota_accountPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64, ffi.Pointer<wire_NetworkInfo>,
              ffi.Pointer<wire_WalletInfo>)>>('wire_create_iota_account');
  late final _wire_create_iota_account =
      _wire_create_iota_accountPtr.asFunction<
          void Function(int, ffi.Pointer<wire_NetworkInfo>,
              ffi.Pointer<wire_WalletInfo>)>();

  void wire_write_advanced_transaction(
    int port_,
    ffi.Pointer<wire_TransactionParams> transaction_params,
    ffi.Pointer<wire_WalletInfo> wallet_info,
  ) {
    return _wire_write_advanced_transaction(
      port_,
      transaction_params,
      wallet_info,
    );
  }

  late final _wire_write_advanced_transactionPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Int64, ffi.Pointer<wire_TransactionParams>,
                  ffi.Pointer<wire_WalletInfo>)>>(
      'wire_write_advanced_transaction');
  late final _wire_write_advanced_transaction =
      _wire_write_advanced_transactionPtr.asFunction<
          void Function(int, ffi.Pointer<wire_TransactionParams>,
              ffi.Pointer<wire_WalletInfo>)>();

  void wire_read_incoming_transactions(
    int port_,
    ffi.Pointer<wire_WalletInfo> wallet_info,
  ) {
    return _wire_read_incoming_transactions(
      port_,
      wallet_info,
    );
  }

  late final _wire_read_incoming_transactionsPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Int64, ffi.Pointer<wire_WalletInfo>)>>(
      'wire_read_incoming_transactions');
  late final _wire_read_incoming_transactions =
      _wire_read_incoming_transactionsPtr
          .asFunction<void Function(int, ffi.Pointer<wire_WalletInfo>)>();

  void wire_read_outgoing_transactions(
    int port_,
    ffi.Pointer<wire_WalletInfo> wallet_info,
  ) {
    return _wire_read_outgoing_transactions(
      port_,
      wallet_info,
    );
  }

  late final _wire_read_outgoing_transactionsPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Int64, ffi.Pointer<wire_WalletInfo>)>>(
      'wire_read_outgoing_transactions');
  late final _wire_read_outgoing_transactions =
      _wire_read_outgoing_transactionsPtr
          .asFunction<void Function(int, ffi.Pointer<wire_WalletInfo>)>();

  void wire_get_balance(
    int port_,
    ffi.Pointer<wire_WalletInfo> wallet_info,
  ) {
    return _wire_get_balance(
      port_,
      wallet_info,
    );
  }

  late final _wire_get_balancePtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Int64, ffi.Pointer<wire_WalletInfo>)>>('wire_get_balance');
  late final _wire_get_balance = _wire_get_balancePtr
      .asFunction<void Function(int, ffi.Pointer<wire_WalletInfo>)>();

  void wire_get_addresses(
    int port_,
    ffi.Pointer<wire_WalletInfo> wallet_info,
  ) {
    return _wire_get_addresses(
      port_,
      wallet_info,
    );
  }

  late final _wire_get_addressesPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Int64, ffi.Pointer<wire_WalletInfo>)>>('wire_get_addresses');
  late final _wire_get_addresses = _wire_get_addressesPtr
      .asFunction<void Function(int, ffi.Pointer<wire_WalletInfo>)>();

  ffi.Pointer<wire_NetworkInfo> new_box_autoadd_network_info_0() {
    return _new_box_autoadd_network_info_0();
  }

  late final _new_box_autoadd_network_info_0Ptr =
      _lookup<ffi.NativeFunction<ffi.Pointer<wire_NetworkInfo> Function()>>(
          'new_box_autoadd_network_info_0');
  late final _new_box_autoadd_network_info_0 =
      _new_box_autoadd_network_info_0Ptr
          .asFunction<ffi.Pointer<wire_NetworkInfo> Function()>();

  ffi.Pointer<wire_TransactionParams> new_box_autoadd_transaction_params_0() {
    return _new_box_autoadd_transaction_params_0();
  }

  late final _new_box_autoadd_transaction_params_0Ptr = _lookup<
          ffi.NativeFunction<ffi.Pointer<wire_TransactionParams> Function()>>(
      'new_box_autoadd_transaction_params_0');
  late final _new_box_autoadd_transaction_params_0 =
      _new_box_autoadd_transaction_params_0Ptr
          .asFunction<ffi.Pointer<wire_TransactionParams> Function()>();

  ffi.Pointer<wire_WalletInfo> new_box_autoadd_wallet_info_0() {
    return _new_box_autoadd_wallet_info_0();
  }

  late final _new_box_autoadd_wallet_info_0Ptr =
      _lookup<ffi.NativeFunction<ffi.Pointer<wire_WalletInfo> Function()>>(
          'new_box_autoadd_wallet_info_0');
  late final _new_box_autoadd_wallet_info_0 = _new_box_autoadd_wallet_info_0Ptr
      .asFunction<ffi.Pointer<wire_WalletInfo> Function()>();

  ffi.Pointer<wire_uint_8_list> new_uint_8_list_0(
    int len,
  ) {
    return _new_uint_8_list_0(
      len,
    );
  }

  late final _new_uint_8_list_0Ptr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<wire_uint_8_list> Function(ffi.Int32)>>(
      'new_uint_8_list_0');
  late final _new_uint_8_list_0 = _new_uint_8_list_0Ptr
      .asFunction<ffi.Pointer<wire_uint_8_list> Function(int)>();

  void free_WireSyncReturn(
    WireSyncReturn ptr,
  ) {
    return _free_WireSyncReturn(
      ptr,
    );
  }

  late final _free_WireSyncReturnPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(WireSyncReturn)>>(
          'free_WireSyncReturn');
  late final _free_WireSyncReturn =
      _free_WireSyncReturnPtr.asFunction<void Function(WireSyncReturn)>();
}

final class _Dart_Handle extends ffi.Opaque {}

final class wire_uint_8_list extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> ptr;

  @ffi.Int32()
  external int len;
}

final class wire_NetworkInfo extends ffi.Struct {
  external ffi.Pointer<wire_uint_8_list> node_url;

  external ffi.Pointer<wire_uint_8_list> faucet_url;
}

final class wire_WalletInfo extends ffi.Struct {
  external ffi.Pointer<wire_uint_8_list> alias;

  external ffi.Pointer<wire_uint_8_list> mnemonic;

  external ffi.Pointer<wire_uint_8_list> stronghold_password;

  external ffi.Pointer<wire_uint_8_list> stronghold_filepath;

  external ffi.Pointer<wire_uint_8_list> last_address;
}

final class wire_TransactionParams extends ffi.Struct {
  external ffi.Pointer<wire_uint_8_list> transaction_tag;

  external ffi.Pointer<wire_uint_8_list> transaction_metadata;

  external ffi.Pointer<wire_uint_8_list> receiver_address;

  external ffi.Pointer<wire_uint_8_list> storage_deposit_return_address;
}

typedef DartPostCObjectFnType = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Bool Function(DartPort port_id, ffi.Pointer<ffi.Void> message)>>;
typedef DartPort = ffi.Int64;
