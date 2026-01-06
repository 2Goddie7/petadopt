import 'package:equatable/equatable.dart';

class Favorite extends Equatable {
  final String userId;
  final String petId;
  final DateTime createdAt;

  const Favorite({
    required this.userId,
    required this.petId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [userId, petId, createdAt];
}
