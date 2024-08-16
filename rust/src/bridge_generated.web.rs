use super::*;
// Section: wire functions

#[wasm_bindgen]
pub fn wire_get_node_info(port_: MessagePort, network_info: JsValue) {
    wire_get_node_info_impl(port_, network_info)
}

#[wasm_bindgen]
pub fn wire_generate_mnemonic(port_: MessagePort) {
    wire_generate_mnemonic_impl(port_)
}

#[wasm_bindgen]
pub fn wire_create_wallet_account(port_: MessagePort, network_info: JsValue, wallet_info: JsValue) {
    wire_create_wallet_account_impl(port_, network_info, wallet_info)
}

#[wasm_bindgen]
pub fn wire_get_addresses(port_: MessagePort, wallet_info: JsValue) {
    wire_get_addresses_impl(port_, wallet_info)
}

#[wasm_bindgen]
pub fn wire_create_transaction(
    port_: MessagePort,
    wallet_info: JsValue,
    transaction_params: JsValue,
) {
    wire_create_transaction_impl(port_, wallet_info, transaction_params)
}

#[wasm_bindgen]
pub fn wire_create_advanced_transaction(
    port_: MessagePort,
    wallet_info: JsValue,
    transaction_params: JsValue,
) {
    wire_create_advanced_transaction_impl(port_, wallet_info, transaction_params)
}

#[wasm_bindgen]
pub fn wire_generate_address(port_: MessagePort, wallet_info: JsValue) {
    wire_generate_address_impl(port_, wallet_info)
}

#[wasm_bindgen]
pub fn wire_get_sent_transactions(port_: MessagePort, wallet_info: JsValue) {
    wire_get_sent_transactions_impl(port_, wallet_info)
}

#[wasm_bindgen]
pub fn wire_get_received_transactions(port_: MessagePort, wallet_info: JsValue) {
    wire_get_received_transactions_impl(port_, wallet_info)
}

#[wasm_bindgen]
pub fn wire_get_single_transaction(
    port_: MessagePort,
    wallet_info: JsValue,
    transaction_id: String,
) {
    wire_get_single_transaction_impl(port_, wallet_info, transaction_id)
}

#[wasm_bindgen]
pub fn wire_check_balance(port_: MessagePort, wallet_info: JsValue) {
    wire_check_balance_impl(port_, wallet_info)
}

#[wasm_bindgen]
pub fn wire_request_funds(port_: MessagePort, network_info: JsValue, wallet_info: JsValue) {
    wire_request_funds_impl(port_, network_info, wallet_info)
}

#[wasm_bindgen]
pub fn wire_create_decentralized_identifier(
    port_: MessagePort,
    network_info: JsValue,
    wallet_info: JsValue,
) {
    wire_create_decentralized_identifier_impl(port_, network_info, wallet_info)
}

#[wasm_bindgen]
pub fn wire_bin_to_hex(port_: MessagePort, val: String, len: usize) {
    wire_bin_to_hex_impl(port_, val, len)
}

#[wasm_bindgen]
pub fn wire_create_iota_account(port_: MessagePort, network_info: JsValue, wallet_info: JsValue) {
    wire_create_iota_account_impl(port_, network_info, wallet_info)
}

#[wasm_bindgen]
pub fn wire_write_advanced_transaction(
    port_: MessagePort,
    transaction_params: JsValue,
    wallet_info: JsValue,
) {
    wire_write_advanced_transaction_impl(port_, transaction_params, wallet_info)
}

#[wasm_bindgen]
pub fn wire_read_incoming_transactions(port_: MessagePort, wallet_info: JsValue) {
    wire_read_incoming_transactions_impl(port_, wallet_info)
}

#[wasm_bindgen]
pub fn wire_read_outgoing_transactions(port_: MessagePort, wallet_info: JsValue) {
    wire_read_outgoing_transactions_impl(port_, wallet_info)
}

#[wasm_bindgen]
pub fn wire_get_balance(port_: MessagePort, wallet_info: JsValue) {
    wire_get_balance_impl(port_, wallet_info)
}

// Section: allocate functions

// Section: related functions

// Section: impl Wire2Api

impl Wire2Api<String> for String {
    fn wire2api(self) -> String {
        self
    }
}

impl Wire2Api<NetworkInfo> for JsValue {
    fn wire2api(self) -> NetworkInfo {
        let self_ = self.dyn_into::<JsArray>().unwrap();
        assert_eq!(
            self_.length(),
            2,
            "Expected 2 elements, got {}",
            self_.length()
        );
        NetworkInfo {
            node_url: self_.get(0).wire2api(),
            faucet_url: self_.get(1).wire2api(),
        }
    }
}
impl Wire2Api<TransactionParams> for JsValue {
    fn wire2api(self) -> TransactionParams {
        let self_ = self.dyn_into::<JsArray>().unwrap();
        assert_eq!(
            self_.length(),
            4,
            "Expected 4 elements, got {}",
            self_.length()
        );
        TransactionParams {
            transaction_tag: self_.get(0).wire2api(),
            transaction_metadata: self_.get(1).wire2api(),
            receiver_address: self_.get(2).wire2api(),
            storage_deposit_return_address: self_.get(3).wire2api(),
        }
    }
}

impl Wire2Api<Vec<u8>> for Box<[u8]> {
    fn wire2api(self) -> Vec<u8> {
        self.into_vec()
    }
}

impl Wire2Api<WalletInfo> for JsValue {
    fn wire2api(self) -> WalletInfo {
        let self_ = self.dyn_into::<JsArray>().unwrap();
        assert_eq!(
            self_.length(),
            5,
            "Expected 5 elements, got {}",
            self_.length()
        );
        WalletInfo {
            alias: self_.get(0).wire2api(),
            mnemonic: self_.get(1).wire2api(),
            stronghold_password: self_.get(2).wire2api(),
            stronghold_filepath: self_.get(3).wire2api(),
            last_address: self_.get(4).wire2api(),
        }
    }
}
// Section: impl Wire2Api for JsValue

impl<T> Wire2Api<Option<T>> for JsValue
where
    JsValue: Wire2Api<T>,
{
    fn wire2api(self) -> Option<T> {
        (!self.is_null() && !self.is_undefined()).then(|| self.wire2api())
    }
}
impl Wire2Api<String> for JsValue {
    fn wire2api(self) -> String {
        self.as_string().expect("non-UTF-8 string, or not a string")
    }
}
impl Wire2Api<u8> for JsValue {
    fn wire2api(self) -> u8 {
        self.unchecked_into_f64() as _
    }
}
impl Wire2Api<Vec<u8>> for JsValue {
    fn wire2api(self) -> Vec<u8> {
        self.unchecked_into::<js_sys::Uint8Array>().to_vec().into()
    }
}
impl Wire2Api<usize> for JsValue {
    fn wire2api(self) -> usize {
        self.unchecked_into_f64() as _
    }
}
