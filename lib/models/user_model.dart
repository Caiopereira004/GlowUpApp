class UserModel {
  String name;
  String email;
  String password;
  String? skinKey;
  String? skinLabel;
  String? skinGoal;
  String? avatarPath;
  String? avatarPresetId;

  UserModel({
    required this.name,
    required this.email,
    required this.password,
    this.skinKey,
    this.skinLabel,
    this.skinGoal,
    this.avatarPath,
    this.avatarPresetId,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? password,
    String? skinKey,
    String? skinLabel,
    String? skinGoal,
    String? avatarPath,
    String? avatarPresetId,
    bool clearSkin = false,
    bool clearAvatar = false,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      skinKey: clearSkin ? null : (skinKey ?? this.skinKey),
      skinLabel: clearSkin ? null : (skinLabel ?? this.skinLabel),
      skinGoal: clearSkin ? null : (skinGoal ?? this.skinGoal),
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
      avatarPresetId: clearAvatar ? null : (avatarPresetId ?? this.avatarPresetId),
    );
  }
}
