import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unify_secret/data/models/user.dart';
import 'package:unify_secret/ui/features/auth/login/login_screen.dart';
import 'package:unify_secret/ui/features/privacy_policy/privacy_policy_screen.dart';
import 'package:unify_secret/ui/features/test_screen/test_screen_screen.dart';
import '../../../../utils/button_util.dart';
import '../../../../utils/dimens.dart';
import '../../../../utils/spacers.dart';
import '../../../../utils/text_util.dart';
import '../../../helper/app_widgets.dart';
import '../../../helper/global_variables.dart';
import 'welcome_controller.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = Get.put(WelcomeController());
  final _formKey = GlobalKey<FormState>();
  final emailEditController = TextEditingController();
  final passEditController = TextEditingController();
  RxBool isShowPassword = false.obs;

  //Box userBox = Hive.box<UsersCollection>('users');


  late Box<User> userBox;

  @override
  void initState() {
    super.initState();

    userBox = Hive.box('users');
  }

  @override
  Widget build(BuildContext context) {
    GlobalVariables.currentContext = context;
    return Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        // appBar: appBarMain(title: "".tr, context: context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Dimens.paddingLarge),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    // const AppLogo(),
                    const AppLogoWithTitle(),
                    vSpacer30(),
                    // const Center(
                    //     child: TextAutoMetropolis(
                    //   "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.",
                    //   fontSize: 12,
                    //   maxLines: 12,
                    //   textAlign: TextAlign.center,
                    // )),
                    // vSpacer30(),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: [
                      userBox.isEmpty
                          ? SizedBox(
                              width: Get.width / 1.5,
                              child: Obx(() => ButtonFillMainWhiteBg(
                                  title: "Create new IOTA Profile".tr,
                                  isLoading: _controller.isLoading.value,
                                  onPress: () {
                                    Get.to(() => const PrivacyPolicyScreen()
                                        // Get.to(() => const CreateNewProfile()
                                        );
                                  })),
                            )
                          : const SizedBox(),
                      // vSpacer10(),
                      // SizedBox(
                      //   width: Get.width / 1.5,
                      //   child: Obx(() => ButtonFillMainWhiteBg(
                      //       title: "Add Existing Shimmer Profile".tr,
                      //       isLoading: _controller.isLoading.value,
                      //       onPress: () {
                      //         Get.to(() => const TestScreen());
                      //       })),
                      // ),
                      vSpacer20(),
                      userBox.isNotEmpty?
                      Center(
                        child: SizedBox(
                          width: Get.width / 3.5,
                          child: Obx(() => ButtonFillMain(
                              title: "Login".tr,
                              isLoading: _controller.isLoading.value,
                              onPress: () {
                                Get.to(() => const LogInScreen());
                              })),
                        ),
                      ): const SizedBox(),
                      vSpacer100(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
