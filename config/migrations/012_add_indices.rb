Sequel.migration do
  up do
    add_index :categories, :category
    add_index :grammars, :grammar
    add_index :grammar_descriptions, :grammar_description
    add_index :cefrs, :cefr
    add_index :labels, :label
  end

  down do
    drop_index :categories, :category
    drop_index :grammars, :grammar
    drop_index :grammar_descriptions, :grammar_description
    drop_index :cefrs, :cefr
    drop_index :labels, :label
  end
end