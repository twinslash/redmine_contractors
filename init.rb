require 'redmine_contractors'

Redmine::Plugin.register :redmine_contractors do
  name 'Redmine Contractors plugin'
  author 'Twinslash'
  description 'This is a plugin for managing contractors and their Redmine users'
  version '0.0.1'
  url 'https://github.com/twinslash/redmine_contractors.git'

  requires_redmine :version_or_higher => '2.1.2'

  settings :default => {
    :users_acl => {},
    :visibility => ''
  }

  menu :top_menu, :people, {:controller => 'people', :action => 'index', :project_id => nil}, :caption => :label_people, :if => Proc.new {
    User.current.allowed_people_to?(:view_people)
  }

  menu :admin_menu, :people, {:controller => 'people_settings', :action => 'index'}, :caption => :label_people

end
