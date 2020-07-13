Sequel.migration do
  up do
    create_table :headwords_labels do
      primary_key  :id
      Integer      :headword_id, index: true
      Integer      :label_id, index: true
    end
  end

  down do
    drop_table :headwords_labels
  end
end
