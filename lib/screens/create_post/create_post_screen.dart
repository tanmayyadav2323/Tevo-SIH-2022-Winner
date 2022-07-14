import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:tevo/screens/profile/profile_screen.dart';
import 'package:tevo/utils/assets_constants.dart';
import 'package:tevo/utils/session_helper.dart';
import 'package:tevo/utils/theme_constants.dart';
import 'package:tevo/widgets/widgets.dart';
import '../../models/models.dart';
import 'bloc/create_post_bloc.dart';

class CreatePostScreen extends StatefulWidget {
  static const String routeName = '/createPost';

  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _controller = ScrollController();
  AnimationController? bottomModalSheetController;
  final _taskTextEditingController = TextEditingController();
  final _descriptionTextEditingController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    bottomModalSheetController = BottomSheet.createAnimationController(this);
    bottomModalSheetController!.duration = const Duration(milliseconds: 300);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreatePostBloc, CreatePostState>(
      builder: (context, state) {
        return Scaffold(
          body: DefaultTabController(
            length: 2,
            child: NestedScrollView(
              controller: _controller,
              clipBehavior: Clip.none,
              headerSliverBuilder: (_, __) {
                return [_buildAppBar()];
              },
              body: TabBarView(
                children: [
                  _buildRemaining(state),
                  _buildCompleted(state),
                ],
              ),
            ),
          ),
          floatingActionButton: state.post != null
              ? Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: FloatingActionButton(
                      backgroundColor: kPrimaryBlackColor,
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                      color: kPrimaryBlackColor, width: 2.0),
                                ),
                                title: Text(
                                  'Delete today\'s post?',
                                  style: TextStyle(
                                      color: kPrimaryBlackColor,
                                      fontFamily: kFontFamily),
                                ),
                                content: Text(
                                  'This will permanently delete all today\'s targets and can\'t be undone?',
                                  style: TextStyle(
                                      color:
                                          kPrimaryBlackColor.withOpacity(0.6),
                                      fontFamily: kFontFamily,
                                      fontWeight: FontWeight.w400),
                                ),
                                actions: [
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: kPrimaryBlackColor,
                                        fontFamily: kFontFamily,
                                      ),
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      _buildDeletePost();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Yes',
                                      style: TextStyle(
                                        color: kPrimaryBlackColor,
                                        fontFamily: kFontFamily,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            });
                      },
                      child: Icon(Icons.delete_outline_sharp)),
                )
              : null,
        );
      },
    );
  }

  _buildDeletePost() {
    context.read<CreatePostBloc>().add(const DeletePostEvent());
  }

  _buildRemaining(CreatePostState state) {
    final todoTask = state.todoTask;
    return state.status == CreatePostStateStatus.loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : AnimatedPadding(
            duration: const Duration(seconds: 2),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                state.dateTime != null
                    ? _buildRemainingTime(state)
                    : Center(
                        child: Text(
                          'No Posts Yet',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: kFontFamily,
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // NeumorphicText(
                    //   "Tasks",
                    //   textStyle: NeumorphicTextStyle(fontSize: 18.sp),
                    // ),
                    Text(
                      "Tasks",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: kFontFamily,
                      ),
                    ),
                    // NeumorphicButton(
                    //   onPressed: () {
                    //     _taskBottomSheet(onSubmit: (task) {
                    //       context
                    //           .read<CreatePostBloc>()
                    //           .add(AddTaskEvent(task: task));
                    //     });
                    //     _scrollDown();
                    //   },
                    //   style: NeumorphicStyle(
                    //     border: NeumorphicBorder(
                    //       color: kPrimaryWhiteColor,
                    //       width: 0.8,
                    //     ),
                    //     depth: 8,
                    //     lightSource: LightSource.top,
                    //     color: kPrimaryBlackColor,
                    //     shape: NeumorphicShape.flat,
                    //     boxShape: NeumorphicBoxShape.roundRect(
                    //         BorderRadius.circular(5)),
                    //   ),
                    //   padding: EdgeInsets.symmetric(
                    //       vertical: 1.5.h, horizontal: 4.w),
                    //   child: const Text(
                    //     'Add Task',
                    //     style: TextStyle(color: Colors.white),
                    //   ),
                    // ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: kPrimaryBlackColor,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              side: const BorderSide(color: kPrimaryBlackColor),
                              borderRadius: BorderRadius.circular(5))),
                      onPressed: () {
                        _taskBottomSheet(onSubmit: (task) {
                          context
                              .read<CreatePostBloc>()
                              .add(AddTaskEvent(task: task));
                        });
                        _scrollDown();
                      },
                      child: Text(
                        'Add Task',
                        style: TextStyle(
                          color: kPrimaryWhiteColor,
                          fontSize: 10.sp,
                          fontFamily: kFontFamily,
                        ),
                      ),
                    )
                  ],
                ),
                state.todoTask.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10.h),
                          Center(
                            child: Image.asset(
                              kEmptyTaskImagePath,
                              scale: 3,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            state.dateTime == null
                                ? 'Drop your 1st task 🎯'
                                : 'Winning 🎉',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontFamily: kFontFamily,
                            ),
                          ),
                        ],
                      )
                    : Expanded(
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (_, index) {
                            return Dismissible(
                              key: Key(todoTask[index].dateTime.toString()),
                              onDismissed: (_) {
                                context.read<CreatePostBloc>().add(
                                    CompleteTaskEvent(task: todoTask[index]));
                              },
                              child: TaskTile(
                                isComplete: false,
                                view: TaskTileView.createScreenView,
                                isEditing: () {
                                  _taskBottomSheet(
                                    onSubmit: (task) {
                                      context.read<CreatePostBloc>().add(
                                          UpdateTask(task: task, index: index));
                                    },
                                    task: todoTask[index],
                                  );
                                },
                                task: todoTask[index],
                                isDeleted: () =>
                                    context.read<CreatePostBloc>().add(
                                          DeleteTaskEvent(
                                            task: state.todoTask[index],
                                          ),
                                        ),
                              ),
                            );
                          },
                          itemCount: todoTask.length,
                        ),
                      ),
              ],
            ),
          );
  }

  _buildCompleted(CreatePostState state) {
    return state.status == CreatePostStateStatus.loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 16,
                ),
                state.post != null
                    ? _buildRemainingTime(state)
                    : Center(
                        child: Text(
                        'No Task Completed',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: kFontFamily,
                        ),
                      )),
                const SizedBox(height: 15),
                state.completedTask.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 17.3.h),
                          Center(
                            child: Image.asset(
                              kEmptyCompleteImagePath,
                              scale: 3,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Complete your 1st task 🚀',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontFamily: kFontFamily,
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (_, index) => TaskTile(
                          view: TaskTileView.createScreenView,
                          isEditing: () {},
                          task: state.completedTask[index],
                          isComplete: true,
                          isDeleted: () => context.read<CreatePostBloc>().add(
                              DeleteTaskEvent(
                                  task: state.completedTask[index])),
                        ),
                        itemCount: state.completedTask.length,
                      ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          );
  }

  _buildAppBar() {
    return SliverAppBar(
      backgroundColor: kPrimaryWhiteColor,
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
      centerTitle: false,
      pinned: true,
      elevation: 1,
      toolbarHeight: 7.5.h,
      title: Text(
        "Today",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontFamily: kFontFamily,
          fontSize: 22.sp,
        ),
      ),
      bottom: TabBar(indicatorColor: kPrimaryBlackColor, tabs: [
        Tab(
          child: Text(
            "Remaining",
            style: TextStyle(
              color: kPrimaryBlackColor,
              fontSize: 13.sp,
              fontFamily: kFontFamily,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Tab(
          child: Text(
            "Completed",
            style: TextStyle(
              color: kPrimaryBlackColor,
              fontSize: 13.sp,
              fontFamily: kFontFamily,
              height: 1,
              letterSpacing: 0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ]),
      actions: [
        GestureDetector(
          onTap: (() {
            Navigator.pushNamed(context, ProfileScreen.routeName,
                arguments: ProfileScreenArgs(userId: SessionHelper.uid!));
          }),
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: UserProfileImage(
              iconRadius: 45,
              radius: 15,
              profileImageUrl: SessionHelper.profileImageUrl!,
            ),
          ),
        )
      ],
    );
  }

  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _taskBottomSheet({required Function(Task) onSubmit, Task? task}) {
    if (task != null) {
      _taskTextEditingController.text = task.title;
      _descriptionTextEditingController.text = task.description ?? "";
    }
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      transitionAnimationController: bottomModalSheetController,
      context: context,
      builder: (context) => Container(
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 10,
            right: 10),
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Wrap(
          children: [
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Center(
                  child: Text(
                "Add Task",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: kFontFamily,
                ),
              )),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: TextField(
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: kFontFamily,
                ),
                autofocus: true,
                controller: _taskTextEditingController,
                decoration: InputDecoration(
                  hintText: 'e.g. Read Chapter of "Zero to One"',
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.sp,
                      fontFamily: kFontFamily,
                      fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                  focusColor: Colors.grey,
                ),
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  _focusNode.requestFocus();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: TextField(
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 10.5.sp,
                  fontFamily: kFontFamily,
                ),
                controller: _descriptionTextEditingController,
                keyboardType: TextInputType.multiline,
                focusNode: _focusNode,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Description\n\n\n',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10.5.sp,
                    fontFamily: kFontFamily,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) {
                  onSubmit(
                    Task(
                      title: _taskTextEditingController.text,
                      priority: 0,
                      dateTime: DateTime.now(),
                      description: _descriptionTextEditingController.text,
                    ),
                  );
                  _taskTextEditingController.clear();
                  _descriptionTextEditingController.clear();
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  if (_taskTextEditingController.text.isEmpty) {
                    Fluttertoast.showToast(msg: "Title cannont be empty.");
                  } else {
                    onSubmit(
                      Task(
                        title: _taskTextEditingController.text,
                        priority: 0,
                        dateTime: DateTime.now(),
                        description: _descriptionTextEditingController.text,
                      ),
                    );
                    _taskTextEditingController.clear();
                    _descriptionTextEditingController.clear();
                  }
                },
                icon: CircleAvatar(
                  backgroundColor: kPrimaryBlackColor,
                  child: Center(
                    child: Icon(
                      FontAwesomeIcons.arrowUp,
                      color: Colors.white,
                      size: 1.8.h,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildRemainingTime(CreatePostState state) {
    final endTime = state.dateTime?.millisecondsSinceEpoch;
    return Center(
      child: CountdownTimer(
        endTime: endTime,
        onEnd: () {
          _buildDialog();
        },
        widgetBuilder: (_, time) {
          if (time == null) {
            return const Text('Time Up');
          }
          return TimerCountdown(
              format: CountDownTimerFormat.hoursMinutesSeconds,
              timeTextStyle: TextStyle(
                color: kPrimaryBlackColor,
                fontFamily: kFontFamily,
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
              colonsTextStyle: TextStyle(
                color: kPrimaryBlackColor,
                fontFamily: kFontFamily,
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
              descriptionTextStyle: TextStyle(
                color: kPrimaryBlackColor,
                fontFamily: kFontFamily,
                fontSize: 10,
              ),
              spacerWidth: 20,
              endTime: DateTime.now().add(
                Duration(
                  hours: time.hours ?? 0,
                  minutes: time.min ?? 0,
                  seconds: time.sec ?? 0,
                ),
              ));
        },
      ),
    );
  }

  _buildDialog() {
    context.read<CreatePostBloc>().add(const ClearPost());
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Your Time is Up',
            style: TextStyle(
              color: Colors.black,
              fontFamily: kFontFamily,
            ),
          ),
        );
      },
    );
  }
}
