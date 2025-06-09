import '../models/contact.dart';

//데이터 모델 클래스

class Contact {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? group; // 'group'은 예약어라 변수명 바꾸는 게 좋아요!
  final String? memo;
  final String? address;
  final DateTime? birthday;
  final bool favorite;
  final String? image;
  final DateTime created;
  final DateTime updated;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.group,
    this.memo,
    this.address,
    this.birthday,
    this.favorite = false,
    this.image,
    required this.created,
    required this.updated,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      group: json['group'],
      memo: json['memo'],
      address: json['address'],
      birthday:
          json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      favorite: json['favorite'] ?? false,
      image: json['image'],
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'group': group,
      'memo': memo,
      'address': address,
      'birthday': birthday?.toIso8601String(),
      'favorite': favorite,
      'image': image,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }
}
