class AddExternalTimeToTimeEntry < ActiveRecord::Migration
  def change
    add_column :time_entries, :accept_time, :boolean, :default=> false
    add_column :time_entries, :external_time, :float, :default => 0
  end
end

