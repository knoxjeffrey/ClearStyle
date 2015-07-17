class AppDelegate
  
  def window
    @window ||= UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
  end
  
  def storyboard
    @storyboard ||= UIStoryboard.storyboardWithName("Storyboard", bundle: nil)
  end
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    UIApplication.sharedApplication.setStatusBarStyle(UIStatusBarStyleLightContent)
    window.rootViewController = storyboard.instantiateInitialViewController
    window.makeKeyAndVisible

    true
  end
end
