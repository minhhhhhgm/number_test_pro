import 'dart:math';

enum ChallengeType {
  highTarget,      // Target rất lớn
  shortTime,       // Thời gian ngắn
  primeTarget,     // Target là số nguyên tố
  evenOnly,        // Chỉ được chọn số chẵn
  oddOnly,         // Chỉ được chọn số lẻ
  sequence,        // Phải chọn theo thứ tự tăng dần
  noHint,          // Không được dùng gợi ý
  powerUpDisabled, // Không được dùng power-up
}

class DailyChallenge {
  final String id; // Ngày (YYYY-MM-DD)
  final int target;
  final int timeLimit; // Thời gian giới hạn (giây)
  final String description; // Mô tả thử thách
  final List<String> specialRules; // Luật đặc biệt
  final int reward; // Phần thưởng khi hoàn thành
  final ChallengeType type;

  DailyChallenge({
    required this.id,
    required this.target,
    required this.timeLimit,
    required this.description,
    required this.specialRules,
    required this.reward,
    required this.type,
  });

  static DailyChallenge generateDailyChallenge(String date) {
    // Random loại thử thách
    List<ChallengeType> types = ChallengeType.values;
    ChallengeType randomType = types[Random().nextInt(types.length)];
    
    switch (randomType) {
      case ChallengeType.highTarget:
        return DailyChallenge(
          id: date,
          target: Random().nextInt(500) + 500, // 500-1000
          timeLimit: 60,
          description: 'Target cao - Thử thách sức mạnh!',
          specialRules: ['Target rất lớn, cần tư duy cẩn thận'],
          reward: 100,
          type: randomType,
        );
        
      case ChallengeType.shortTime:
        return DailyChallenge(
          id: date,
          target: Random().nextInt(200) + 100, // 100-300
          timeLimit: 30, // Chỉ 30 giây
          description: 'Thời gian ngắn - Tốc độ là chìa khóa!',
          specialRules: ['Chỉ có 30 giây để hoàn thành'],
          reward: 150,
          type: randomType,
        );
        
      case ChallengeType.primeTarget:
        return DailyChallenge(
          id: date,
          target: _getRandomPrimeNumber(),
          timeLimit: 45,
          description: 'Target nguyên tố - Toán học thuần túy!',
          specialRules: ['Target là số nguyên tố'],
          reward: 200,
          type: randomType,
        );
        
      case ChallengeType.evenOnly:
        return DailyChallenge(
          id: date,
          target: Random().nextInt(300) + 100, // 100-400
          timeLimit: 50,
          description: 'Chỉ số chẵn - Lọc kỹ lưỡng!',
          specialRules: ['Chỉ được chọn số chẵn'],
          reward: 120,
          type: randomType,
        );
        
      case ChallengeType.oddOnly:
        return DailyChallenge(
          id: date,
          target: Random().nextInt(300) + 100, // 100-400
          timeLimit: 50,
          description: 'Chỉ số lẻ - Tư duy khác biệt!',
          specialRules: ['Chỉ được chọn số lẻ'],
          reward: 120,
          type: randomType,
        );
        
      case ChallengeType.noHint:
        return DailyChallenge(
          id: date,
          target: Random().nextInt(400) + 200, // 200-600
          timeLimit: 60,
          description: 'Không gợi ý - Tự lực cánh sinh!',
          specialRules: ['Không được dùng gợi ý'],
          reward: 180,
          type: randomType,
        );
        
      case ChallengeType.powerUpDisabled:
        return DailyChallenge(
          id: date,
          target: Random().nextInt(400) + 200, // 200-600
          timeLimit: 60,
          description: 'Không power-up - Thuần túy kỹ năng!',
          specialRules: ['Không được dùng power-up'],
          reward: 180,
          type: randomType,
        );
        
      case ChallengeType.sequence:
        return DailyChallenge(
          id: date,
          target: Random().nextInt(300) + 100, // 100-400
          timeLimit: 55,
          description: 'Thứ tự tăng dần - Logic nghiêm ngặt!',
          specialRules: ['Phải chọn số theo thứ tự tăng dần'],
          reward: 160,
          type: randomType,
        );
    }
  }

  static int _getRandomPrimeNumber() {
    List<int> primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97];
    return primes[Random().nextInt(primes.length)];
  }
} 