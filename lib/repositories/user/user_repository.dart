import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tevo/config/paths.dart';
import 'package:tevo/enums/enums.dart';
import 'package:tevo/models/models.dart';
import 'package:tevo/repositories/repositories.dart';
import 'package:tevo/utils/session_helper.dart';
import 'package:tevo/widgets/widgets.dart';

class UserRepository extends BaseUserRepository {
  final FirebaseFirestore _firebaseFirestore;

  UserRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<User> getUserWithId({required String userId}) async {
    final doc =
        await _firebaseFirestore.collection(Paths.users).doc(userId).get();
    return doc.exists ? User.fromDocument(doc) : User.empty;
  }

  @override
  Future<void> updateUser({required User user}) async {
    await _firebaseFirestore
        .collection(Paths.users)
        .doc(user.id)
        .update(user.toDocument());
  }

  @override
  Future<void> setUser({required User user}) async {
    await _firebaseFirestore
        .collection(Paths.users)
        .doc(user.id)
        .set(user.toDocument());
  }

  @override
  Future<List<User>> searchUsers({required String query}) async {
    List<User> list;

    final userNameSnap = await _firebaseFirestore
        .collection(Paths.users)
        .where('name', isGreaterThanOrEqualTo: query)
        .get();
    list = userNameSnap.docs.map((doc) => User.fromDocument(doc)).toList();

    final nameSnap = await _firebaseFirestore
        .collection(Paths.users)
        .where('username', isGreaterThanOrEqualTo: query)
        .get();

    list.addAll(nameSnap.docs.map((doc) => User.fromDocument(doc)).toList());
    return list;
  }

  @override
  Future<List<User>> getUsersByFollowers() async {
    final userSnap = await _firebaseFirestore
        .collection(Paths.users)
        .orderBy(Paths.followers, descending: true)
        .where("isPrivate", isEqualTo: false)
        .get();
    // log(SessionHelper.uid!);
    log(SessionHelper.uid ?? " null hai value");

    final followersList =
        userSnap.docs.map((doc) => User.fromDocument(doc)).toList();
    List<User> topFollowersList = [];
    for (var element in followersList) {
      if (element.id != SessionHelper.uid) {
        topFollowersList.add(element);
      }
    }
    return topFollowersList;
  }

  @override
  Future<bool> searchUserbyPhone(
      {required String query, required bool newAccount}) async {
    try {
      return await _firebaseFirestore
          .collection(Paths.users)
          .where("phoneNumber", isEqualTo: query)
          .snapshots()
          .isEmpty;
    } on FirebaseException catch (err) {
      if (err.code == 'permission-denied') {
        flutterToast(
            msg: newAccount ? 'New Account' : 'Account does not exists',
            position: ToastGravity.CENTER);
      } else {
        flutterToast(msg: 'An Error occured', position: ToastGravity.CENTER);
      }
    } catch (err) {
      flutterToast(msg: 'An Error occured', position: ToastGravity.CENTER);
    }
    return true;
  }

  @override
  Future<bool> searchUserbyUsername({required String query}) async {
    try {
      final QuerySnapshot users = await _firebaseFirestore
          .collection(Paths.users)
          .where(Paths.usernameLower, isEqualTo: query.toLowerCase())
          .get();
      return users.size == 0;
    } on FirebaseException catch (err) {
      log(err.message!);
    } catch (e) {
      log(e.toString());
    }
    return false;
  }

  void requestUser({
    required String userId,
    required String followUserId,
  }) {
    final notification = Notif(
      type: NotifType.request,
      fromUser: User.empty.copyWith(id: userId),
      date: DateTime.now(),
    );

    _firebaseFirestore
        .collection(Paths.requests)
        .doc(followUserId)
        .collection(Paths.userRequests)
        .add(notification.toDocument());
  }

  void deleteRequest({
    required String requestId,
    required String followUserId,
  }) {
    _firebaseFirestore
        .collection(Paths.requests)
        .doc(followUserId)
        .collection(Paths.userRequests)
        .doc(requestId)
        .delete();
  }

  @override
  void followUser({
    required String userId,
    required String followUserId,
    required String? requestId,
  }) {
    log("han yeh bhi");

    // Add followUser to user's userFollowing.
    _firebaseFirestore
        .collection(Paths.following)
        .doc(userId)
        .collection(Paths.userFollowing)
        .doc(followUserId)
        .set({});

    // Add user to followUser's userFollowers.
    _firebaseFirestore
        .collection(Paths.followers)
        .doc(followUserId)
        .collection(Paths.userFollowers)
        .doc(userId)
        .set({});

    final notification = Notif(
      type: NotifType.follow,
      fromUser: User.empty.copyWith(id: userId),
      date: DateTime.now(),
    );

    if (requestId != null) {
      final notificationRequestAccepted = Notif(
        type: NotifType.requestAccepted,
        fromUser: User.empty.copyWith(id: followUserId),
        date: DateTime.now(),
      );

      _firebaseFirestore
          .collection(Paths.notifications)
          .doc(userId)
          .collection(Paths.userNotifications)
          .add(notificationRequestAccepted.toDocument());

      _firebaseFirestore
          .collection(Paths.notifications)
          .doc(followUserId)
          .collection(Paths.userNotifications)
          .add(notification.toDocument());

      deleteRequest(requestId: requestId, followUserId: followUserId);
    }
  }

  @override
  void unfollowUser({
    required String userId,
    required String unfollowUserId,
  }) {
    // Remove unfollowUser from user's userFollowing.
    _firebaseFirestore
        .collection(Paths.following)
        .doc(userId)
        .collection(Paths.userFollowing)
        .doc(unfollowUserId)
        .delete();
    // Remove user from unfollowUser's userFollowers.
    _firebaseFirestore
        .collection(Paths.followers)
        .doc(unfollowUserId)
        .collection(Paths.userFollowers)
        .doc(userId)
        .delete();
  }

  @override
  Future<bool> isFollowing({
    required String userId,
    required String otherUserId,
  }) async {
    // is otherUser in user's userFollowing
    final otherUserDoc = await _firebaseFirestore
        .collection(Paths.following)
        .doc(userId)
        .collection(Paths.userFollowing)
        .doc(otherUserId)
        .get();
    return otherUserDoc.exists;
  }

  @override
  Future<bool> isRequesting({
    required String userId,
    required String otherUserId,
  }) async {
    // is otherUser in user's requesting
    final authref = _firebaseFirestore.collection(Paths.users).doc(userId);
    final otherUserDoc = await _firebaseFirestore
        .collection(Paths.requests)
        .doc(otherUserId)
        .collection(Paths.userRequests)
        .where("fromUser", isEqualTo: authref)
        .get();
    return otherUserDoc.docs.isNotEmpty;
  }

  void deleteRequested({
    //Person sending request is deleting the request sent
    required String userId,
    required String otherUserId,
  }) async {
    // is otherUser in user's requesting
    final authref = _firebaseFirestore.collection(Paths.users).doc(userId);
    _firebaseFirestore
        .collection(Paths.requests)
        .doc(otherUserId)
        .collection(Paths.userRequests)
        .where("fromUser", isEqualTo: authref)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  Future<bool> checkUsernameAvailability(String username) async {
    try {
      var result = await _firebaseFirestore
          .collection(Paths.username)
          .doc(username)
          .get();
      return result.exists;
    } catch (e) {
      log(e.toString());
    }
    return true;
  }
}
