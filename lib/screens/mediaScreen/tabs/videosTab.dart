// Flutter
import 'package:flutter/material.dart';

// Internal
import 'package:haydikids/core/models/folder.dart';
import 'package:haydikids/core/models/videoFile.dart';
import 'package:haydikids/utils/players/videoPlayer.dart';

// Packages
import 'package:permission_handler/permission_handler.dart';
import 'package:haydikids/provider/mediaProvider.dart';
import 'package:provider/provider.dart';
import 'package:haydikids/screens/mediaScreen/components/loadingListWidget.dart';
import 'package:haydikids/screens/mediaScreen/components/mediaListBase.dart';
import 'package:haydikids/screens/mediaScreen/components/noPermissionWidget.dart';

// UI
import 'package:haydikids/screens/mediaScreen/components/videoList/folderGridView.dart';
import 'package:haydikids/screens/mediaScreen/components/videoList/videosOnFolderListView.dart';

class MediaVideoTab extends StatefulWidget {
  final String searchQuery;
  MediaVideoTab(this.searchQuery);
  @override
  _MediaVideoTabState createState() => _MediaVideoTabState();
}

class _MediaVideoTabState extends State<MediaVideoTab> {
  // Current Viewing Folder
  FolderItem folderOnView;

  @override
  Widget build(BuildContext context) {
    MediaProvider mediaProvider = Provider.of<MediaProvider>(context);
    return MediaListBase(
      baseWidget: folderOnView == null
          ? FolderGridView(
              list: mediaProvider.listFolders,
              onFolderTap: (FolderItem selectedFolder) {
                setState(() => folderOnView = selectedFolder);
              })
          : VideosOnFolderListView(
              list: folderOnView.videos,
              onBackPressed: () => setState(() => folderOnView = null),
              onVideoTap: (VideoFile video) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AppVideoPlayer(video)));
              }),
      loadingWidget: const MediaLoadingWidget(),
      noPermissionWidget: NoPermissionWidget(onPermissionRequest: () {
        Permission.storage.request().then((value) {
          if (value == PermissionStatus.granted) {
            mediaProvider.storagePermission = true;
            mediaProvider.loadVideoList();
          }
        });
      }),
      permissionStatus: mediaProvider.storagePermission,
      listStatus: mediaProvider.listFolders.isNotEmpty,
    );
  }
}
