require_dependency 'timelog_controller'
module RedmineTime
  module TimelogControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        # Same as typing in the class.
        unloadable # Send unloadable so it will not be unloaded in development.
        alias_method_chain :index, :time
        before_filter :check_report_user, only: [:report]

      end
    end
  end

  module InstanceMethods
    def index_with_time
      if !User.current.admin? && User.current.allowed_to?(:view_external_time, nil, {:global => true})
        @query = TimeEntryQuery.build_from_params(params, :project => @project, :name => '_')

        sort_init(@query.sort_criteria.empty? ? [['spent_on', 'desc']] : @query.sort_criteria)
        sort_update(@query.sortable_columns)
        scope = time_entry_scope(:order => sort_clause).
            includes(:project, :user, :issue).
            preload(:issue => [:project, :tracker, :status, :assigned_to, :priority])

        respond_to do |format|
          format.html {
            @entry_count = scope.count
            @entry_pages = Redmine::Pagination::Paginator.new @entry_count, per_page_option, params['page']
            @entries = scope.offset(@entry_pages.offset).limit(@entry_pages.per_page).to_a
            @total_hours = scope.sum(:external_time).to_f

            render :layout => !request.xhr?
          }
          format.api  {
            @entry_count = scope.count
            @offset, @limit = api_offset_and_limit
            @entries = scope.offset(@offset).limit(@limit).preload(:custom_values => :custom_field).to_a
          }
          format.atom {
            entries = scope.limit(Setting.feeds_limit.to_i).reorder("#{TimeEntry.table_name}.created_on DESC").to_a
            render_feed(entries, :title => l(:label_spent_time))
          }
          format.csv {
            # Export all entries
            @entries = scope.to_a
            send_data(query_to_csv(@entries, @query, params), :type => 'text/csv; header=present', :filename => 'timelog.csv')
          }
        end
      else
        index_without_time
      end
    end

    private
    def check_report_user
      if !User.current.admin? && User.current.allowed_to?(:view_external_time, nil, {:global => true})
        render_403
      end
    end
  end
end
