import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/data/db/app_db.dart';

final appDbProvider = Provider((ref) => AppDb());
