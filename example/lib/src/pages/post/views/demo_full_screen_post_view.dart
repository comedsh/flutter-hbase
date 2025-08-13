
import 'package:hbase/hbase.dart';

import '../../profile/pages/demo_profile_page.dart';

class DemoFullScreenPostView extends PostFullScreenView {

  const DemoFullScreenPostView({
    super.key, 
    required super.post, 
    required super.postIndex
  });
  
  @override
  ProfilePage getProfilePage(Profile profile) {
    return DemoProfilePage(profile: profile,);
  }

}