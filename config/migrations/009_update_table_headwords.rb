Sequel.migration do
  up do
    add_column :headwords, :cefr_id, Integer
    add_index :headwords, :cefr_id
  end

  down do
    drop_column :headwords, :cefr_id
  end
end