require_dependency 'time_entry'
module RedmineTime
  module IssueHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        # Same as typing in the class.
        unloadable # Send unloadable so it will not be unloaded in development.
        alias_method_chain :issue_spent_hours_details, :time

      end
    end
  end

  module InstanceMethods

    def issue_spent_hours_details_with_time(issue)
      issue_spent_hours_details_without_time(issue)

      # if issue.total_spent_hours > 0
      #   if User.current.allowed_to?(:view_external_time, issue.project)
      #     if issue.total_spent_hours == issue.spent_hours
      #       link_to(l_hours_short(issue.spent_hours), issue_time_entries_path(issue))
      #     else
      #       s = issue.spent_hours > 0 ? l_hours_short(issue.spent_hours) : ""
      #       s << " (#{l(:label_total)}: #{link_to l_hours_short(issue.total_spent_hours), issue_time_entries_path(issue)})"
      #       s.html_safe
      #     end
      #   else
      #
      #   end
      # end
    end
  end
end
