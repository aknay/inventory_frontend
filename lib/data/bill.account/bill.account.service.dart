import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/data/auth/firebase.auth.repository.dart';
import 'package:inventory_frontend/data/bill.account/bill.account.repository.dart';
import 'package:inventory_frontend/data/onboarding/team.id.shared.ref.repository.dart';
import 'package:inventory_frontend/domain/bill.account/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bill.account.service.g.dart';

class BillAccountService {
  final AuthRepository _authRepo;
  final TeamIdSharedRefereceRepository _teamIdSharedRefRepository;
  final BillAccountRepository _itemRepo;
  BillAccountService(
      {required AuthRepository authRepo,
      required TeamIdSharedRefereceRepository teamIdSharedRefRepository,
      required BillAccountRepository billAccountRepo})
      : _itemRepo = billAccountRepo,
        _teamIdSharedRefRepository = teamIdSharedRefRepository,
        _authRepo = authRepo;

  Future<Either<String, List<BillAccount>>> list() async {
    final teamIdOrNone = _teamIdSharedRefRepository.getTemId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final items = await _itemRepo.list(teamId: teamId, token: token);
      return items.fold((l) => Left(l.message), (r) => Right(r.data));
    });
  }
}

@Riverpod(keepAlive: true)
BillAccountService billAccountService(BillAccountServiceRef ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final teamIdSharedRefRepo = ref.watch(teamIdSharedReferenceRepositoryProvider);
  final billAccountRepo = ref.watch(billAccountRepositoryProvider);
  return BillAccountService(
      authRepo: authRepo, teamIdSharedRefRepository: teamIdSharedRefRepo, billAccountRepo: billAccountRepo);
}