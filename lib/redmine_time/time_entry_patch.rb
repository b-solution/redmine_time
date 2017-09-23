require_dependency 'time_entry'
module RedmineTime
  module TimeEntryPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        # Same as typing in the class.
        unloadable # Send unloadable so it will not be unloaded in development.
        safe_attributes 'accept_time', 'external_time'
        alias_method_chain :hours, :time
      end
    end
  end

  module InstanceMethods
    def hours_with_time
      if !User.current.admin? && User.current.allowed_to?(:view_external_time, nil, {:global => true})
        h = read_attribute(:external_time)
        if h.is_a?(Float)
          h.round(2)
        else
          h
        end
      else
        hours_without_time
      end

    end
  end
end
