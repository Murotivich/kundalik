// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GradeModelAdapter extends TypeAdapter<GradeModel> {
  @override
  final int typeId = 1;

  @override
  GradeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GradeModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      subject: fields[2] as String,
      grade: fields[3] as int,
      gradeType: fields[4] as String,
      date: fields[5] as DateTime,
      comment: fields[6] as String?,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GradeModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.subject)
      ..writeByte(3)
      ..write(obj.grade)
      ..writeByte(4)
      ..write(obj.gradeType)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.comment)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
