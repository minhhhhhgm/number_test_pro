// Ví dụ trong lib/models/leader_board_model.dart
class LeaderBoardModel {
  final String id; // THÊM MỚI: Thêm id
  final String name;
  final int highScore;
  final int correctAnswers;
  final int totalQuestions;
  final int lastUpdated;
  final int? periodStartTimestamp; // Chỉ có cho daily/weekly/monthly
  int? rank; // THÊM MỚI: rank có thể thay đổi

  LeaderBoardModel({
    required this.id, // Yêu cầu id trong constructor
    required this.name,
    required this.highScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.lastUpdated,
    this.periodStartTimestamp,
    this.rank, // rank ban đầu có thể null
  });

  // THAY ĐỔI: Hàm fromMap nhận thêm id
  factory LeaderBoardModel.fromMap(Map<String, dynamic> data, String id) {
    return LeaderBoardModel(
      id: id,
      name: data['name'] as String,
      highScore: data['highScore'] as int,
      correctAnswers: data['correctAnswers'] as int,
      totalQuestions: data['totalQuestions'] as int,
      lastUpdated: data['lastUpdated'] as int,
      periodStartTimestamp: data['periodStartTimestamp'] as int?,
      // rank không được lấy từ Firestore mà được tính toán local
    );
  }

  // THÊM MỚI: Hàm toMap để đẩy lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'highScore': highScore,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'lastUpdated': lastUpdated,
      if (periodStartTimestamp != null) 'periodStartTimestamp': periodStartTimestamp,
      // Không bao gồm id và rank vì id là document ID và rank là local property
    };
  }

  // THÊM MỚI: Hàm copyWith để dễ dàng tạo bản sao với các thay đổi
  LeaderBoardModel copyWith({
    String? id,
    String? name,
    int? highScore,
    int? correctAnswers,
    int? totalQuestions,
    int? lastUpdated,
    int? periodStartTimestamp,
    int? rank,
  }) {
    return LeaderBoardModel(
      id: id ?? this.id,
      name: name ?? this.name,
      highScore: highScore ?? this.highScore,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      periodStartTimestamp: periodStartTimestamp ?? this.periodStartTimestamp,
      rank: rank ?? this.rank,
    );
  }
}