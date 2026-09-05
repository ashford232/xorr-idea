import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/auth/configs/client_config.dart';
import 'package:xorr/features/auth/configs/token_config.dart';
import 'package:xorr/features/auth/repositories/auth_repository.dart';
import 'package:xorr/features/auth/services/upload_service.dart';

final clientProvider = Provider(
  (ref) => Client(tokenConfig: ref.watch(tokenConfigProvider)),
);

final tokenConfigProvider = Provider((ref) => TokenConfig());
final authRepositoryProvider = Provider(
  (ref) => AuthRepository(client: ref.watch(clientProvider)),
);

final getUserProvider = FutureProvider(
  (ref) => ref.watch(authRepositoryProvider).me(),
);

final uploadServiceProvider = Provider((ref)=> UploadService(client: ref.watch(clientProvider)));