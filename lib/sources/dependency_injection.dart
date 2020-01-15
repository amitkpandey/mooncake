import 'package:dependencies/dependencies.dart';
import 'package:mooncake/entities/entities.dart';
import 'package:mooncake/repositories/repositories.dart';
import 'package:mooncake/sources/sources.dart';
import 'package:http/http.dart' as http;

class SourcesModule implements Module {
  // TODO: Take back these
//  static const _lcdUrl = "http://lcd.morpheus.desmos.network:1317";
//  static const _rpcUrl = "http://rpc.morpheus.desmos.network:26657";

  static const _lcdUrl = "http://10.0.2.2:1317";
  static const _rpcUrl = "http://10.0.2.2:26657";
  final _networkInfo = NetworkInfo(bech32Hrp: "desmos", lcdUrl: _lcdUrl);

  @override
  void configure(Binder binder) {
    binder
      ..bindLazySingleton<WalletSource>(
        (injector, params) => WalletSourceImpl(
          networkInfo: _networkInfo,
        ),
      )
      ..bindLazySingleton<LocalPostsSource>(
        (injector, params) => LocalPostsSourceImpl(dbPath: "posts.db"),
        name: "local",
      )
      ..bindLazySingleton<RemotePostsSource>(
        (injector, params) => RemotePostsSourceImpl(
          rpcEndpoint: _rpcUrl,
          chainHelper: ChainHelper(
            lcdEndpoint: _lcdUrl,
            rpcEndpoint: _rpcUrl,
            httpClient: http.Client(),
          ),
          walletSource: injector.get(),
        ),
        name: "remote",
      );
  }
}
