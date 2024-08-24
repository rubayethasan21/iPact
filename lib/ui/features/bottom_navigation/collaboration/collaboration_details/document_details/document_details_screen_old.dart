import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:unify_secret/data/local/constants.dart';
import 'package:unify_secret/data/models/collaboration/collaborations.dart';
import 'package:unify_secret/data/models/collaboration/documents.dart';
import 'package:unify_secret/data/models/transaction.dart';
import 'package:unify_secret/data/models/user.dart';
import 'package:unify_secret/ffi.dart';
import 'package:unify_secret/ui/features/bottom_navigation/collaboration/collaboration_details/document_details/document_details_controller.dart';
import 'package:unify_secret/ui/features/bottom_navigation/encryption/encryption_controller_final.dart';
import 'package:unify_secret/ui/features/bottom_navigation/encryption/encryption_utils.dart';
import 'package:unify_secret/ui/helper/app_widgets.dart';
import 'package:unify_secret/ui/helper/global_variables.dart';
import 'package:unify_secret/utils/appbar_util.dart';
import 'package:unify_secret/utils/button_util.dart';
import 'package:unify_secret/utils/common_utils.dart';
import 'package:unify_secret/utils/common_widgets.dart';
import 'package:unify_secret/utils/dimens.dart';
import 'package:unify_secret/utils/spacers.dart';
import 'package:unify_secret/utils/text_field_util.dart';
import 'package:unify_secret/utils/text_util.dart';

class DocumentDetailsScreen extends StatefulWidget {
  final String? collaborationId;
  final String? documentName;
  final bool? documentShareStatus;
  final String? filePath;
  final String? fileId;
  final String? fileOriginalName;
  final String? generateKeyFileForSymmetricCryptography;
  final String? symmetricEncryptFile;
  final String? asymmetricEncryptFile;
  final String? asymmetricDecryptFile;
  final String? symmetricDecryptFile;
  final String? originalFileHash;
  final String? symmetricEncryptFileHash;
  final bool? ownDocument;
  final String? originalFileHashTransactionId;
  final String? symmetricEncryptFileHashTransactionId;
  final String? asymmetricDecryptFileHash;
  final String? asymmetricDecryptFileHashTransactionId;
  final bool? isCryptographicKeyShared;
  final String? cryptographicKeyTransactionId;

  const DocumentDetailsScreen({
    super.key,
    this.collaborationId,
    this.documentName,
    this.documentShareStatus,
    this.filePath,
    this.fileId,
    this.fileOriginalName,
    this.generateKeyFileForSymmetricCryptography,
    this.symmetricEncryptFile,
    this.asymmetricEncryptFile,
    this.asymmetricDecryptFile,
    this.symmetricDecryptFile,
    this.originalFileHash,
    this.symmetricEncryptFileHash,
    this.ownDocument,
    this.originalFileHashTransactionId,
    this.symmetricEncryptFileHashTransactionId,
    this.asymmetricDecryptFileHash,
    this.asymmetricDecryptFileHashTransactionId,
    this.isCryptographicKeyShared,
    this.cryptographicKeyTransactionId,
  });

  @override
  DocumentDetailsScreenState createState() => DocumentDetailsScreenState();
}

class DocumentDetailsScreenState extends State<DocumentDetailsScreen> {
  final _controller = Get.put(DocumentDetailsController());
  final _controllerEncryptionControllerFinal =
      Get.put(EncryptionControllerFinal());

  final _encryptionControllerFinal = Get.put(EncryptionControllerFinal());

  bool _isChecked = false;

  EncryptionUtils objectInstance = EncryptionUtils();

  late Box<Documents> documentsBox;
  bool isFileEncrypted = false;

  late Box<Collaborations> collaborationBox;
  late Collaborations collaborations;

  late Box<User> userBox;
  late User user;

  late String iPactWalletFilePathValue;

  @override
  void initState() {
    super.initState();
    _getIpactWalletFilePath();

    documentsBox = Hive.box('documents');
    _checkEncryptionStatus();

    userBox = Hive.box<User>('users');
    if (userBox.isNotEmpty) {
      user = userBox.values.first;
    } else {
      // empty state
    }

    collaborationBox = Hive.box('collaborations');
    if (collaborationBox.isNotEmpty) {
      collaborations = collaborationBox.values.first;
    } else {
      // empty state
    }

    _receiveAsymmetricDecryptionConfirmation();
    _receiveCryptographicKey();
  }

  Future<dynamic> _readCryptographicKeyFromTangle(
      String collaborationId, String fileId) async {
    // Read incoming transactions
    final receivedText = await api.readIncomingTransactions(
        walletInfo: WalletInfo(
      alias: user.userName.toString(),
      mnemonic: '',
      strongholdPassword: '',
      strongholdFilepath: iPactWalletFilePathValue.toString(),
      lastAddress: '',
    ));

    print('receivedText');
    print(receivedText);

    // Parse the JSON string
    List<dynamic> jsonList = jsonDecode(receivedText);

    List<Transaction> transactions =
        jsonList.map((json) => Transaction.fromJson(json)).toList();

    List<Map<String, dynamic>?> transactionList = transactions
        .map((transaction) {
          try {
            if (transaction.metadata != null &&
                transaction.metadata.isNotEmpty) {
              var transactionMetadata = jsonDecode(transaction.metadata);
              if (transactionMetadata['a'] == 5 &&
                  transactionMetadata['b'] == collaborationId &&
                  transactionMetadata['c'] == fileId) {
                return {
                  'transactionType': transactionMetadata['a'].toString(),
                  'transactionId': transaction.transactionId,
                  'collaborationId': transactionMetadata['b'],
                  'fileId': transactionMetadata['c'],
                  'cryptographicKey': transactionMetadata['d'],
                };
              }
            }
          } catch (e) {
            print(e.toString());
          }
          return null; // Return null for transactions that don't meet the criteria
        })
        .where((item) => item != null)
        .toList(); // Remove null entries from the list

    if (transactionList.isNotEmpty) {
      return transactionList.first;
    } else {
      return null;
    }
  }

