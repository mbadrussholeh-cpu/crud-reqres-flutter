class UserModel {
final int? id;
final String email;
final String firstName;
final String lastName;
final String avatar;

const UserModel({
this.id,
required this.email,
required this.firstName,
required this.lastName,
this.avatar = '',
});

String get fullName => '$firstName $lastName'.trim();

factory UserModel.fromJson(Map<String, dynamic> json) {
return UserModel(
id: int.tryParse('${json['id']}'),
email: json['email'] ?? '',
firstName: json['first_name'] ?? '',
lastName: json['last_name'] ?? '',
avatar: json['avatar'] ?? '',
);
}

Map<String, dynamic> toJson() => {
'email': email,
'first_name': firstName,
'last_name': lastName,
};

UserModel copyWith({
int? id,
String? email,
String? firstName,
String? lastName,
String? avatar,
}) {
return UserModel(
id: id ?? this.id,
email: email ?? this.email,
firstName: firstName ?? this.firstName,
lastName: lastName ?? this.lastName,
avatar: avatar ?? this.avatar,
);
}
}
