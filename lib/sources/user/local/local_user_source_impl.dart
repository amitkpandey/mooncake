import 'dart:convert';

import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';
import 'package:mooncake/entities/entities.dart';
import 'package:mooncake/repositories/repositories.dart';
import 'package:sembast/sembast.dart';

/// Contains the information that needs to be given to derive a [Wallet].
class _WalletInfo {
  final List<String> mnemonic;
  final NetworkInfo networkInfo;
  final String derivationPath;

  _WalletInfo(this.mnemonic, this.networkInfo, this.derivationPath);
}

/// Implementation of [LocalUserSource] that saves the mnemonic into a safe place
/// using the [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
/// plugin that stores it inside the secure hardware of the device.
class LocalUserSourceImpl extends LocalUserSource {
  static const _WALLET_DERIVATION_PATH = "m/44'/852'/0'/0/0";

  @visibleForTesting
  static const AUTHENTICATION_KEY = "authentication";

  @visibleForTesting
  static const USER_DATA_KEY = "user_data";

  @visibleForTesting
  static const ACTIVE = "active";

  @visibleForTesting
  static const ACCOUNTS = "accounts";

  @visibleForTesting
  static const ADDRESSES = "addresses";

  @visibleForTesting
  static const MNEMONIC_KEY = "mnemonic";

  final Database database;
  final NetworkInfo _networkInfo;
  final FlutterSecureStorage _storage;

  final store = StoreRef.main();

  LocalUserSourceImpl({
    @required Database database,
    @required NetworkInfo networkInfo,
    @required FlutterSecureStorage secureStorage,
  })  : assert(database != null),
        database = database,
        assert(networkInfo != null),
        this._networkInfo = networkInfo,
        assert(secureStorage != null),
        this._storage = secureStorage;

  /// Allows to derive a [Wallet] instance from the given [_WalletInfo] object.
  /// This method is static so that it can be called using the [compute] method
  /// to run it in a different isolate.
  static Wallet _deriveWallet(_WalletInfo info) {
    return Wallet.derive(
      info.mnemonic,
      info.networkInfo,
      derivationPath: info.derivationPath,
    );
  }

  @override
  Future<void> saveWallet(String mnemonic) async {
    final activeAccountAddress =
        await store.record('${USER_DATA_KEY}.${ACTIVE}').get(database);
    // Make sure the mnemonic is valid
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception("Error while saving wallet: invalid mnemonic.");
    }

    // Save it safely
    await _storage.write(
        key: '${USER_DATA_KEY}.${MNEMONIC_KEY}.${activeAccountAddress}',
        value: mnemonic.trim());
  }

  // returns mnemonic of current active account
  @override
  Future<List<String>> getMnemonic({String accountAddress}) async {
    String activeAccountAddress = accountAddress;
    if (activeAccountAddress == null) {
      activeAccountAddress = await store
          .record('${USER_DATA_KEY}.${ACTIVE}')
          .get(database) as String;
    }

    final mnemonic = await _storage.read(
        key: '${USER_DATA_KEY}.${MNEMONIC_KEY}.${activeAccountAddress}');
    if (mnemonic == null) {
      // The mnemonic does not exist, no wallet can be created.
      return null;
    }
    return mnemonic.split(" ");
  }

  @override
  Future<Wallet> getWallet({String accountAddress}) async {
    final mnemonic = await getMnemonic(accountAddress: accountAddress);
    if (mnemonic == null) return null;

    final walletInfo = _WalletInfo(
      mnemonic,
      _networkInfo,
      _WALLET_DERIVATION_PATH,
    );
    return compute(_deriveWallet, walletInfo);
  }

  @override
  Future<MooncakeAccount> saveAccount(MooncakeAccount data,
      {bool makeActive = true}) async {
    await database.transaction((txn) async {
      var addresses = await store
              .record('${USER_DATA_KEY}.${ADDRESSES}')
              .get(database) as List ??
          [];
      addresses.add(data?.address);
      addresses = addresses.toSet().toList();

      // log it in to list of locally stored account addresses
      await store
          .record('${USER_DATA_KEY}.${ADDRESSES}')
          .put(txn, data?.address);
      if (makeActive) {
        // makes this account active
        await store
            .record('${USER_DATA_KEY}.${ACTIVE}')
            .put(txn, data?.address);
      }
      // saves account by address
      await store
          .record('${USER_DATA_KEY}.${ACCOUNTS}.${data?.address}')
          .put(txn, data?.toJson());
    });
    return data;
  }

  Future<MooncakeAccount> _buildUserFromWalletHelper(
      {String accountAddress}) async {
    // If the database does not have the user, build it from the address
    final wallet = await getWallet(accountAddress: accountAddress);
    final address = wallet?.bech32Address;

    // If the address is null return null
    if (address == null) {
      return null;
    }

    // Build the user from the address and save it
    final user = MooncakeAccount.local(address);
    await saveAccount(user);

    return user;
  }

  @override
  Future<MooncakeAccount> getAccount() async {
    // Try getting the user from the database
    final activeAccountAddress =
        await store.record('${USER_DATA_KEY}.${ACTIVE}').get(database);
    dynamic record;
    if (activeAccountAddress != null) {
      record = await store
          .record('${USER_DATA_KEY}.${ACCOUNTS}.${activeAccountAddress}')
          .get(database);
    }

    if (record != null) {
      return MooncakeAccount.fromJson(record as Map<String, dynamic>);
    }
    return _buildUserFromWalletHelper();
  }

  @override
  Future<List<MooncakeAccount>> getAccounts() async {
    // Try getting the user from the database
    final addresses = await store
            .record('${USER_DATA_KEY}.${ADDRESSES}')
            .get(database) as List ??
        [];

    final List<MooncakeAccount> results = [];

    await Future.wait(addresses.toSet().toList().map((x) async {
      final record =
          await store.record('${USER_DATA_KEY}.${ACCOUNTS}.${x}').get(database);
      if (record != null) {
        results.add(MooncakeAccount.fromJson(record as Map<String, dynamic>));
      } else {
        final tryToBuildFromWallet =
            await _buildUserFromWalletHelper(accountAddress: x as String);

        if (tryToBuildFromWallet is MooncakeAccount) {
          results.add(tryToBuildFromWallet);
        }
      }
    }));
    return results;
  }

  @override
  Stream<MooncakeAccount> get accountStream {
    return store
        .query(finder: Finder(filter: Filter.byKey(USER_DATA_KEY)))
        .onSnapshots(database)
        .map((event) => event.isEmpty
            ? null
            : MooncakeAccount.fromJson(
                event.first.value as Map<String, dynamic>,
              ));
  }

  @override
  Future<void> saveAuthenticationMethod(AuthenticationMethod method) async {
    final methodString = jsonEncode(method.toJson());
    await _storage.write(key: AUTHENTICATION_KEY, value: methodString);
  }

  @override
  Future<AuthenticationMethod> getAuthenticationMethod() async {
    final methodString = await _storage.read(key: AUTHENTICATION_KEY);
    if (methodString == null) {
      return null;
    }

    return AuthenticationMethod.fromJson(
      jsonDecode(methodString) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> wipeData() async {
    await _storage.deleteAll();
    await store.delete(database);
  }
}
