Sequel.migration do
  up do
    create_table :names do
      primary_key  :name_id
      String       :name, :null => false
      String       :heslo, :null => false
    end
  end

  down do
    drop_table :names
  end
end
