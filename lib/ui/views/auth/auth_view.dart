import 'package:afriprize/ui/common/app_colors.dart';
import 'package:afriprize/ui/components/background.dart';
import 'package:afriprize/ui/views/auth/register.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'auth_viewmodel.dart';
import 'login.dart';

class AuthView extends StatefulWidget {
  const AuthView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AuthViewState();
  }
}

class _AuthViewState extends State<AuthView> with TickerProviderStateMixin {
  late TabController tabController;
  final List<Widget> _tabs = [
    const Login(),
    const Register(),
  ];

  @override
  void initState() {
    tabController = TabController(length: _tabs.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: Background(
              children: [
                Positioned(
                  top: 30,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Image.asset("assets/images/logo.png"),
                )
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            child: Container(
                              height: 4,
                              width: MediaQuery.of(context).size.width,
                              color: kcVeryLightGrey,
                            ),
                          ),
                          TabBar(
                            controller: tabController,
                            labelColor: kcSecondaryColor,
                            unselectedLabelColor: kcBlackColor,
                            indicatorWeight: 4,
                            indicatorColor: kcSecondaryColor,
                            tabs: const [
                              Tab(
                                text: "Login",
                              ),
                              Tab(
                                text: "Register",
                              )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 1.7,
                        child: TabBarView(
                          controller: tabController,
                          children: _tabs,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}