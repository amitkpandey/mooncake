import 'package:mooncake/dependency_injection/dependency_injection.dart';
import 'package:mooncake/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Represents the screen that is shown to the user during the application
/// loading before having defined whether the user is authenticated or not.
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        if (state is LoggedOut) {
          return LoginScreen();
        } else if (state is LoggedIn) {
          return _homeScreen();
        }

        return Container(
          padding: EdgeInsets.all(16.0),
          color: PostsTheme.primaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/logo.png', width: 200),
            ],
          ),
        );
      },
    );
  }

  Widget _homeScreen() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(
            loginBloc: BlocProvider.of(context),
            logoutUseCase: Injector.get(),
          ),
        ),
      ],
      child: HomeScreen(),
    );
  }
}
