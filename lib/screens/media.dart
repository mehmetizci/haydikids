// Flutter
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:provider/provider.dart';
import 'package:haydikids/config/languages.dart';
import 'package:haydikids/provider/downloadsProvider.dart';
import 'package:haydikids/provider/managerProvider.dart';

// Internal
import 'package:haydikids/screens/mediaScreen/tabs/downloadsTab.dart';
import 'package:haydikids/screens/mediaScreen/tabs/musicTab.dart';
import 'package:haydikids/screens/mediaScreen/tabs/videosTab.dart';

// Packages
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:haydikids/screens/mediaScreen/components/mediaSearchBar.dart';

// UI
import 'package:haydikids/utils/ui/animations/showUp.dart';

class MediaScreen extends StatefulWidget {
  @override
  _MediaScreenState createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  // Search Controller and FocusNode
  TextEditingController searchController;
  FocusNode searchNode;

  // Current Search Query
  String searchQuery = "";

  @override
  void initState() {
    searchController = new TextEditingController();
    searchNode = new FocusNode();
    KeyboardVisibility.onChange.listen((bool visible) {
      if (visible == false) {
        searchNode.unfocus();
      }
    });
    Provider.of<DownloadsProvider>(context, listen: false).getDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ManagerProvider manager = Provider.of<ManagerProvider>(context);
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          titleSpacing: 0,
          elevation: 12,
          shadowColor: Colors.black.withOpacity(0.15),
          backgroundColor: Theme.of(context).cardColor,
          title: ShowUpTransition(
            forward: true,
            duration: Duration(milliseconds: 400),
            slideSide: SlideFromSlide.TOP,
            child: AnimatedSwitcher(
                duration: Duration(milliseconds: 250),
                child: !manager.showSearchBar
                    ? Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 8, left: 16),
                            child: Icon(
                              EvaIcons.musicOutline,
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                          Text(
                            Languages.of(context).labelMedia,
                            style: TextStyle(
                                fontFamily: 'Product Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .color),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(
                              EvaIcons.searchOutline,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            onPressed: () {
                              setState(() {
                                manager.showSearchBar = true;
                                if (manager.showSearchBar == true)
                                  searchNode.requestFocus();
                              });
                            },
                          ),
                          SizedBox(width: 16)
                        ],
                      )
                    : MediaSearchBar(
                        textController: searchController,
                        onClear: () => setState(() {
                          searchController.clear();
                          searchQuery = "";
                        }),
                        focusNode: searchNode,
                        onChanged: (String search) =>
                            setState(() => searchQuery = search),
                      )),
          ),
          bottom: TabBar(
            physics: BouncingScrollPhysics(),
            labelStyle: TextStyle(
                fontSize: 13,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3),
            unselectedLabelStyle: TextStyle(
                fontSize: 13,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2),
            labelColor: Theme.of(context).accentColor,
            unselectedLabelColor:
                Theme.of(context).textTheme.bodyText1.color.withOpacity(0.4),
            indicator: MD2Indicator(
              indicatorSize: MD2IndicatorSize.tiny,
              indicatorHeight: 4,
              indicatorColor: Theme.of(context).accentColor,
            ),
            tabs: [
              Tab(child: Text(Languages.of(context).labelDownloads)),
              Tab(child: Text(Languages.of(context).labelMusic)),
              Tab(child: Text(Languages.of(context).labelVideos))
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MediaDownloadTab(searchQuery),
            MediaMusicTab(searchQuery),
            MediaVideoTab(searchQuery)
          ],
        ),
      ),
    );
  }
}
