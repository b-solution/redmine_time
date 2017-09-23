module RedmineTime
  module IssuesControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        def get_time_entries
          @time_entries = @issue.time_entries.preload(:user, :activity).order("#{TimeEntry.table_name}.spent_on DESC")
          @time_entries_for_table = if !User.current.admin? && User.current.allowed_to?(:view_external_time, @issue.project)
                                      @issue.time_entries.preload(:user, :activity)
                                          .select('user_id, activity_id, sum(external_time) as hours_sum')
                                          .group(:user_id, :activity_id).order(:activity_id)
                                    else
                                      @issue.time_entries.preload(:user, :activity)
                                          .select('user_id, activity_id, sum(hours) as hours_sum')
                                          .group(:user_id, :activity_id).order(:activity_id)
                                    end
        end
      end
    end

    module InstanceMethods



    end
  end
end
