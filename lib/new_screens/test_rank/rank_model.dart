// import 'package:cloud_firestore/cloud_firestore.dart';

// class RankModel {
//   final String id;
//   final String name;
//   final int highScore;
//   int rank;

//   RankModel({
//     required this.id,
//     required this.name,
//     required this.highScore,
//     this.rank = 0,
//   });

//   factory RankModel.fromMap(Map<String, dynamic> map, String documentId) {
//     final dynamic rawLastUpdated = map['lastUpdated'];
//     if (rawLastUpdated is Timestamp) {}

//     return RankModel(
//       id: documentId,
//       name: map['name'] as String? ?? 'N/A',
//       highScore: map['highScore'] as int? ?? 0,
//       rank: 0,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'highScore': highScore,
//     };
//   }

//   RankModel copyWith({
//     String? id,
//     String? name,
//     int? highScore,
//     int? rank,
//   }) {
//     return RankModel(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       highScore: highScore ?? this.highScore,
//       rank: rank ?? this.rank,
//     );
//   }
// }
