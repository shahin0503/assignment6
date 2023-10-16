import 'package:equatable/equatable.dart';

class ChatUser extends Equatable {
  final String id;
  final String email;
  final String photoUrl;
  final String displayName;
  final String phoneNumber;
  final String aboutMe;

  const ChatUser({
    required this.id,
    required this.email,
    required this.photoUrl,
    required this.displayName,
    required this.phoneNumber,
    required this.aboutMe,
  });

  @override
  List<Object?> get props => throw UnimplementedError();
}
