import 'package:equatable/equatable.dart';

class Shelter extends Equatable {
  final String id;
  final String profileId;
  final String shelterName;
  final String? description;
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? website;
  final int totalPets;
  final int totalAdoptions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Shelter({
    required this.id,
    required this.profileId,
    required this.shelterName,
    this.description,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.website,
    required this.totalPets,
    required this.totalAdoptions,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        profileId,
        shelterName,
        description,
        address,
        city,
        country,
        latitude,
        longitude,
        phone,
        website,
        totalPets,
        totalAdoptions,
        createdAt,
        updatedAt,
      ];
}