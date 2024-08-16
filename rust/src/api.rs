use anyhow::Result;
//use serde::{Serialize, Serializer};
use serde::Serialize;
use tokio::runtime::Runtime;

use iota_sdk::{
    client::{
        secret::{
            stronghold::StrongholdSecretManager as WalletStrongholdSecretManager,
            SecretManager as WalletSecretManager,
        },
        utils::request_funds_from_faucet,
        Client,
    },
    //types::{api::core::response::OutputWithMetadataResponse, block::{address::Bech32Address, output::AliasOutput, payload::{transaction::{TransactionEssence, TransactionId}, TransactionPayload}, unlock::Unlocks, BlockId}}, wallet::account::types::{InclusionState, Transaction},
    types::{
        api::core::response::OutputWithMetadataResponse,
        block::{
            address::Bech32Address,
            output::AliasOutput,
            payload::transaction::{TransactionEssence, TransactionId},
            unlock::Unlocks,
            BlockId,
        },
    },
    wallet::{account::types::InclusionState, ClientOptions},
    Wallet,
};

use std::{env, path::PathBuf, u32};

use identity_iota::{
    iota::{IotaClientExt, IotaDocument, IotaIdentityClientExt, NetworkName},
    storage::{JwkDocumentExt, JwkMemStore, KeyIdMemstore, Storage},
    verification::{jws::JwsAlgorithm, MethodScope},
};

mod wallet_custom;
mod wallet_singleton;

#[derive(Debug, Clone)]
pub struct NetworkInfo {
    pub node_url: String,
    pub faucet_url: String,
}

/// A transaction to move funds.
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct MyTransactionPayload {
    pub ess: TransactionEssence,
    pub unl: Unlocks,
}

#[derive(Debug, Clone)]
pub struct TransactionParams {
    pub transaction_tag: String,
    pub transaction_metadata: String,
    pub receiver_address: String,
    pub storage_deposit_return_address: String,
}

#[derive(Serialize)]
struct TransactionDetails {
    pub transaction_id: TransactionId, // Example field to serialize
    //payload: TransactionPayload,
    pub payload: String,
    pub metadata: String,
    pub block_id: Option<BlockId>,
    pub inclusion_state: InclusionState,
    // Transaction creation time
    pub timestamp: u128,
    // network id to ignore outputs when set_client_options is used to switch to another network
    pub network_id: u64,
    // set if the transaction was created by the wallet or if it was sent by someone else and is incoming
    pub incoming: bool,
    pub note: Option<String>,
    // serde(default) is needed so it doesn't break with old dbs
    pub inputs: Vec<OutputWithMetadataResponse>,
}

#[derive(Serialize)]
struct TransactionDetailsCustom {
    pub transaction_id: String,
    pub metadata: String,
    pub timestamp: u128,
    pub incoming: bool,
}

#[derive(Debug, Clone)]
pub struct WalletInfo {
    pub alias: String,
    pub mnemonic: String,
    pub stronghold_password: String,
    pub stronghold_filepath: String,
    pub last_address: String,
}

#[derive(Debug, Clone)]
pub struct BaseCoinBalance {
    /// Total amount
    pub total: u64,
    /// Balance that can currently be spent
    pub available: u64,
}

#[allow(dead_code)]
pub fn get_node_info(network_info: NetworkInfo) -> Result<String> {
    Runtime::new().unwrap().block_on(async {
        // Create a client with that node.
        let client = Client::builder()
            .with_node(&network_info.node_url)?
            .with_ignore_node_health()
            .finish()
            .await?;
        // Get node info.
        let info = client.get_info().await?.node_info;
        Ok(serde_json::to_string_pretty(&info).unwrap())
    })
}

#[allow(dead_code)]
pub fn generate_mnemonic() -> String {
    let mnemonic = Client::generate_mnemonic();
    mnemonic.unwrap().to_string()
}

#[allow(dead_code)]
pub fn create_wallet_account(network_info: NetworkInfo, wallet_info: WalletInfo) -> Result<String> {
    wallet_singleton::create_wallet_account(network_info, wallet_info)
}

#[allow(dead_code)]
pub fn get_addresses(wallet_info: WalletInfo) -> Result<String> {
    wallet_singleton::get_addresses(wallet_info)
}

#[allow(dead_code)]
pub fn create_transaction(
    wallet_info: WalletInfo,
    transaction_params: TransactionParams,
) -> Result<String> {
    wallet_singleton::create_transaction(wallet_info, transaction_params)
}

#[allow(dead_code)]
pub fn create_advanced_transaction(
    wallet_info: WalletInfo,
    transaction_params: TransactionParams,
) -> Result<String> {
    wallet_singleton::create_advanced_transaction(wallet_info, transaction_params)
}

#[allow(dead_code)]
pub fn generate_address(wallet_info: WalletInfo) -> Result<String> {
    wallet_singleton::generate_address(wallet_info)
}

#[allow(dead_code)]
pub fn get_sent_transactions(wallet_info: WalletInfo) -> Result<String> {
    wallet_singleton::get_sent_transactions(wallet_info)
}

#[allow(dead_code)]
pub fn get_received_transactions(wallet_info: WalletInfo) -> Result<String> {
    wallet_singleton::get_received_transactions(wallet_info)
}

