import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:numbers/store/SettingsStore.dart';

class LeaderboardService {
  final String collection = 'leaderboard';
  final String orderByKey = 'score';
  final Map<String, int> leaderBoardTypes = {
    'overall': 0,
    'weekly': 7,
    'daily': 1
  };

  setData(Map gameState) async {
    final newData = await _formatSetData(gameState);
    FirebaseFirestore.instance.collection(collection).doc().set(newData);
  }

  Future<Map<String, dynamic>> _formatSetData(Map gameState) async {
    String? name = await SettingsStore().getKey('name');

    // if (name == null) {
    //   name = Common.getRandomName();
    // }

    return {
      'name': name,
      'time': DateTime.now().millisecondsSinceEpoch.toString(),
      'total': gameState['total'],
      'success': gameState['success'],
      'fail': gameState['fail'],
      'score': gameState['score'],
      'selectedBlocks': gameState['selectedBlocks'],
    };
  }

  getData({int limit = 6, leaderboardType = 'overall'}) async {
    try {
      int daysToSubtract = leaderBoardTypes[leaderboardType] ?? 0;
      var resultData;

      if (daysToSubtract != 0) {
        String lastWeekTimeStamp = DateTime.now()
            .subtract(Duration(days: daysToSubtract))
            .millisecondsSinceEpoch
            .toString();

        resultData = await _getDataByTimeCondition(lastWeekTimeStamp);
      } else {
        resultData = await _getOverallData(limit);
      }

      return this._formatGetData(resultData, limit);
    } catch (error) {
      //print(error);
    }
  }

  _getDataByTimeCondition(String daysToSubtract) async {
    return await FirebaseFirestore.instance
        .collection(collection)
        .where("time", isGreaterThanOrEqualTo: daysToSubtract)
        .get();
  }

  _getOverallData(limit) async {
    return await FirebaseFirestore.instance
        .collection(collection)
        .orderBy(orderByKey, descending: true)
        .limit(limit)
        .get();
  }

  _formatGetData(collection, limit) {
    List list = _formList(collection);
    _sortList(list);
    list = _addRank(list);
    return _splitList(list, 0, limit);
  }

  List _formList(collection) {
    List list = [];
    for (var document in collection.documents) {
      list.add(document.data);
    }

    return list;
  }

  _sortList(List documents) {
    documents.sort((m1, m2) {
      return m2["score"].compareTo(m1["score"]);
    });
  }

  List _addRank(List documents) {
    int counter = 0;
    for (var document in documents) {
      document['rank'] = ++counter;
    }

    return documents;
  }

  List _splitList(List list, int start, int end) {
    if (list.length < end) {
      end = list.length;
    }
    return list.sublist(start, end);
  }
}
