Sequel.migration do
  up do
    create_table :labels do
      primary_key  :id
      String       :label, :null => false
      Time         :created_time
    end
  end

  down do
    drop_table :labels
  end
end