#[allow(dead_code)]
pub fn get_single_transaction(wallet_info: WalletInfo, transaction_id: String) -> Result<String> {
    wallet_singleton::get_single_transaction(wallet_info, transaction_id)
}

#[allow(dead_code)]
pub fn check_balance(wallet_info: WalletInfo) -> Result<String> {
    wallet_singleton::check_balance(wallet_info)
}

#[allow(dead_code)]
pub fn request_funds(network_info: NetworkInfo, wallet_info: WalletInfo) -> Result<String> {
    Runtime::new().unwrap().block_on(async {
        env::set_current_dir(&wallet_info.stronghold_filepath).ok();
        let faucet_url = network_info.faucet_url;
        // Convert given address (BECH32 string) to Address struct
        let address = Bech32Address::try_from_str(&wallet_info.last_address)?;
        // Use the function iota_wallet::iota_client::request_funds_from_faucet
        let faucet_response = request_funds_from_faucet(&faucet_url, &address).await?;
        Ok(faucet_response.to_string())
    })
}

type MemStorage = Storage<JwkMemStore, KeyIdMemstore>;
#[allow(dead_code)]
pub fn create_decentralized_identifier(
    network_info: NetworkInfo,
    wallet_info: WalletInfo,
) -> Result<String> {
    Runtime::new().unwrap().block_on(async {
        let node_url = network_info.node_url;
        let stronghold_password = wallet_info.stronghold_password;
        let stronghold_filepath = wallet_info.stronghold_filepath;
        let last_address = wallet_info.last_address;

        env::set_current_dir(&stronghold_filepath).ok();

        let mut path_buf_snapshot = PathBuf::new();
        path_buf_snapshot.push(&stronghold_filepath);
        path_buf_snapshot.push("wallet.stronghold");
        let path_snapshot = PathBuf::from(path_buf_snapshot);

        // Create a new client to interact with the IOTA ledger.
        let client: Client = Client::builder()
            .with_primary_node(&node_url, None)?
            .finish()
            .await?;

        // Create a new secret manager backed by a Stronghold.
        let secret_manager: WalletSecretManager = WalletSecretManager::Stronghold(
            WalletStrongholdSecretManager::builder()
                .password(stronghold_password)
                .build(path_snapshot)?,
        );

        // Convert given address (BECH32 string) to Address struct
        let address = Bech32Address::try_from_str(&last_address)?;

        // Get the Bech32 human-readable part (HRP) of the network.
        let network_name: NetworkName = client.network_name().await?;

        // Create a new DID document with a placeholder DID.
        // The DID will be derived from the Alias Id of the Alias Output after publishing.
        let mut document: IotaDocument = IotaDocument::new(&network_name);

        // Insert a new Ed25519 verification method in the DID document.
        let storage: MemStorage = MemStorage::new(JwkMemStore::new(), KeyIdMemstore::new());
        document
            .generate_method(
                &storage,
                JwkMemStore::ED25519_KEY_TYPE,
                JwsAlgorithm::EdDSA,
                None,
                MethodScope::VerificationMethod,
            )
            .await?;

        // Insert a new Ed25519 verification method in the DID document.
        let storage: MemStorage = MemStorage::new(JwkMemStore::new(), KeyIdMemstore::new());
        document
            .generate_method(
                &storage,
                JwkMemStore::ED25519_KEY_TYPE,
                JwsAlgorithm::EdDSA,
                None,
                MethodScope::VerificationMethod,
            )
            .await?;

        // Construct an Alias Output containing the DID document, with the wallet address
        // set as both the state controller and governor.
        let alias_output: AliasOutput = client.new_did_output(*address, document, None).await?;

        // Publish the Alias Output and get the published DID document.
        let document: IotaDocument = client
            .publish_did_output(&secret_manager, alias_output)
            .await?;
        Ok(document.to_string())
    })
}

#[allow(dead_code)]
pub fn bin_to_hex(val: String, len: usize) -> String {
    let n: u32 = u32::from_str_radix(&val, 2).unwrap();
    format!("{:01$x}", n, len * 2)
}

////////////////////////////////new/////////////////////////////
#[allow(dead_code)]
pub fn create_iota_account(
    network_info: NetworkInfo,
    wallet_info: WalletInfo,
) -> Result<String> {
    wallet_custom::create_iota_account(network_info,wallet_info)
}

#[allow(dead_code)]
pub fn write_advanced_transaction(
    transaction_params: TransactionParams,
    wallet_info: WalletInfo,
) -> Result<String> {
    wallet_custom::write_advanced_transaction(transaction_params, wallet_info)
}

#[allow(dead_code)]
pub fn read_incoming_transactions(wallet_info: WalletInfo) -> Result<String> {
    wallet_custom::read_transactions(wallet_info, true)
}

#[allow(dead_code)]
pub fn read_outgoing_transactions(wallet_info: WalletInfo) -> Result<String> {
    wallet_custom::read_transactions(wallet_info, false)
}

#[allow(dead_code)]
pub fn get_balance(wallet_info: WalletInfo) -> Result<String> {
    wallet_custom::get_balance(wallet_info)
}
////////////////////////////////new/////////////////////////////
