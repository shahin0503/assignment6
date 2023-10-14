import 'package:equatable/equatable.dart';

class Chatuser extends Equatable {
  final String id;
  final String photoUrl;
  final String displayName;
  final String phoneNumber;
  final String aboutMe;

  const Chatuser({
    required this.id,
    required this.photoUrl,
    required this.displayName,
    required this.phoneNumber,
    required this.aboutMe,
  });

  @override
  List<Object?> get props => throw UnimplementedError();
}
