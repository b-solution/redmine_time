class TimeHook <  Redmine::Hook::ViewListener
  render_on :view_timelog_edit_form_bottom, partial: 'timelog/external_time'
end