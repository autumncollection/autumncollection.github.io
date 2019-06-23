Sequel.migration do
  up do
    create_table :grammar_descriptions do
      primary_key  :id
      String       :grammar_description, :null => false
      Time         :created_time
    end
  end

  down do
    drop_table :grammar_descriptions
  end
end
