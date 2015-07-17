# -*- coding: utf-8 -*-
$LOAD_PATH.unshift('/Library/RubyMotion/lib')
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'ClearStyle'
  app.identifier = 'io.knoxjeffrey.github'
  app.codesign_certificate = 'iPhone Developer: Jeffrey Knox'
  app.provisioning_profile = '../../Certificates/DevelopmentProvisioningProfile.mobileprovision'

  app.info_plist['UIViewControllerBasedStatusBarAppearance'] = false

  # Frameworks
  app.frameworks += [
    'QuartzCore'
  ]
end
