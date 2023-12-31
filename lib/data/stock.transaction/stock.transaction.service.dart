import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/data/auth/firebase.auth.repository.dart';
import 'package:inventory_frontend/data/onboarding/team.id.shared.ref.repository.dart';
import 'package:inventory_frontend/data/stock.transaction/stock.transaction.repository.dart';
import 'package:inventory_frontend/domain/stock.transaction/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stock.transaction.service.g.dart';

class StockTransactionService {
  final AuthRepository _authRepo;
  final TeamIdSharedRefereceRepository _teamIdSharedRefRepository;
  final StockTransactionRepository _stockTransactionRepo;
  StockTransactionService(
      {required AuthRepository authRepo,
      required TeamIdSharedRefereceRepository teamIdSharedRefRepository,
      required StockTransactionRepository saleOrderRepo})
      : _stockTransactionRepo = saleOrderRepo,
        _teamIdSharedRefRepository = teamIdSharedRefRepository,
        _authRepo = authRepo;

  Future<Either<String, Unit>> create(StockTransaction stockTransaction) async {
    final teamIdOrNone = _teamIdSharedRefRepository.getTemId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final createdOrError =
          await _stockTransactionRepo.create(stockTransaction: stockTransaction, teamId: teamId, token: token);
      return createdOrError.fold((l) => Left(l.message), (r) => const Right(unit));
    });
  }

    Future<Either<String, StockTransaction>> get({required String stockTransactionId}) async {
    final teamIdOrNone = _teamIdSharedRefRepository.getTemId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final createdOrError = await _stockTransactionRepo.get(stockTransactionId: stockTransactionId, teamId: teamId, token: token);
      return createdOrError.fold((l) => Left(l.message), (r) =>  Right(r));
    });
  }

  Future<Either<String, List<StockTransaction>>> list() async {
    final teamIdOrNone = _teamIdSharedRefRepository.getTemId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final items = await _stockTransactionRepo.list(teamId: teamId, token: token);
      return items.fold((l) => Left(l.message), (r) => Right(r.data));
    });
  }

  //   Future<Either<String, Unit>> converteToDelivered({required String saleOrderId}) async {
  //   final teamIdOrNone = _teamIdSharedRefRepository.getTemId;
  //   return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
  //     final token = await _authRepo.shouldGetToken();
  //     final items = await _saleOrderRepo.deliveredItems(saleOrderId: saleOrderId, date: DateTime.now(), teamId: teamId, token: token);
  //     return items.fold((l) => Left(l.message), (r) => Right(r));
  //   });
  // }
}

@Riverpod(keepAlive: true)
StockTransactionService stockTransactionService(StockTransactionServiceRef ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final teamIdSharedRefRepo = ref.watch(teamIdSharedReferenceRepositoryProvider);
  final saleOrderRepo = ref.watch(stockTransactionRepositoryProvider);
  return StockTransactionService(
      authRepo: authRepo, teamIdSharedRefRepository: teamIdSharedRefRepo, saleOrderRepo: saleOrderRepo);
}
