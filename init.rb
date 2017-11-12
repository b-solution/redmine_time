Redmine::Plugin.register :redmine_time do
  name 'Redmine Time plugin'
  author 'Bilel KEDIDI'
  description 'This is a Redmine plugin that add external time'
  version '0.0.2'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  project_module :time_tracking do
    permission :view_external_time, {}
    permission :view_internal_time, {}
    permission :add_external_time, {}
  end
end
require 'time_hook'
Rails.application.config.to_prepare do
  Issue.send(:include, RedmineTime::IssuePatch)
  IssuesHelper.send(:include, RedmineTime::IssueHelperPatch)
  IssuesController.send(:include, RedmineTime::IssuesControllerPatch)
  TimeEntry.send(:include, RedmineTime::TimeEntryPatch)
  TimelogController.send(:include, RedmineTime::TimelogControllerPatch)
  TimeEntryQuery.send(:include, RedmineTime::TimeEntryQueryPatch)
end



=begin
add 2 columns (external time, accept time)
permission of these 2 columns


-overview
 User can enter their own time

 XX can accept that time and add it

-User who can see that permission
will see the accepted hours
else no



=end

