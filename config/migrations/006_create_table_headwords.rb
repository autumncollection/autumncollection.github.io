Sequel.migration do
  up do
    create_table :headwords do
      primary_key  :id
      Integer      :grammar_id
      Integer      :grammar_description_id
      Integer      :category_id
      String       :headword, index: true
      String       :definition
      String       :translation
      String       :learner_errors
      String       :skell
      String       :prirucka
      String       :note
      Time         :created_time
    end
  end

  down do
    drop_table :headwords
  end
end
