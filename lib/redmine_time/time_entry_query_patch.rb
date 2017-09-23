require_dependency 'time_entry'
module RedmineTime
  module TimeEntryQueryPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        # Same as typing in the class.
        unloadable # Send unloadable so it will not be unloaded in development.
        alias_method_chain :available_columns, :time
        alias_method_chain :total_for_hours, :time if Redmine::VERSION::MAJOR >= 3 and Redmine::VERSION::MINOR > 3
        alias_method_chain :default_columns_names, :time
        alias_method_chain :default_totalable_names, :time if Redmine::VERSION::MAJOR >= 3 and Redmine::VERSION::MINOR > 3

      end
    end
  end

  module InstanceMethods
    def available_columns_with_time
      available_columns_without_time
      if can_view_internal_time? && can_view_external_time?
        match =  @available_columns.find{|c| c.name == :external_time}
        @available_columns << QueryColumn.new(:external_time, :sortable => "#{TimeEntry.table_name}.external_time", :totalable => true) unless match
      elsif can_view_external_time?
        match =  @available_columns.find{|c| c.name == :hours}
        @available_columns[@available_columns.index(match)] =  QueryColumn.new(:external_time, :sortable => "#{TimeEntry.table_name}.external_time", :totalable => true) if match
      end
      @available_columns
    end

    def can_view_internal_time?

      @view_internal_time ||=  User.current.allowed_to?(:view_internal_time, nil, {:global => true})
    end

    def can_view_external_time?
      @view_external_time ||= User.current.allowed_to?(:view_external_time, nil, {:global => true})
    end

    def total_for_external_time(scope)
      map_total(scope.sum(:external_time)) {|t| t.to_f.round(2)}
    end

    def total_for_hours_with_time(scope)
      if User.current.allowed_to?(:view_internal_time, nil, {:global => true})
        total_for_hours_without_time(scope)
      else
        map_total(scope.sum(:external_time)) {|t| t.to_f.round(2)}
      end

    end

    def default_columns_names_with_time
      return @default_columns_names if @default_columns_names
      @default_columns_names = default_columns_names_without_time
      if can_view_external_time?
        @default_columns_names<< :external_time
      end
      @default_columns_names
    end
    def default_totalable_names_with_time
      if can_view_internal_time? && can_view_external_time?
        [:external_time]
      else
        default_totalable_names_without_time
      end

    end

  end
end
