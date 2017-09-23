require_dependency 'time_entry'
module RedmineTime
  module IssuePatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        # Same as typing in the class.
        unloadable # Send unloadable so it will not be unloaded in development.
        alias_method_chain :spent_hours, :time
        alias_method_chain :total_spent_hours, :time

      end
    end
  end

  module InstanceMethods

    def can_view_internal_time?
      @view_internal_time ||=  User.current.allowed_to?(:view_internal_time, nil, {:global => true})
    end

    def can_view_external_time?
      @view_external_time ||= User.current.allowed_to?(:view_external_time, nil, {:global => true})
    end

    def spent_hours_with_time
      if can_view_internal_time?
        spent_hours_without_time
      elsif can_view_external_time?
        time_entries.sum(:external_time) || 0.0
      else
        0
      end
    end


# Returns the total number of hours spent on this issue and its descendants
    def total_spent_hours_with_time
      if can_view_internal_time?
        total_spent_hours_without_time
      elsif can_view_external_time?
        if leaf?
          spent_hours
        else
          self_and_descendants.joins(:time_entries).sum("#{TimeEntry.table_name}.external_time").to_f || 0.0
        end
      else
        total_spent_hours_without_time
      end
    end
  end
end
