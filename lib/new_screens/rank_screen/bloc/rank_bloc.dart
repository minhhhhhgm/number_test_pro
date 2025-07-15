import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'rank_event.dart';
part 'rank_state.dart';

class RankBloc extends Bloc<RankEvent, RankState> {
  late StreamSubscription<QuerySnapshot<Object?>> _subscription;
  RankBloc(super.initialState) {
    on<InitEvent>((event, emit) async {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      try {
        await users.add({
          'name': 'John Doe',
          'email': 'john@example.com',
          'age': 25,
        });
      } catch (e) {
        print('error : $e');
      }

      _subscription = users.snapshots().listen(
        (event) {
          for (var doc in event.docs) {
            print(doc.data()); // In ra dữ liệu từng document
          }
        },
      );
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
