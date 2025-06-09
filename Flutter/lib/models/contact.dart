import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Contact {
  int? id;
  String name;
  String? phone;
  String? home;
  String? company;
  String? email;
  String? group;
  String? memo;
  String? address;
  DateTime? birthday;
  bool favorite;
  String? image;
  DateTime? created;
  DateTime? updated;

  Contact({
    required this.id,
    required this.name,
    this.phone,
    this.home,
    this.company,
    this.email,
    this.group,
    this.memo,
    this.address,
    this.birthday,
    this.favorite = false,
    this.image,
    this.created,
    this.updated,
  });

  Contact copyWith({
    int? id,
    String? name,
    String? phone,
    String? home,
    String? company,
    String? email,
    String? group,
    String? memo,
    String? address,
    DateTime? birthday,
    bool? favorite,
    String? image,
    DateTime? created,
    DateTime? updated,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      home: home ?? this.home,
      company: company ?? this.company,
      email: email ?? this.email,
      group: group ?? this.group,
      memo: memo ?? this.memo,
      address: address ?? this.address,
      birthday: birthday ?? this.birthday,
      favorite: favorite ?? this.favorite,
      image: image ?? this.image,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) {
        return null;
      }
      try {
        return DateTime.tryParse(dateString) ??
            DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateString);
      } catch (e) {
        debugPrint("날짜 파싱 오류: $dateString, 오류: $e");
        return null;
      }
    }

    return Contact(
      id: json['id'] as int?,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      home: json['home'] as String?,
      company: json['company'] as String?,
      email: json['email'] as String?,
      group: json['group'] as String?,
      memo: json['memo'] as String?,
      address: json['address'] as String?,
      birthday: parseDate(json['birthday'] as String?),
      favorite:
          json['favorite'] is bool
              ? json['favorite'] as bool
              : (json['favorite'] == 1),
      image: json['image'] as String?,
      created: parseDate(json['created'] as String?),
      updated: parseDate(json['updated'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'home': home,
      'company': company,
      'email': email,
      'group': group,
      'memo': memo,
      'address': address,
      'birthday': birthday?.toIso8601String(),
      'favorite': favorite,
      'image': image,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }
}
