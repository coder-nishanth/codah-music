import 'package:River/ytmusic/client.dart';
import 'package:River/ytmusic/mixins/library.dart';

import 'mixins/browsing.dart';
import 'mixins/search.dart';

class YTMusic extends YTClient with BrowsingMixin, LibraryMixin, SearchMixin {
  YTMusic({super.config, super.onIdUpdate});
}
