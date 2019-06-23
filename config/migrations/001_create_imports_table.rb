Sequel.migration do
  up do
    create_table :imports do
      primary_key  :import_id
      String       :name, :null => false
      Time         :created_time
    end
  end

  down do
    drop_table :imports
  end
end
