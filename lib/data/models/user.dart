/// User model representing application user data
class User {
  const User({
    required this.name,
    required this.email,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.goal,
    required this.avatar,
    required this.loginCount,
    required this.lastLogin,
    required this.completedGoals,
    required this.budget,
    required this.notificationCount,
  });

  final String name;
  final String email;
  final double height;
  final double weight;
  final int age;
  final String gender;
  final String activityLevel;
  final String goal;
  final String avatar;
  final int loginCount;
  final String lastLogin;
  final int completedGoals;
  final double budget;
  final int notificationCount;

  /// Creates a User from JSON data
  factory User.fromJson(Map<String, dynamic> json) => User(
        name: json['name'] as String,
        email: json['email'] as String,
        height: (json['height'] as num).toDouble(),
        weight: (json['weight'] as num).toDouble(),
        age: json['age'] as int,
        gender: json['gender'] as String,
        activityLevel: json['activityLevel'] as String,
        goal: json['goal'] as String,
        avatar: json['avatar'] as String,
        loginCount: json['loginCount'] as int,
        lastLogin: json['lastLogin'] as String,
        completedGoals: json['completedGoals'] as int,
        budget: (json['budget'] as num).toDouble(),
        notificationCount: json['notificationCount'] as int,
      );

  /// Converts User to JSON data
  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'height': height,
        'weight': weight,
        'age': age,
        'gender': gender,
        'activityLevel': activityLevel,
        'goal': goal,
        'avatar': avatar,
        'loginCount': loginCount,
        'lastLogin': lastLogin,
        'completedGoals': completedGoals,
        'budget': budget,
        'notificationCount': notificationCount,
      };

  /// Creates a copy of this User with updated fields
  User copyWith({
    String? name,
    String? email,
    double? height,
    double? weight,
    int? age,
    String? gender,
    String? activityLevel,
    String? goal,
    String? avatar,
    int? loginCount,
    String? lastLogin,
    int? completedGoals,
    double? budget,
    int? notificationCount,
  }) =>
      User(
        name: name ?? this.name,
        email: email ?? this.email,
        height: height ?? this.height,
        weight: weight ?? this.weight,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        activityLevel: activityLevel ?? this.activityLevel,
        goal: goal ?? this.goal,
        avatar: avatar ?? this.avatar,
        loginCount: loginCount ?? this.loginCount,
        lastLogin: lastLogin ?? this.lastLogin,
        completedGoals: completedGoals ?? this.completedGoals,
        budget: budget ?? this.budget,
        notificationCount: notificationCount ?? this.notificationCount,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || 
      other is User && 
      other.email == email &&
      other.budget == budget &&
      other.name == name &&
      other.height == height &&
      other.weight == weight &&
      other.age == age &&
      other.gender == gender &&
      other.activityLevel == activityLevel &&
      other.goal == goal;

  @override
  int get hashCode => Object.hash(email, budget, name, height, weight, age, gender, activityLevel, goal);

  @override
  String toString() => 'User(name: $name, email: $email, budget: $budget)';
}
