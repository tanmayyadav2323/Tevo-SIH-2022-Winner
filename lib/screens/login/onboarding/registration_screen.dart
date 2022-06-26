import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:tevo/screens/login/widgets/standard_elevated_button.dart';
import 'package:tevo/utils/session_helper.dart';
import 'package:tevo/utils/theme_constants.dart';

class RegistrationScreen extends StatefulWidget {
  final PageController pageController;

  const RegistrationScreen({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final FocusNode _firstfocusNode = FocusNode();
  final FocusNode _lastfocusNode = FocusNode();
  bool isButtonNotActive1 = true;
  bool isButtonNotActive2 = true;

  @override
  void initState() {
    _firstfocusNode.requestFocus();
    _firstNameController.addListener(() {
      final isButtonNotActive1 = _firstNameController.text.isEmpty;
      setState(() {
        this.isButtonNotActive1 = isButtonNotActive1;
      });
    });
    _secondNameController.addListener(() {
      final isButtonNotActive2 = _firstNameController.text.isEmpty;
      setState(() {
        this.isButtonNotActive2 = isButtonNotActive2;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _firstfocusNode.dispose();
    _lastfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SizedBox(height: 10.h),
                Text(
                  "What's your full name?",
                  style: TextStyle(fontSize: 20.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  "People use their real name at Tevo",
                  style: TextStyle(fontSize: 10.sp),
                ),
                SizedBox(height: 8.h),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 8.h,
                          width: 30.w,
                          child: TextField(
                            controller: _firstNameController,
                            focusNode: _firstfocusNode,
                            onSubmitted: (_) {
                              _lastfocusNode.requestFocus();
                            },
                            autofocus: true,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: kPrimaryBlackColor,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: kPrimaryBlackColor,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: kPrimaryBlackColor,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              focusedErrorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: kPrimaryBlackColor,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              filled: true,
                              hintText: "First",
                              hintStyle: TextStyle(
                                  fontSize: 12.sp,
                                  color: kPrimaryBlackColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        SizedBox(
                          height: 8.h,
                          width: 30.w,
                          child: TextField(
                            focusNode: _lastfocusNode,
                            controller: _secondNameController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: kPrimaryBlackColor,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: kPrimaryBlackColor,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: kPrimaryBlackColor,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              focusedErrorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: kPrimaryBlackColor,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              filled: true,
                              hintText: "Last",
                              hintStyle: TextStyle(
                                  fontSize: 12.sp,
                                  color: kPrimaryBlackColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        )
                      ],
                    )),
              ],
            ),
            StandardElevatedButton(
              labelText: "Continue →",
              onTap: () {
                widget.pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn);
                SessionHelper.firstName = _firstNameController.text;
                SessionHelper.lastName = _secondNameController.text;
                SessionHelper.displayName = _firstNameController.text +
                    " " +
                    _secondNameController.text;
              },
              isButtonNull: isButtonNotActive1 || isButtonNotActive2,
            ),
            Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom)),
          ],
        ),
      ),
    );
  }
}