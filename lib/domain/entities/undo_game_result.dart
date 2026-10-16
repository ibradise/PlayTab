import 'package:equatable/equatable.dart';

enum UndoStatus { done, notFound, conflict }

class UndoGameResult extends Equatable {
  const UndoGameResult(this.status, {this.restored = false, this.message});

  final UndoStatus status;
  final bool restored;
  final String? message;

  String get displayMessage =>
      message ??
      switch (status) {
        UndoStatus.done => 'Game undone',
        UndoStatus.notFound => 'Game not found',
        UndoStatus.conflict => 'Cannot undo this game',
      };

  @override
  List<Object?> get props => [status, restored, message];
}
