import 'package:easyph/ui/views/auth/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../common/app_colors.dart';
import 'SignUp.dart';
import 'login.dart';

/// @author
/// George David
/// email: georgequin19@gmail.com
/// Feb, 2024

enum PresentPage {
  login,
  register,
  signup,
}

class AuthView extends StatefulWidget {
  final PresentPage? initialPage;
  final Map<String, dynamic>? parametersArg;

  const AuthView({Key? key, this.initialPage, this.parametersArg})
      : super(key: key);

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> with TickerProviderStateMixin {
  late PresentPage presentPage;

  @override
  void initState() {
    super.initState();
    print('value of initial page is ${widget.initialPage}');
    presentPage = widget.initialPage ?? PresentPage.login;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top Decorative Background
          Align(
            alignment: Alignment.topCenter,
            child: ClipPath(
              clipper: CurvedClipper(),
              child: Container(
                height: 300,
                color: kcClipColor,
              ),
            ),
          ),
          // Main Content
          CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      padding: const EdgeInsets.all(25),
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [
                          Flexible(
                            child: SingleChildScrollView(
                              child: getPageWidget(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getPageWidget() {
    switch (presentPage) {
      case PresentPage.login:
        return Login(
          updateIsLogin: (page) {
            setState(() {
              presentPage = page;
            });
          },
        );
      case PresentPage.signup:
        return SignUp(
          updatePage: (page) {
            setState(() {
              presentPage = page;
            });
          },
          isOtpRequested: widget.parametersArg?['isOtpRequested'] == 'true',
          userId: widget.parametersArg?['userId'],
          verificationCode: widget.parametersArg?['verificationCode'],
          phone: widget.parametersArg?['phone'],
          email: widget.parametersArg?['email'],
        );
      case PresentPage.register:
        return Register(
          updateIsLogin: (page) {
            setState(() {
              presentPage = page ? PresentPage.login : PresentPage.signup;
            });
          },
        );
      default:
        return Container();
    }
  }
}

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height - 300);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 0,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}