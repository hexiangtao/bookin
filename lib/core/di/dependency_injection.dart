import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../network/dio_factory.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => DioFactory.getDio());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  
  // External
  sl.registerLazySingleton(() => Connectivity());
  
  // Features - Add your feature dependencies here
  // Example:
  // sl.registerLazySingleton(() => AuthRepository(sl(), sl()));
  // sl.registerLazySingleton(() => LoginUseCase(sl()));
}