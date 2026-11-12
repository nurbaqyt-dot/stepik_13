import 'package:stepik_13/core/error/exception.dart';
import 'package:stepik_13/core/platform/network_info.dart';
import 'package:stepik_13/feature/data/datasources/person_local_data_source.dart';
import 'package:stepik_13/feature/data/datasources/person_remote_data_source.dart';
import 'package:stepik_13/feature/data/models/person_model.dart';
import 'package:stepik_13/feature/domain/entities/person_entity.dart';
import 'package:stepik_13/core/error/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:stepik_13/feature/domain/repositories/person_repository.dart';

class PersonRepositoryImpl implements PersonRepository {
  final PersonRemoteDataSource remoteDataSource;
  final PersonLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PersonRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<PersonEntity>>> getAllPersons(int page) async {
    return _getPersons(() {
      return remoteDataSource.getAllPersons(page);
    }, cacheResults: true);
  }

  @override
  Future<Either<Failure, List<PersonEntity>>> searchPerson(String query) async {
    return _getPersons(() {
      return remoteDataSource.searchPerson(query);
    });
  }

  Future<Either<Failure, List<PersonModel>>> _getPersons(
      Future<List<PersonModel>> Function() getPersons,
      {bool cacheResults = false}) async {
    if (await networkInfo.isConnected) {
      try {
        final remotePerson = await getPersons();
        if (cacheResults) {
          await localDataSource.personsToCache(remotePerson);
        }
        return Right(remotePerson);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localPerson = await localDataSource.getLastPersonsFromCache();
        return Right(localPerson);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}