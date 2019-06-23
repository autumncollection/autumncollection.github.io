Sequel.migration do
  up do
    create_table :examples do
      primary_key  :id
      Integer      :headword_id
      String       :example, :null => false
      Time         :created_time
    end
  end

  down do
    drop_table :examples
  end
end