  _receiveCryptographicKey() async {
    if (widget.ownDocument == false &&
        widget.documentShareStatus == true &&
        (widget.cryptographicKeyTransactionId == null ||
            widget.cryptographicKeyTransactionId == '')) {

      /*showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(
              message:
                  'Please wait while we process your request.\nDo not close the app.\nThank you for your patience.',
              context: context);
        },
      );*/

      try {
        iPactWalletFilePathValue = await iPactWalletFilePath();
        var transactionValue = await _readCryptographicKeyFromTangle(
            widget.collaborationId.toString(), widget.fileId.toString());
        print("_receiveCryptographicKey");
        print(transactionValue);

        if (transactionValue != null) {
          var cryptographicKeyTransactionId = transactionValue['transactionId'];

          if (transactionValue['cryptographicKey'] != null ||
              transactionValue['cryptographicKey'] != '') {
            await _controllerEncryptionControllerFinal
                .generateFileForReceivedSymmetricKey(
                    collaborationId: widget.collaborationId.toString(),
                    fileId: widget.fileId,
                    cryptographicKey: transactionValue?['cryptographicKey']);
            var symmetricDecryptedFilePath =
                await _controllerEncryptionControllerFinal.symmetricDecryptFile(
                    collaborationId: widget.collaborationId.toString(),
                    fileId: widget.fileId,
                    fileExtension: 'txt');

            print('symmetricDecryptedFilePath');
            print(symmetricDecryptedFilePath);
            if (cryptographicKeyTransactionId != '' ||
                cryptographicKeyTransactionId != null) {
              List<Documents> documents = documentsBox.values.toList();

              var filteredDocumentsList = documents
                  .where((documents) => documents.fileId == widget.fileId)
                  .toList();

              if (filteredDocumentsList.isNotEmpty) {
                var firstDocument = filteredDocumentsList.first;

                var updatedDocuments = Documents(
                  collaborationId: firstDocument.collaborationId,
                  documentName: firstDocument.documentName,
                  documentShareStatus: firstDocument.documentShareStatus,
                  filePath: firstDocument.filePath,
                  fileId: firstDocument.fileId,
                  fileOriginalName: firstDocument.fileOriginalName,
                  generateKeyFileForSymmetricCryptography:
                      firstDocument.generateKeyFileForSymmetricCryptography,
                  symmetricEncryptFile: firstDocument.symmetricEncryptFile,
                  asymmetricEncryptFile: firstDocument.asymmetricEncryptFile,
                  asymmetricDecryptFile: firstDocument.asymmetricDecryptFile,
                  symmetricDecryptFile: symmetricDecryptedFilePath,
                  originalFileHash: firstDocument.originalFileHash,
                  symmetricEncryptFileHash:
                      firstDocument.symmetricEncryptFileHash,
                  ownDocument: firstDocument.ownDocument,
                  originalFileHashTransactionId:
                      firstDocument.originalFileHashTransactionId,
                  symmetricEncryptFileHashTransactionId:
                      firstDocument.symmetricEncryptFileHashTransactionId,
                  symmetricDecryptFileHash:
                      firstDocument.symmetricDecryptFileHash,
                  asymmetricDecryptFileHash:
                      firstDocument.asymmetricDecryptFileHash,
                  symmetricDecryptFileHashTransactionId:
                      firstDocument.symmetricDecryptFileHashTransactionId,
                  asymmetricDecryptFileHashTransactionId:
                      firstDocument.asymmetricDecryptFileHashTransactionId,
                  isCryptographicKeyShared: true,
                  cryptographicKeyTransactionId: cryptographicKeyTransactionId,
                );
                await documentsBox.put(firstDocument.key, updatedDocuments);
                Navigator.pop(context);
                Get.snackbar('Success', 'The Final decryption is completed.',
                    snackPosition: SnackPosition.BOTTOM);
              }
            }
          }
        }
        // Navigator.pop(context); // Close the dialog
        // Go back to the previous screen
      } catch (e) {
        Navigator.pop(context); // Close the dialog
        Get.snackbar('Error', e.toString(),
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> _receiveAsymmetricDecryptionConfirmation() async {
    // following code only will be executed if the initial decryption of file is done by the receiver
    print('widget.asymmetricDecryptFileHash');
    print(widget.asymmetricDecryptFileHash);

    if (widget.ownDocument == true &&
        widget.documentShareStatus == true &&
        (widget.asymmetricDecryptFileHash == null ||
            widget.asymmetricDecryptFileHash == '')) {
      print('here');
      iPactWalletFilePathValue = await iPactWalletFilePath();
      var transactionValue = await _readFileHashFromTangle(
          widget.symmetricEncryptFileHash.toString());
      print("transactionValue");
      print(transactionValue);

      List<Documents> documents = documentsBox.values.toList();

      var filteredDocumentsList = documents
          .where((documents) => documents.fileId == widget.fileId)
          .toList();

      if (filteredDocumentsList.isNotEmpty) {
        var firstDocument = filteredDocumentsList.first;

        var updatedDocuments = Documents(
          collaborationId: firstDocument.collaborationId,
          documentName: firstDocument.documentName,
          documentShareStatus: firstDocument.documentShareStatus,
          filePath: firstDocument.filePath,
          fileId: firstDocument.fileId,
          fileOriginalName: firstDocument.fileOriginalName,
          generateKeyFileForSymmetricCryptography:
              firstDocument.generateKeyFileForSymmetricCryptography,
          symmetricEncryptFile: firstDocument.symmetricEncryptFile,
          asymmetricEncryptFile: firstDocument.asymmetricEncryptFile,
          asymmetricDecryptFile: firstDocument.asymmetricDecryptFile,
          symmetricDecryptFile: firstDocument.symmetricDecryptFile,
          originalFileHash: firstDocument.originalFileHash,
          symmetricEncryptFileHash: firstDocument.symmetricEncryptFileHash,
          ownDocument: firstDocument.ownDocument,
          originalFileHashTransactionId:
              firstDocument.originalFileHashTransactionId,
          symmetricEncryptFileHashTransactionId:
              firstDocument.symmetricEncryptFileHashTransactionId,
          symmetricDecryptFileHash: firstDocument.symmetricDecryptFileHash,
          asymmetricDecryptFileHash: transactionValue['fileHash'],
          symmetricDecryptFileHashTransactionId:
              firstDocument.symmetricDecryptFileHashTransactionId,
          asymmetricDecryptFileHashTransactionId:
              transactionValue['transactionId'],
          isCryptographicKeyShared: firstDocument.isCryptographicKeyShared,
          cryptographicKeyTransactionId:
              firstDocument.cryptographicKeyTransactionId,
        );
        await documentsBox.put(firstDocument.key, updatedDocuments);
      }
    }
  }

  Future<Map<String, String>> _readFileHashFromTangle(
      String asymmetricDecryptedFileHash) async {
    print('getIncomingCollaborationsFromTangle');
    print(user.userName.toString());

    // Read incoming transactions
    final receivedText = await api.readIncomingTransactions(
        walletInfo: WalletInfo(
      alias: user.userName.toString(),
      mnemonic: '',
      strongholdPassword: '',
      strongholdFilepath: iPactWalletFilePathValue.toString(),
      lastAddress: '',
    ));

    print('receivedText');
    print(receivedText);

    // Parse the JSON string
    List<dynamic> jsonList = jsonDecode(receivedText);
    List<Transaction> transactions =
        jsonList.map((json) => Transaction.fromJson(json)).toList();

    // Convert List<Transaction> to List<Map<String, String>>
    List<Map<String, String>> transactionList = transactions.map((transaction) {
      // Handle the metadata correctly
      List<String> data = [];
      try {
        if (transaction.metadata != null && transaction.metadata.isNotEmpty) {
          if (transaction.metadata.startsWith('{') &&
              transaction.metadata.endsWith('}')) {
            data = transaction.metadata
                .substring(4, transaction.metadata.length - 1)
                .split(', ');
          } else if (transaction.metadata.startsWith('[') &&
              transaction.metadata.endsWith(']')) {
            data = jsonDecode(transaction.metadata).cast<String>();
          }
        }
        print("data--");
        print(data);
      } catch (e) {
        print('Error parsing metadata: $e');
      }

      print("data--");
      print(data);

      return {
        // 'transactionType': data.isNotEmpty ? data[0] : '',
        'transactionId': transaction.transactionId,
        'collaborationId': data.isNotEmpty ? data[0] : '',
        'fileId': data.length > 1 ? data[1] : '',
        'fileHash': data.length > 2 ? data[2] : '',
      };
    }).toList();

    // Debug print the resulting list of maps
    for (var _transaction_test in transactionList) {
      print("transaction0");
      print(_transaction_test);
    }

    // return transactionList;

    print(asymmetricDecryptedFileHash);
    // Find the specific file hash in the transaction list
    var foundTransaction = transactionList.firstWhere(
      (transaction) => transaction['fileHash'] == asymmetricDecryptedFileHash,
      // orElse: () => null,
    );

    // Check if the transaction was found and print the result
    if (foundTransaction.isNotEmpty) {
      print('Found transaction: $foundTransaction');
      print('foundTransaction');
    } else {
      print(
          'Transaction with file hash $asymmetricDecryptedFileHash not found.');
    }
    print('foundTransaction');
    print(foundTransaction);
    return foundTransaction;
  }

  void _checkEncryptionStatus() {
    final document = documentsBox.get(widget.fileId);
    if (document != null &&
        document.symmetricEncryptFile != null &&
        document.symmetricEncryptFile!.isNotEmpty) {
      setState(() {
        isFileEncrypted = true;
      });
    }
  }

  @override
  void dispose() {
    hideKeyboard();
    super.dispose();
  }

  void _getIpactWalletFilePath() async {
    iPactWalletFilePathValue = await iPactWalletFilePath();
  }

  Future<String> writeFileHashToTangle(
      TransactionParams transactionParams) async {
    print('writeFileHashToTangle');
    print(user.userName.toString());
    print(iPactWalletFilePathValue.toString());
    final receivedText = await api.writeAdvancedTransaction(
        transactionParams: transactionParams,
        walletInfo: WalletInfo(
          alias: user.userName.toString(),
          mnemonic: '',
          strongholdPassword:
              _controller.strongholdPasswordController.text.toString(),
          // strongholdPassword: 'Rasel1#',
          strongholdFilepath: iPactWalletFilePathValue.toString(),
          lastAddress: '',
        ));
    print(receivedText);
    return receivedText;
  }

  Future<void> handleEncryptionProcess() async {
    if (_controller.strongholdPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Password field can not be empty');
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(
              message:
                  'Please wait while we process your request.\nDo not close the app.\nThank you for your patience.',
              context: context);
        },
      );

      try {
        String collaborationPartnerAddress;
        if (user.userPublicAddress == collaborations.senderIOTAAddress) {
          collaborationPartnerAddress =
              collaborations.receiverIOTAAddress.toString();
        } else {
          collaborationPartnerAddress =
              collaborations.senderIOTAAddress.toString();
        }

        final keyFilePath = await _controllerEncryptionControllerFinal
            .generateKeyFileForSymmetricCryptography(
          collaborationId: widget.collaborationId.toString(),
          fileId: widget.fileId.toString(),
        );

        final symmetricEncryptedFilePath =
            await _controllerEncryptionControllerFinal.symmetricEncryptFile(
          collaborationId: widget.collaborationId.toString(),
          fileId: widget.fileId.toString(),
          fileToEncryptPath: widget.filePath.toString(),
        );

        final appSupportDir = await getApplicationSupportDirectory();

        final asymmetricEncryptedFilePath =
            await _controllerEncryptionControllerFinal.asymmetricEncryptFile(
          collaborationId: widget.collaborationId.toString(),
          fileId: widget.fileId.toString(),
          publicKeyPemFilePath:
              '${appSupportDir.path}/cryptographic_documents/received_cryptographic_keys/${widget.collaborationId}/$collaborationPartnerAddress/public_key.pem',
        );

        // final asymmetricDecryptedFilePath = await _controllerEncryptionControllerFinal.asymmetricDecryptFile(
        //   collaborationId: widget.collaborationId.toString(),
        //   fileId: widget.fileId.toString(),
        // );

        // final symmetricDecryptedFilePath = await _controllerEncryptionControllerFinal.symmetricDecryptFile(
        //   collaborationId: widget.collaborationId.toString(),
        //   fileId: widget.fileId.toString(),
        //   fileName: widget.fileOriginalName.toString(),
        // );

        var originalFileHash =
            await objectInstance.createHashFromFile(widget.filePath.toString());
        print('originalFileHash');
        print(originalFileHash);
        var symmetricEncryptFileHash = await objectInstance
            .createHashFromFile(symmetricEncryptedFilePath.toString());
        print('symmetricEncryptFileHash');
        print(symmetricEncryptFileHash);

        //if current userPublicAddress match with collaboration senderIotaPublicAddress that means the collaboration invitation was sent by the senderIotaPublicAddress
        //otherwise the collaboration invitation was sent by the senderIotaPublicAddress

        var transactionParamsForOriginalFileHash = TransactionParams(
            transactionTag: "",
            //transactionMetadata: "{2, 'collaboration_id', 'document_id', '${originalFileHash.toString()}'}",
            transactionMetadata:
                "{2, ${widget.collaborationId.toString()}, ${widget.fileId.toString()}, $originalFileHash}",
            receiverAddress: '$collaborationPartnerAddress',
            storageDepositReturnAddress: '$collaborationPartnerAddress');

        var transactionParamsSymmetricEncryptedFileHash = TransactionParams(
            transactionTag: "",
            //transactionMetadata: "{2, 'collaboration_id', 'document_id', '${originalFileHash.toString()}'}",
            transactionMetadata:
                "{3, ${widget.collaborationId.toString()}, ${widget.fileId.toString()}, $symmetricEncryptFileHash}",
            receiverAddress: '$collaborationPartnerAddress',
            storageDepositReturnAddress: '$collaborationPartnerAddress');

        var originalFileHashTransactionId =
            await writeFileHashToTangle(transactionParamsForOriginalFileHash);
        var symmetricEncryptFileHashTransactionId = await writeFileHashToTangle(
            transactionParamsSymmetricEncryptedFileHash);
        //need to store  transaction senderAddress, receiverAddress, originalFileHash, symmetricEncryptFileHash

        final documentKey = widget.fileId.toString().trim();
        final existingDocument = documentsBox.get(documentKey);

        List<Documents> documents = documentsBox.values.toList();

        var filteredDocumentsList = documents
            .where((documents) => documents.fileId == widget.fileId)
            .toList();

        if (filteredDocumentsList.isNotEmpty) {
          var firstDocument = filteredDocumentsList.first;

          var updatedDocuments = Documents(
            collaborationId: firstDocument.collaborationId,
            documentName: firstDocument.documentName,
            documentShareStatus: firstDocument.documentShareStatus,
            filePath: firstDocument.filePath,
            fileId: firstDocument.fileId,
            fileOriginalName: firstDocument.fileOriginalName,
            generateKeyFileForSymmetricCryptography: keyFilePath,
            symmetricEncryptFile: symmetricEncryptedFilePath,
            asymmetricEncryptFile: asymmetricEncryptedFilePath,
            asymmetricDecryptFile: firstDocument.asymmetricDecryptFile,
            symmetricDecryptFile: firstDocument.symmetricDecryptFile,
            originalFileHash: originalFileHash.toString(),
            symmetricEncryptFileHash: symmetricEncryptFileHash.toString(),
            ownDocument: firstDocument.ownDocument,
            originalFileHashTransactionId:
                originalFileHashTransactionId.toString(),
            symmetricEncryptFileHashTransactionId:
                symmetricEncryptFileHashTransactionId.toString(),
            symmetricDecryptFileHash: firstDocument.symmetricDecryptFileHash,
            asymmetricDecryptFileHash: firstDocument.asymmetricDecryptFileHash,
            symmetricDecryptFileHashTransactionId:
                firstDocument.symmetricDecryptFileHashTransactionId,
            asymmetricDecryptFileHashTransactionId:
                firstDocument.asymmetricDecryptFileHashTransactionId,
            isCryptographicKeyShared: firstDocument.isCryptographicKeyShared,
            cryptographicKeyTransactionId:
                firstDocument.cryptographicKeyTransactionId,
          );

          await documentsBox.put(firstDocument.key, updatedDocuments);

          Get.snackbar('Success', 'Files encrypted and saved successfully!',
              snackPosition: SnackPosition.BOTTOM);

          setState(() {
            isFileEncrypted = true;
          }); // Refresh the UI after the update

          Navigator.pop(context); // Close the dialog
          Navigator.pop(context); // Go back to the previous screen
          //hideKeyboard();
          //Get.back();
        }
        Get.back();
      } catch (e) {
        print(e.toString());
        Get.snackbar('Error', e.toString());
        Get.back(); // Close the dialog
      }
    }
  }

  Future<void> handleShareCryptographicKeyProcess() async {
    if (_controller.strongholdPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Password field can not be empty');
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(
              message:
                  'Please wait while we process your request.\nDo not close the app.\nThank you for your patience.',
              context: context);
        },
      );

      try {
        String collaborationPartnerAddress;
        if (user.userPublicAddress == collaborations.senderIOTAAddress) {
          collaborationPartnerAddress =
              collaborations.receiverIOTAAddress.toString();
        } else {
          collaborationPartnerAddress =
              collaborations.senderIOTAAddress.toString();
        }

        // final keyFilePath = await _controllerEncryptionControllerFinal
        //     .generateKeyFileForSymmetricCryptography(
        //   collaborationId: widget.collaborationId.toString(),
        //   fileId: widget.fileId.toString(),
        // );

        // final symmetricEncryptedFilePath = await _controllerEncryptionControllerFinal.symmetricEncryptFile(
        //   collaborationId: widget.collaborationId.toString(),
        //       fileId: widget.fileId.toString(),
        //   fileToEncryptPath: widget.filePath.toString(),
        // );

        // final appSupportDir = await getApplicationSupportDirectory();
        //
        // final asymmetricEncryptedFilePath =
        //     await _controllerEncryptionControllerFinal.asymmetricEncryptFile(
        //   collaborationId: widget.collaborationId.toString(),
        //   fileId: widget.fileId.toString(),
        //       publicKeyPemFilePath: '${appSupportDir.path}/cryptographic_documents/received_cryptographic_keys/${widget.collaborationId}/$collaborationPartnerAddress/public_key.pem',
        // );

        // final asymmetricDecryptedFilePath = await _controllerEncryptionControllerFinal.asymmetricDecryptFile(
        //   collaborationId: widget.collaborationId.toString(),
        //   fileId: widget.fileId.toString(),
        // );

        // final symmetricDecryptedFilePath = await _controllerEncryptionControllerFinal.symmetricDecryptFile(
        //   collaborationId: widget.collaborationId.toString(),
        //   fileId: widget.fileId.toString(),
        //   fileName: widget.fileOriginalName.toString(),
        // );

        // var originalFileHash = await objectInstance.createHashFromFile(widget.filePath.toString());
        // print('originalFileHash');
        // print(originalFileHash);
        // var symmetricEncryptFileHash = await objectInstance.createHashFromFile(symmetricEncryptedFilePath.toString());
        // print('symmetricEncryptFileHash');
        // print(symmetricEncryptFileHash);

        //if current userPublicAddress match with collaboration senderIotaPublicAddress that means the collaboration invitation was sent by the senderIotaPublicAddress
        //otherwise the collaboration invitation was sent by the senderIotaPublicAddress

        // var transactionParamsForOriginalFileHash = TransactionParams(
        //     transactionTag: "",
        //     //transactionMetadata: "{2, 'collaboration_id', 'document_id', '${originalFileHash.toString()}'}",
        //     transactionMetadata: "{2, ${widget.collaborationId.toString()}, ${widget.fileId.toString()}, $originalFileHash}",
        //     receiverAddress: '$collaborationPartnerAddress',
        //     storageDepositReturnAddress: '$collaborationPartnerAddress'
        // );

        var symmetricKey = await _encryptionControllerFinal.readSymmetricKey(
            collaborationId: widget.collaborationId.toString(),
            fileId: widget.fileId.toString());

        var metadata = {
          "a": 5,
          "b": widget.collaborationId.toString(),
          "c": widget.fileId.toString(),
          "d": symmetricKey
        };

        var transactionParamsCryptographicKey = TransactionParams(
            transactionTag: "",
            //transactionMetadata: "{5, ${widget.collaborationId.toString()}, ${widget.fileId.toString()}, $symmetricKey}",
            transactionMetadata: jsonEncode(metadata),
            receiverAddress: '$collaborationPartnerAddress',
            storageDepositReturnAddress: '$collaborationPartnerAddress');

        var cryptographicKeyTransactionId =
            await writeFileHashToTangle(transactionParamsCryptographicKey);
        // var symmetricEncryptFileHashTransactionId = await writeFileHashToTangle(transactionParamsCryptographicKey);
        //need to store  transaction senderAddress, receiverAddress, originalFileHash, symmetricEncryptFileHash

        final documentKey = widget.fileId.toString().trim();
        final existingDocument = documentsBox.get(documentKey);

        List<Documents> documents = documentsBox.values.toList();

        var filteredDocumentsList = documents
            .where((documents) => documents.fileId == widget.fileId)
            .toList();

        if (filteredDocumentsList.isNotEmpty) {
          var firstDocument = filteredDocumentsList.first;

          var updatedDocuments = Documents(
            collaborationId: firstDocument.collaborationId,
            documentName: firstDocument.documentName,
            documentShareStatus: firstDocument.documentShareStatus,
            filePath: firstDocument.filePath,
            fileId: firstDocument.fileId,
            fileOriginalName: firstDocument.fileOriginalName,
            generateKeyFileForSymmetricCryptography:
                firstDocument.generateKeyFileForSymmetricCryptography,
            symmetricEncryptFile: firstDocument.documentShareStatus.toString(),
            asymmetricEncryptFile: firstDocument.asymmetricEncryptFile,
            asymmetricDecryptFile: firstDocument.asymmetricDecryptFile,
            symmetricDecryptFile: firstDocument.symmetricDecryptFile,
            originalFileHash: firstDocument.originalFileHash,
            symmetricEncryptFileHash: firstDocument.symmetricEncryptFileHash,
            ownDocument: firstDocument.ownDocument,
            originalFileHashTransactionId:
                firstDocument.originalFileHashTransactionId,
            symmetricEncryptFileHashTransactionId:
                firstDocument.symmetricEncryptFileHashTransactionId,
            symmetricDecryptFileHash: firstDocument.symmetricDecryptFileHash,
            asymmetricDecryptFileHash: firstDocument.asymmetricDecryptFileHash,
            symmetricDecryptFileHashTransactionId:
                firstDocument.symmetricDecryptFileHashTransactionId,
            asymmetricDecryptFileHashTransactionId:
                firstDocument.asymmetricDecryptFileHashTransactionId,
            isCryptographicKeyShared: true,
            cryptographicKeyTransactionId:
                cryptographicKeyTransactionId.toString(),
          );

          await documentsBox.put(firstDocument.key, updatedDocuments);

          Get.snackbar('Success', 'Files encrypted and saved successfully!',
              snackPosition: SnackPosition.BOTTOM);

          setState(() {
            isFileEncrypted = true;
          }); // Refresh the UI after the update

          Navigator.pop(context); // Close the dialog
          Navigator.pop(context); // Go back to the previous screen
          hideKeyboard();
        }
      } catch (e) {
        print(e.toString());
        Get.snackbar('Error', e.toString());
        Navigator.pop(context); // Close the dialog
      }
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   GlobalVariables.currentContext = context;
  //   return Scaffold(
  //       backgroundColor: context.theme.scaffoldBackgroundColor,
  //       appBar: appBarWithBack(title: widget.documentName.toString(), context: context),
  //       body: SafeArea(
  //         child: Column(
  //           children: [
  //             getTabView(
  //               titles: [(widget.ownDocument == true ?
  //               (widget.isCryptographicKeyShared == false ?
  //               "Share Cryptographic Key"
  //                   : "Encrypt & Share".tr)
  //                   : "Decrypt File".tr), "Document Details".tr],
  //               controller: _controller.tabController,
  //               onTap: (selected) {
  //                 _controller.tabSelectedIndex.value = selected;
  //               },
  //             ),
  //             Expanded(
  //               child: TabBarView(
  //                   controller: _controller.tabController,
  //                   children: [ widget.ownDocument == true ?
  //                   widget.isCryptographicKeyShared == false ?
  //                   _shareCryptographicKeyTab()
  //                   : _encryptAndShareTab()
  //                       : _decryptFileFinalTab(), _documentDetailsTab()]),
  //             ),
  //           ],
  //         ),
  //       ));
  // }

  @override
  Widget build(BuildContext context) {
    GlobalVariables.currentContext = context;
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: appBarWithBack(
          title: widget.documentName.toString(), context: context),
      body: SafeArea(
        child: Column(
          children: [
            getTabView(
              titles: [
                widget.ownDocument == true
                    ? (
                        //widget.isCryptographicKeyShared == false
                        //&&
                        widget.documentShareStatus == true
                            //&& widget.asymmetricDecryptFileHashTransactionId!=null
                            //? "Share Cryptographic Key"
                            ? "Share Key"
                            : "Encrypt & Share".tr)
                    : "Decrypt File".tr,
                "Document Details".tr
              ],
              controller: _controller.tabController,
              onTap: (selected) {
                _controller.tabSelectedIndex.value = selected;
              },
            ),
            Expanded(
              child: TabBarView(
                controller: _controller.tabController,
                children: [
                  widget.ownDocument == true
                      ? (
                          //widget.isCryptographicKeyShared == false
                          //&&
                          widget.documentShareStatus == true
                              //&& widget.asymmetricDecryptFileHashTransactionId!=null
                              ? _shareCryptographicKeyTab()
                              : _encryptAndShareTab())
                      : _decryptFileFinalTab(),
                  _documentDetailsTab()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _encryptAndShareTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DocumentsItemDetailsView(
              context: context,
              fileTitle: "Original File",
              documentRealName: widget.fileOriginalName.toString(),
              onTap: () {
                OpenFile.open(widget.filePath.toString());
              },
              onTapDownload: () {
                OpenFile.open(widget.filePath.toString());
              },
            ),

            widget.symmetricEncryptFileHash == null ||
                    widget.symmetricEncryptFileHash ==
                        '' // check if the encryption is not done yet
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      vSpacer10(),
                      TextAutoMetropolis(
                        "Stronghold Password".tr,
                        fontSize: Dimens.fontSizeRegular,
                        textAlign: TextAlign.start,
                      ),
                      vSpacer5(),
                      Obx(
                        () => TextFieldView(
                          controller: _controller.strongholdPasswordController,
                          hint: "Enter your Stronghold Password".tr,
                          isObscure: !_controller.isShowPassword.value,
                          inputType: TextInputType.visiblePassword,
                          validator: TextFieldValidator.emptyValidator,
                          suffix: ShowHideIconView(
                              isShow: _controller.isShowPassword.value,
                              onTap: () => _controller.isShowPassword.value =
                                  !_controller.isShowPassword.value),
                          // onSaved: (value) {
                          //   collabName = value.toString();
                          // },
                        ),
                      ),
                      vSpacer20(),
                      Row(
                        children: <Widget>[
                          Checkbox(
                            focusColor: context.theme.primaryColorDark,
                            activeColor: context.theme.primaryColorDark,
                            checkColor: context.theme.primaryColorLight,
                            value: _isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                _isChecked = value ?? false;
                              });
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isChecked = !_isChecked;
                              });
                            },
                            child: SizedBox(
                              width: Get.width / 1.3,
                              child: const TextAutoPoppins(
                                'I agree to encrypt the document and share the document hash with my collaboration partner via the IOTA Tangle.',
                                maxLines: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      vSpacer20(),
                    ],
                  )
                : const SizedBox(),

            _isChecked == true
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      isFileEncrypted
                          ? const Expanded(
                              child: TextAutoMetropolis(
                                'File is encrypted. Now you can share the encrypted file.',
                                maxLines: 5,
                                fontSize: 16,
                              ),
                            )
                          : Obx(() => SizedBox(
                                width: Get.width / 2.5,
                                child: ButtonFillMainWhiteBg(
                                  title: "Encrypt File".tr,
                                  isLoading: _controller.isLoading.value,
                                  onPress: handleEncryptionProcess,
                                ),
                              )),
                    ],
                  )
                : const SizedBox(),
            ValueListenableBuilder(
              valueListenable: documentsBox.listenable(),
              builder: (context, Box<Documents> box, _) {
                List<Documents> documents = box.values.toList();
                var filteredDocumentsList = documents
                    .where((documents) => documents.fileId == widget.fileId)
                    .toList();

                if (filteredDocumentsList.isNotEmpty) {
                  var firstDocument = filteredDocumentsList.first;

                  // print(firstDocument.symmetricEncryptFile.toString());

                  return firstDocument.symmetricEncryptFileHash
                          .toString()
                          .isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SizedBox(
                            //   width: Get.width / 2.5,
                            //   child: firstDocument.symmetricEncryptFile != null &&
                            //           firstDocument.symmetricEncryptFile.isNotEmpty
                            //       ? const Row(
                            //           crossAxisAlignment: CrossAxisAlignment.center,
                            //           mainAxisAlignment: MainAxisAlignment.spaceAround,
                            //           children: [
                            //             TextAutoMetropolis(
                            //               'File Encrypted',
                            //               fontSize: 16,
                            //               textAlign: TextAlign.center,
                            //             ),
                            //           ],
                            //         )
                            //       : Obx(() => ButtonFillMainWhiteBg(
                            //             title: "Encrypt File".tr,
                            //             isLoading: _controller.isLoading.value,
                            //             onPress: handleEncryptionProcess,
                            //           )),
                            // ),
                            vSpacer20(),
                            firstDocument.symmetricEncryptFile!.isNotEmpty
                                ? DocumentsLockedItemDetailsView(
                                    context: context,
                                    fileTitle: "Symmetric Encrypt File",
                                    documentRealName: firstDocument
                                        .symmetricEncryptFile!
                                        .trim()
                                        .split('/')
                                        .last,
                                    assetName: AssetConstants.icLocked,
                                    onTap: () {
                                      OpenFile.open(firstDocument
                                          .symmetricEncryptFile
                                          .toString());
                                    },
                                  )
                                : const SizedBox(),
                            vSpacer20(),

                            firstDocument.symmetricEncryptFile!.isNotEmpty
                                ? DocumentsLockedItemDetailsView(
                                    context: context,
                                    fileTitle: "Asymmetric Encrypt File",
                                    documentRealName: firstDocument
                                        .asymmetricEncryptFile!
                                        .trim()
                                        .split('/')
                                        .last,
                                    assetName: AssetConstants.icLocked,
                                    onTap: () {
                                      OpenFile.open(widget.filePath.toString());
                                      OpenFile.open(firstDocument
                                          .asymmetricEncryptFile
                                          .toString());
                                    },
                                  )
                                : const SizedBox(),
                            // vSpacer20(),
                            // TextAutoPoppins(
                            //     firstDocument.originalFileHash.toString(),
                            //     maxLines: 5),
                            // TextAutoPoppins(
                            //     firstDocument.symmetricEncryptFileHash
                            //         .toString(),
                            //     maxLines: 5),

                            vSpacer30(),
                            const Center(
                              child: TextAutoMetropolis(
                                'You successfully encrypted the file.\n The hash of original file and symmetric encrypt file is stored in IOTA. \n Now the asymmetric file is now ready to share with your collaboration partner',
                                maxLines: 5,
                                fontSize: 16,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            vSpacer30(),
                            Center(
                              child: SizedBox(
                                width: Get.width / 2.5,
                                child: Obx(() => ButtonFillMain(
                                      title: "Share File".tr,
                                      isLoading: _controller.isLoading.value,
                                      onPress: () async {
                                        await shareFile(
                                            context,
                                            firstDocument.asymmetricEncryptFile
                                                .toString());

                                        // Get.snackbar('Success',
                                        //     'Encrypted file Shared Successfully');
                                      },
                                    )),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox();
                } else {
                  return const Center(child: Text('No document found'));
                }
              },
            ),
            // vSpacer30(),
            // Center(
            //   child: SizedBox(
            //     width: Get.width / 2.5,
            //     child: Obx(() => ButtonFillMain(
            //       title: "Share File".tr,
            //       isLoading: _controller.isLoading.value,
            //       onPress: () async {
            //         await shareFile(widget.filePath.toString());
            //         updateDocumentShareStatus(widget.filePath.toString());
            //       },
            //     )),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _shareCryptographicKeyTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DocumentsItemDetailsView(
              context: context,
              fileTitle: "Original File",
              documentRealName: widget.fileOriginalName.toString(),
              onTap: () {
                OpenFile.open(widget.filePath.toString());
              },
              onTapDownload: () {
                OpenFile.open(widget.filePath.toString());
              },
            ),
            vSpacer20(),
            ValueListenableBuilder(
              valueListenable: documentsBox.listenable(),
              builder: (context, Box<Documents> box, _) {
                List<Documents> documents = box.values.toList();
                var filteredDocumentsList = documents
                    .where((documents) => documents.fileId == widget.fileId)
                    .toList();

                if (filteredDocumentsList.isNotEmpty) {
                  var firstDocument = filteredDocumentsList.first;

                  return firstDocument.symmetricEncryptFileHash
                          .toString()
                          .isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SizedBox(
                            //   width: Get.width / 2.5,
                            //   child: firstDocument.symmetricEncryptFile != null &&
                            //           firstDocument.symmetricEncryptFile.isNotEmpty
                            //       ? const Row(
                            //           crossAxisAlignment: CrossAxisAlignment.center,
                            //           mainAxisAlignment: MainAxisAlignment.spaceAround,
                            //           children: [
                            //             TextAutoMetropolis(
                            //               'File Encrypted',
                            //               fontSize: 16,
                            //               textAlign: TextAlign.center,
                            //             ),
                            //           ],
                            //         )
                            //       : Obx(() => ButtonFillMainWhiteBg(
                            //             title: "Encrypt File".tr,
                            //             isLoading: _controller.isLoading.value,
                            //             onPress: handleEncryptionProcess,
                            //           )),
                            // ),
                            vSpacer20(),
                            firstDocument.symmetricEncryptFile!.isNotEmpty
                                ? DocumentsLockedItemDetailsView(
                                    context: context,
                                    fileTitle: "Symmetric Encrypt File",
                                    documentRealName: firstDocument
                                        .symmetricEncryptFile!
                                        .trim()
                                        .split('/')
                                        .last,
                                    assetName: AssetConstants.icLocked,
                                    onTap: () {
                                      OpenFile.open(firstDocument
                                          .symmetricEncryptFile
                                          .toString());
                                    },
                                  )
                                : const SizedBox(),
                            vSpacer20(),

                            firstDocument.symmetricEncryptFile!.isNotEmpty
                                ? DocumentsLockedItemDetailsView(
                                    context: context,
                                    fileTitle: "Asymmetric Encrypt File",
                                    documentRealName: firstDocument
                                        .asymmetricEncryptFile!
                                        .trim()
                                        .split('/')
                                        .last,
                                    assetName: AssetConstants.icLocked,
                                    onTap: () {
                                      OpenFile.open(widget.filePath.toString());
                                      OpenFile.open(firstDocument
                                          .asymmetricEncryptFile
                                          .toString());
                                    },
                                  )
                                : const SizedBox(),
                            // vSpacer20(),
                            // TextAutoPoppins(
                            //     firstDocument.originalFileHash.toString(),
                            //     maxLines: 5),
                            // TextAutoPoppins(
                            //     firstDocument.symmetricEncryptFileHash
                            //         .toString(),
                            //     maxLines: 5),

                            vSpacer30(),
                            // Center(
                            //   child: SizedBox(
                            //     width: Get.width / 2.5,
                            //     child: Obx(() => ButtonFillMain(
                            //       title: "Share Cryptographic Key".tr,
                            //       isLoading: _controller.isLoading.value,
                            //       onPress: () async {
                            //         await shareFile(context,firstDocument.asymmetricEncryptFile.toString());
                            //         updateDocumentShareStatus(firstDocument.asymmetricEncryptFile.toString());
                            //
                            //         Get.snackbar('Success', 'Encrypted file Shared Successfully');
                            //       },
                            //     )),
                            //   ),
                            // ),
                          ],
                        )
                      : const SizedBox();
                } else {
                  return const Center(child: Text('No document found'));
                }
              },
            ),

            (widget.asymmetricDecryptFileHash == null ||
                    widget.asymmetricDecryptFileHash == '')
                ? Column(children: [
                    vSpacer30(),
                    const Center(
                        child: TextAutoMetropolis(
                      'You have successfully encrypted and share the file with your collaboration partner. Please wait until your collaboration partner perform the initial decryption.',
                      maxLines: 10,
                      textAlign: TextAlign.center,
                      fontSize: 16,
                    )),

                    //TextAutoMetropolis("You have successfully encrypted and share the file with your collaboration partner. Please wait until your collaboration partner erform the initial decryption".tr, fontSize: Dimens.fontSizeRegular),
                    vSpacer5(),
                  ])
                : widget.isCryptographicKeyShared != true
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          vSpacer30(),
                          const Center(
                              child: TextAutoMetropolis(
                            'Your collaboration partner successfully performed the initial decryption. Share the Cryptographic key to your collaboration partner to perform the final decryption to obtain the original document',
                            maxLines: 10,
                            fontSize: 16,
                            textAlign: TextAlign.center,
                          )),

                          //TextAutoMetropolis("Your collaboration partner successfully performed the initial decryption. Share the Cryptographic key to your collaboration partner to perform the final decryption to obtain the original document".tr, fontSize: Dimens.fontSizeRegular),
                          vSpacer5(),
                          vSpacer30(),
                          TextAutoMetropolis("Stronghold Password".tr,
                              fontSize: Dimens.fontSizeRegular),
                          vSpacer5(),
                          Obx(
                            () => TextFieldView(
                              controller:
                                  _controller.strongholdPasswordController,
                              hint: "Enter your Stronghold Password".tr,
                              isObscure: !_controller.isShowPassword.value,
                              inputType: TextInputType.visiblePassword,
                              validator: TextFieldValidator.emptyValidator,
                              suffix: ShowHideIconView(
                                  isShow: _controller.isShowPassword.value,
                                  onTap: () =>
                                      _controller.isShowPassword.value =
                                          !_controller.isShowPassword.value),
                              // onSaved: (value) {
                              //   collabName = value.toString();
                              // },
                            ),
                          ),
                          vSpacer20(),

                          Row(
                            children: <Widget>[
                              Checkbox(
                                focusColor: context.theme.primaryColorDark,
                                activeColor: context.theme.primaryColorDark,
                                checkColor: context.theme.primaryColorLight,
                                value: _isChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isChecked = value ?? false;
                                  });
                                },
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isChecked = !_isChecked;
                                  });
                                },
                                child: SizedBox(
                                  width: Get.width / 1.3,
                                  child: const TextAutoPoppins(
                                    'I agree to share cryptographic key with my collaboration partner via the IOTA Tangle.',
                                    maxLines: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          vSpacer20(),
                        ],
                      )
                    : Column(
                        children: [
                          vSpacer30(),
                          const Center(
                              child: TextAutoMetropolis(
                            'You have successfully shared the Cryptographic Secret to your collaboration partner which can be used to perform the final decryption to obtain the original document',
                            fontSize: 16,
                            textAlign: TextAlign.center,
                            maxLines: 10,
                          )),

                          //TextAutoMetropolis("You have successfully shared the Cryptographic Secret to your collaboration partner which can be used to perform the final decryption to obtain the original document".tr, fontSize: Dimens.fontSizeRegular),
                          vSpacer5(),
                        ],
                      ),

            _isChecked == true
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      isFileEncrypted
                          ? const Expanded(
                              child: TextAutoMetropolis(
                                'The Cryptographic Key is Shared to the collaboration partner through IOTA',
                                maxLines: 5,
                                fontSize: 16,
                              ),
                            )
                          : Obx(() => SizedBox(
                                width: Get.width / 1.8,
                                child: ButtonFillMainWhiteBg(
                                  title: "Share Cryptographic Key".tr,
                                  isLoading: _controller.isLoading.value,
                                  onPress: handleShareCryptographicKeyProcess,
                                ),
                              )),
                    ],
                  )
                : const SizedBox(),
            vSpacer30(),
            // Center(
            //   child: SizedBox(
            //     width: Get.width / 2.5,
            //     child: Obx(() => ButtonFillMain(
            //       title: "Share File".tr,
            //       isLoading: _controller.isLoading.value,
            //       onPress: () async {
            //         await shareFile(widget.filePath.toString());
            //         updateDocumentShareStatus(widget.filePath.toString());
            //       },
            //     )),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _decryptFileFinalTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DocumentsLockedItemDetailsView(
              context: context,
              fileTitle: "Asymmetric Decrypt File",
              documentRealName:
                  widget.asymmetricDecryptFile!.trim().split('/').last,
              assetName: AssetConstants.icLocked,
              onTap: () {
                OpenFile.open(widget.filePath.toString());
                OpenFile.open(widget.asymmetricDecryptFile.toString());
              },
            ),
            vSpacer30(),
            (widget.symmetricDecryptFile != null)
                ? Column(
                    children: [
                      DocumentsItemDetailsView(
                        context: context,
                        fileTitle: "Symmetric Decrypt File/ Original File",
                        documentRealName:
                            widget.symmetricDecryptFile!.trim().split('/').last,
                        onTap: () {
                          OpenFile.open(widget.symmetricDecryptFile.toString());
                        },
                        onTapDownload: () {
                          OpenFile.open(widget.symmetricDecryptFile.toString());
                        },
                      ),
                      vSpacer30(),
                      Center(
                        child: SizedBox(
                          width: Get.width / 1.3,
                          child: const TextAutoMetropolis(
                            'You have successfully completed the final decryption of received file.',
                            maxLines: 10,
                            fontSize: 16,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: SizedBox(
                      width: Get.width / 1.3,
                      child: const TextAutoMetropolis(
                        'You have successfully completed the initial decryption of received file.\nPlease wait until your collaboration partner allow to perform the final decryption.',
                        maxLines: 10,
                        fontSize: 16,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _documentDetailsTab() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: _controller.getData,
        child: SingleChildScrollView(
          child: Column(
            children: [
              vSpacer20(),
              SizedBox(
                height: 100,
                width: 100,
                child: CircleAvatar(
                  radius: 0,
                  backgroundColor: context.theme.dividerColor,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SvgPicture.asset(
                      AssetConstants.icDocument,
                      color: context.theme.primaryColorDark,
                    ),
                  ),
                ),
              ),
              Center(
                child: DocumentCard(
                  collaborationId: widget.collaborationId.toString(),
                  documentName: widget.documentName.toString(),
                  documentShareStatus: widget.documentShareStatus.toString(),
                  filePath: widget.filePath.toString(),
                  fileId: widget.fileId.toString(),
                  fileOriginalName: widget.fileOriginalName.toString(),
                  generateKeyFileForSymmetricCryptography:
                      widget.generateKeyFileForSymmetricCryptography.toString(),
                  symmetricEncryptFile: widget.symmetricEncryptFile.toString(),
                  asymmetricEncryptFile:
                      widget.asymmetricEncryptFile.toString(),
                  asymmetricDecryptFile:
                      widget.asymmetricDecryptFile.toString(),
                  symmetricDecryptFile: widget.symmetricDecryptFile.toString(),
                  originalFileHash: widget.originalFileHash.toString(),
                  symmetricEncryptFileHash:
                      widget.symmetricEncryptFileHash.toString(),
                  ownDocument: widget.ownDocument.toString(),
                  originalFileHashTransactionId:
                      widget.originalFileHashTransactionId.toString(),
                  symmetricEncryptFileHashTransactionId:
                      widget.symmetricEncryptFileHashTransactionId.toString(),
                  asymmetricDecryptFileHash:
                      widget.asymmetricDecryptFileHash.toString(),
                  asymmetricDecryptFileHashTransactionId:
                      widget.asymmetricDecryptFileHashTransactionId.toString(),
                  isCryptographicKeyShared:
                      widget.isCryptographicKeyShared.toString(),
                  cryptographicKeyTransactionId:
                      widget.cryptographicKeyTransactionId.toString(), isFileEncrypted: '',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

/*  @override
  Widget build(BuildContext context) {
    GlobalVariables.currentContext = context;
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: appBarWithBack(title: widget.documentName, context: context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              vSpacer20(),
              DocumentsItemDetailsView(
                context: context,
                documentRealName: widget.fileOriginalName.toString(),
                onTap: () {
                  OpenFile.open(widget.filePath.toString());
                },
                onTapDownload: () {
                  OpenFile.open(widget.filePath.toString());
                },
              ),
              vSpacer20(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: Get.width / 2.5,
                    child: Obx(() => isFileEncrypted
                        ? const Center(
                      child: Text(
                        'File Encrypted',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                        : ButtonFillMainWhiteBg(
                      title: "Encrypt File".tr,
                      isLoading: _controller.isLoading.value,
                      onPress: handleEncryptionProcess,
                    )),
                  ),
                ],
              ),
              ValueListenableBuilder(
                valueListenable: documentsBox.listenable(),
                builder: (context, Box<Documents> box, _) {
                  List<Documents> documents = box.values.toList();
                  var filteredDocumentsList = documents
                      .where((documents) => documents.fileId == widget.fileId)
                      .toList();

                  if (filteredDocumentsList.isNotEmpty) {
                    var firstDocument = filteredDocumentsList.first;

                    return firstDocument.symmetricEncryptFileHash
                            .toString()
                            .isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SizedBox(
                              //   width: Get.width / 2.5,
                              //   child: firstDocument.symmetricEncryptFile != null &&
                              //           firstDocument.symmetricEncryptFile.isNotEmpty
                              //       ? const Row(
                              //           crossAxisAlignment: CrossAxisAlignment.center,
                              //           mainAxisAlignment: MainAxisAlignment.spaceAround,
                              //           children: [
                              //             TextAutoMetropolis(
                              //               'File Encrypted',
                              //               fontSize: 16,
                              //               textAlign: TextAlign.center,
                              //             ),
                              //           ],
                              //         )
                              //       : Obx(() => ButtonFillMainWhiteBg(
                              //             title: "Encrypt File".tr,
                              //             isLoading: _controller.isLoading.value,
                              //             onPress: handleEncryptionProcess,
                              //           )),
                              // ),
                              vSpacer20(),
                              DocumentsLockedItemDetailsView(
                                context: context,
                                documentRealName: firstDocument
                                    .symmetricEncryptFile
                                    .trim()
                                    .split('/')
                                    .last,
                                assetName: AssetConstants.icLocked,
                                onTap: () {
                                  OpenFile.open(firstDocument
                                      .symmetricEncryptFile
                                      .toString());
                                },
                              ),
                              vSpacer20(),
                              DocumentsLockedItemDetailsView(
                                context: context,
                                documentRealName: firstDocument
                                    .asymmetricEncryptFile
                                    .trim()
                                    .split('/')
                                    .last,
                                assetName: AssetConstants.icLocked,
                                onTap: () {
                                  OpenFile.open(widget.filePath.toString());
                                  OpenFile.open(firstDocument
                                      .asymmetricEncryptFile
                                      .toString());
                                },
                              ),
                              // vSpacer20(),
                              // TextAutoPoppins(
                              //     firstDocument.originalFileHash.toString(),
                              //     maxLines: 5),
                              // TextAutoPoppins(
                              //     firstDocument.symmetricEncryptFileHash
                              //         .toString(),
                              //     maxLines: 5),
                              vSpacer30(),
                              Center(
                                child: SizedBox(
                                  width: Get.width / 2.5,
                                  child: Obx(() => ButtonFillMain(
                                        title: "Share File".tr,
                                        isLoading: _controller.isLoading.value,
                                        onPress: () async {
                                          await shareFile(firstDocument.asymmetricEncryptFile.toString());
                                          updateDocumentShareStatus(firstDocument.asymmetricEncryptFile.toString());

                                          Get.snackbar('Success', 'Encrypted file Shared Successfully');
                                        },
                                      )),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox();
                  } else {
                    return const Center(child: Text('No document found'));
                  }
                },
              ),
              // vSpacer30(),
              // Center(
              //   child: SizedBox(
              //     width: Get.width / 2.5,
              //     child: Obx(() => ButtonFillMain(
              //       title: "Share File".tr,
              //       isLoading: _controller.isLoading.value,
              //       onPress: () async {
              //         await shareFile(widget.filePath.toString());
              //         updateDocumentShareStatus(widget.filePath.toString());
              //       },
              //     )),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }*/

  Future<void> shareFile(BuildContext context, String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Encrypted Document',
      text:
          'Import this encrypted document in iPact Application Receive document section to decrypt',
    );

    Get.snackbar('Success', 'File shared successfully!',
        snackPosition: SnackPosition.BOTTOM);
    updateDocumentShareStatus();
  }

  void updateDocumentShareStatus() async {
    try {
      List<Documents> documents = documentsBox.values.toList();

      var filteredDocumentsList = documents
          .where((documents) => documents.fileId == widget.fileId)
          .toList();

      if (filteredDocumentsList.isNotEmpty) {
        var firstDocument = filteredDocumentsList.first;

        var updatedDocuments = Documents(
          collaborationId: firstDocument.collaborationId,
          documentName: firstDocument.documentName,
          documentShareStatus: true,
          filePath: firstDocument.filePath,
          fileId: firstDocument.fileId,
          fileOriginalName: firstDocument.fileOriginalName,
          generateKeyFileForSymmetricCryptography:
              firstDocument.generateKeyFileForSymmetricCryptography,
          symmetricEncryptFile: firstDocument.symmetricEncryptFile,
          asymmetricEncryptFile: firstDocument.asymmetricEncryptFile,
          asymmetricDecryptFile: firstDocument.asymmetricDecryptFile,
          symmetricDecryptFile: firstDocument.symmetricDecryptFile,
          originalFileHash: firstDocument.originalFileHash.toString(),
          symmetricEncryptFileHash: firstDocument.symmetricEncryptFileHash,
          ownDocument: firstDocument.ownDocument,
          originalFileHashTransactionId:
              firstDocument.originalFileHashTransactionId,
          symmetricEncryptFileHashTransactionId:
              firstDocument.symmetricEncryptFileHashTransactionId,
          symmetricDecryptFileHash: firstDocument.symmetricDecryptFileHash,
          asymmetricDecryptFileHash: firstDocument.asymmetricDecryptFileHash,
          symmetricDecryptFileHashTransactionId:
              firstDocument.symmetricDecryptFileHashTransactionId,
          asymmetricDecryptFileHashTransactionId:
              firstDocument.asymmetricDecryptFileHashTransactionId,
          isCryptographicKeyShared: firstDocument.isCryptographicKeyShared,
          cryptographicKeyTransactionId:
              firstDocument.cryptographicKeyTransactionId,
        );

        await documentsBox.put(firstDocument.key, updatedDocuments);

        // Get.snackbar('Success', 'Files Shared successfully!',
        //     snackPosition: SnackPosition.BOTTOM);

        Navigator.pop(context); // Close the dialog
        // Navigator.pop(context); // Go back to the previous screen
        hideKeyboard();
      }
    } catch (e) {
      print(e.toString());
      Get.snackbar('Error', e.toString());
      Navigator.pop(context); // Close the dialog
    }
    /*final document = documentsBox.values.firstWhere((doc) => doc.filePath == filePath);
    document.documentShareStatus = true;
    document.save();

    Navigator.pop(context);

    if (document.documentShareStatus == true) {


      Future<void> writeFileHashToTangle(
          TransactionParams transactionParams) async {
        debugPrint('writeFileHashToTangle');
        final receivedText = await api.writeAdvancedTransaction(
            transactionParams: transactionParams,
            walletInfo: WalletInfo(
              alias: user.userName.toString(),
              mnemonic: '',
              strongholdPassword: '',
              strongholdFilepath: '',
              lastAddress: '',
            ));
      }
    }*/
  }
// void updateDocumentShareStatus3(String filePath) {
//
//   filteredAllPendingCollaborationsList = allCollaborations.where((collaboration) =>
//   collaboration.collaborationAccepted == false && collaboration.collaborationSent == true).toList();
//
//   final document = documentsBox.values.firstWhere((doc) => doc.filePath == filePath);
//   if (document.filePath.isNotEmpty) {
//     var firstTransaction = document.first;
//     // Do something with firstTransaction
//     print('First Transaction: $firstTransaction');
//
//     // Create a new instance with updated values
//     var updatedCollaboration = Collaborations(
//       collaborationId: pendingCollaboration.collaborationId,
//       collaborationName: pendingCollaboration.collaborationName,
//       collaborationAccepted: true,
//       collaborationSent: pendingCollaboration.collaborationSent,
//       transactionId: firstTransaction['transactionId'].toString(),
//       senderIOTAAddress: pendingCollaboration.senderIOTAAddress,
//       senderPublicKey: pendingCollaboration.senderPublicKey,
//       receiverIOTAAddress: firstTransaction['iotaAddress'].toString(),
//       receiverPublicKey: firstTransaction['publicKey'].toString(),
//     );
//
//     // Replace the old object with the new one
//     await collaborationBox.put(pendingCollaboration.key, updatedCollaboration);
//
//     print('Updated Collaboration: ${pendingCollaboration.collaborationId}');
//   } else {
//     print('No transactions found matching the criteria.');
//   }

// void updateDocumentShareStatus3(String filePath) {
//   final documentKey = documentsBox.keys.firstWhere((key) {
//     final doc = documentsBox.get(key);
//     return doc!.filePath == filePath;
//   });
//
//   if (documentKey != null) {
//     final document = documentsBox.get(documentKey);
//     document?.documentShareStatus = true;
//     document?.save();
//   }
}
