Sequel.migration do
  up do
    create_table :grammars do
      primary_key  :id
      String       :grammar, :null => false
      Time         :created_time
    end
  end

  down do
    drop_table :grammars
  end
end
