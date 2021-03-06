import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/classes/login_state.dart';
import 'package:turno_admin/widgets/appbar.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  //  List<HomeList> homeList = HomeList.homeList;
  AnimationController animationController;
  bool multiple = true;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync:this);
    super.initState();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
  Widget actionButtons(){
    return InkWell(
      borderRadius:
          BorderRadius.circular(AppBar().preferredSize.height),
      child: Icon(
          Icons.dashboard ,
        color: AppSettings.dark_grey,
      ),
      onTap: () {
        Provider.of<LoginState>(context, listen: false).logout();
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSettings.LIGTH,
      body: FutureBuilder<bool>(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return Container(child: Text(''),);
          } else {
            return Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  appBar('',null, actionButtons(), AppSettings.PRIMARY),
                  Expanded(
                    child: FutureBuilder<bool>(
                      future: getData(),
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        } else {
                          return GridView(
                            padding: const EdgeInsets.only(
                                top: 0, left: 12, right: 12),
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            // children: List<Widget>.generate(
                            //   homeList.length,
                            //   (int index) {
                            //     final int count = homeList.length;
                            //     final Animation<double> animation =
                            //         Tween<double>(begin: 0.0, end: 1.0).animate(
                            //       CurvedAnimation(
                            //         parent: animationController,
                            //         curve: Interval((1 / count) * index, 1.0,
                            //             curve: Curves.fastOutSlowIn),
                            //       ),
                            //     );
                            //     animationController.forward();
                            //     return HomeListView(
                            //       animation: animation,
                            //       animationController: animationController,
                            //       listData: homeList[index],
                            //       callBack: () {
                            //         Navigator.push<dynamic>(
                            //           context,
                            //           MaterialPageRoute<dynamic>(
                            //             builder: (BuildContext context) =>
                            //                 homeList[index].navigateScreen,
                            //           ),
                            //         );
                            //       },
                            //     );
                            //   },
                            // ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: multiple ? 2 : 1,
                              mainAxisSpacing: 12.0,
                              crossAxisSpacing: 12.0,
                              childAspectRatio: 1.5,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  
}

class HomeListView extends StatelessWidget {
  const HomeListView(
      {Key key,
      // this.listData,
      this.callBack,
      this.animationController,
      this.animation})
      : super(key: key);

  // final HomeList listData;
  final VoidCallback callBack;
  final AnimationController animationController;
  final Animation<dynamic> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation.value), 0.0),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    // Image.asset(
                    //   listData.imagePath,
                    //   fit: BoxFit.cover,
                    // ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.grey.withOpacity(0.2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4.0)),
                        onTap: () {
                          callBack();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

