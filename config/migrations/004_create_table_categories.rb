Sequel.migration do
  up do
    create_table :categories do
      primary_key  :id
      String       :category, :null => false
      Time         :created_time
    end
  end

  down do
    drop_table :categories
  end
end
