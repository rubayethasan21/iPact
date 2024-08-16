import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:unify_secret/data/models/collaboration/documents.dart';
import 'package:unify_secret/ui/features/bottom_navigation/collaboration/collaboration_details/document_details/document_details_controller.dart';
import 'package:unify_secret/ui/helper/app_widgets.dart';
import 'package:unify_secret/ui/helper/global_variables.dart';
import 'package:unify_secret/utils/appbar_util.dart';
import 'package:unify_secret/utils/button_util.dart';
import 'package:unify_secret/utils/common_utils.dart';
import 'package:unify_secret/utils/spacers.dart';

class DocumentDetailsScreen extends StatefulWidget {
  final String? collaborationId;
  final String? filePath;
  const DocumentDetailsScreen({super.key, this.collaborationId, this.filePath});


  @override
  DocumentDetailsScreenState createState() =>
      DocumentDetailsScreenState();
}

class DocumentDetailsScreenState
    extends State<DocumentDetailsScreen> {
  final _controller = Get.put(DocumentDetailsController());

  late Box<Documents> documentsBox;

  @override
  void initState() {
    super.initState();
    documentsBox = Hive.box('documents');
  }

  void _shareFile() async {
    if (_controller.collaborationNameTextController.value.text.isEmpty) {
      CustomSnackBar.show(context, "Collaboration name can not be empty.");
    } else {
      var dateAndTimeNow = DateTime.now().microsecondsSinceEpoch;
      print(dateAndTimeNow);


      var varOwnPublicKey = _controller.userPublicKey.value;
      var varUserPublicAddress = _controller.userPublicAddress.value;

      final String url =
          'https://play.google.com/store/apps/details?id=de.ipact.ipact_hnn&prm1=$dateAndTimeNow&prm2=$varOwnPublicKey&prm3=$varUserPublicAddress';

      final String emailBody = 'Hi! Someone shared collaboration document $url';

      final result = await Share.shareWithResult(emailBody,
          subject: 'Documents of Collaborate');

      if (result.status == ShareResultStatus.success) {
        // CustomSnackBar.show(context, "Link shared.");
        Get.snackbar('Succeeded', 'Document file shared Successfully.',snackPosition: SnackPosition.BOTTOM);
        print('Document file shared!');
        Navigator.pop(context);

        ///Saving data to local DB
        // updateDocumentAndSaveToHive(
        //   documentShareStatus: true,
        // );
      }
    }
  }

  @override
  void dispose() {
    hideKeyboard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GlobalVariables.currentContext = context;
    return Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: appBarWithBack(title: "Document Name".tr, context: context),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      vSpacer30(),
                      const AppLogo(),
                      vSpacer100(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: Get.width / 2.5,
                            child: Obx(() => ButtonFillMainWhiteBg(
                                title: "View File".tr,
                                isLoading: _controller.isLoading.value,
                                onPress: () {
                                  OpenFile.open(widget.filePath.toString());
                                })),
                          ),
                        ],
                      ),
                      vSpacer20(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: Get.width / 2.5,
                            child: Obx(() => ButtonFillMainWhiteBg(
                                title: "Encrypt File".tr,
                                isLoading: _controller.isLoading.value,
                                onPress: () {

                                })),
                          ),
                        ],
                      ),
                      vSpacer100(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: Get.width / 1.5,
                            child: Obx(() => ButtonFillMain(
                                title: "Share FIle".tr,
                                isLoading: _controller.isLoading.value,
                                onPress: () {
                                  _shareFile();
                                })),
                          ),
                        ],
                      ),
                      vSpacer30(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  // void updateDocumentAndSaveToHive({
  //   required bool documentShareStatus,
  // }) {
  //       documentsBox.add(Documents(
  //         collaborationId: '',
  //         documentName: '',
  //           documentShareStatus: true,
  //         filePath: '',
  //       ));
  //   }


}
