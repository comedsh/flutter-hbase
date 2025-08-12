
import 'package:hbase/hbase.dart';

import '../../profile/pages/demo_profile_page.dart';

class DemoFullScreenPostView extends FullScreenPostView {

  const DemoFullScreenPostView({
    super.key, 
    required super.post
  });
  
  @override
  ProfilePage getProfilePage(Profile profile) {
    return DemoProfilePage(profile: profile,);
  }

}