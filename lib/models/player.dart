class Player {
  final String uid;
  final String name;
  final String photoUrl;
  bool hasVoted;
  String? voteTo;
  int votedCount;

  Player({
    required this.uid,
    required this.name,
    required this.photoUrl,
    this.hasVoted = false,
    this.voteTo,
    this.votedCount = 0,
  });

  Player copyWith({
    String? uid,
    String? name,
    String? photoUrl,
    bool? hasVoted,
    String? voteTo,
    int? votedCount,
  }) {
    return Player(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      hasVoted: hasVoted ?? this.hasVoted,
      voteTo: voteTo ?? this.voteTo,
      votedCount: votedCount ?? this.votedCount,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'photoUrl': photoUrl,
        'hasVoted': hasVoted,
        'voteTo': voteTo,
        'votedCount': votedCount,
      };

  static Player fromMap(Map<String, dynamic> map) => Player(
        uid: map['uid'],
        name: map['name'],
        photoUrl: map['photoUrl'],
        hasVoted: map['hasVoted'],
        voteTo: map['voteTo'],
        votedCount: map['votedCount'] ?? 0,
      );
}
