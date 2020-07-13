Sequel.migration do
  up do
    create_table :cefrs do
      primary_key  :id
      String       :cefr
    end
  end

  down do
    drop_table :cefrs
  end
end
