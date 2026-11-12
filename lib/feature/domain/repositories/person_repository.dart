import 'package:dartz/dartz.dart';
import 'package:stepik_13/core/error/failure.dart';
import 'package:stepik_13/feature/domain/entities/person_entity.dart';

abstract class PersonRepository {
  Future<Either<Failure, List<PersonEntity>>> getAllPersons(int page);
  Future<Either<Failure, List<PersonEntity>>> searchPerson(String query);
}