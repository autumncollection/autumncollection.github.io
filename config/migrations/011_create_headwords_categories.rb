Sequel.migration do
  up do
    create_table :headwords_categories do
      primary_key  :id
      Integer      :headword_id, index: true
      Integer      :category_id, index: true
    end
  end

  down do
    drop_table :headwords_categories
  end
end
