require 'csv'
require 'active_support/all'

require_relative '../config/initializers/ini_database'

class Import
  class << self
    FINDERS = {
      grammar_id: { :grammars => :grammar },
      grammar_description_id: { :grammar_descriptions => :grammar_description },
      category_id: { :categories => :category },
      cefr_id: { :cefrs => :cefr },
      :examples => :example,
      :labels => { labels: :label }
    }

    CSV_KEYS = {
      foreign: {
        grammar_id: :grammar,
        grammar_description_id: :grammar_description,
        cefr_id: :cefr },
      headword: {
        headword: :headword,
        definition: :definition,
        translation: :translation,
        learner_errors: :errors,
        skell: :skell,
        prirucka: :online_reference_book,
        note: :note
      }
    }

    def perform(file)
      %i[headwords examples headwords_labels].each { |table| DB[table].truncate }
      parse_file(file)
    end

  private

    def parse_file(file)
      parsed = []
      CSV.parse(File.read(File.join(file)), headers: true, header_converters: :symbol) do |row|
        next unless row[:hotovo] =~ /ano/

        ini_data = parse_foreign(row)
        examples = parse_examples(row)
        labels   = parse_labels(row)
        categories = parse_categories(row)
        parse_headword!(row, ini_data)
        parsed << { data: ini_data, examples: examples, labels: labels, categories: categories }
      end
      create_foreigns!(parsed)
      save_rows(parsed)
    end

    def save_rows(parsed)
      parsed.each_with_index.map do |row, index|
        id = DB[:headwords].insert(row[:data])
        # create examples
        row[:examples].each do |example|
          DB[:examples].insert(example: example, headword_id: id)
        end

        # create labels
        (row[:labels] || []).each do |label|
          label_id = insert_or_update(:labels, label)

          DB[:headwords_labels].insert(headword_id: id, label_id: label_id)
        end

        # create categories
        (row[:categories] || []).each do |label|
          label_id = insert_or_update(:labels, label)

          DB[:headwords_labels].insert(headword_id: id, label_id: label_id)
        end
        index
      end.size
    end

    def create_foreigns!(parsed)
      foreigns = {}
      parsed.each do |row|
        CSV_KEYS[:foreign].each_key do |key|
          foreigns[key] ||= Set.new
          foreigns[key] << row[:data][key]
        end
      end

      created_foreigns = {}
      foreigns.each do |key, values|
        values.each do |value|
          created_foreigns[key] ||= {}
          created_foreigns[key][value] = insert_or_update(key, value)
        end
      end
      parsed.each do |row|
        CSV_KEYS[:foreign].each_key do |key|
          row[:data][key] = created_foreigns[key][row[:data][key]]
        end
      end
      parsed
    end

    def parse_headword!(row, ini_data)
      CSV_KEYS[:headword].each do |column, csv_column|
        ini_data[column] = row[csv_column]
      end
    end

    def parse_examples(row)
      counter = 'i'
      data    = []
      loop do
        key = "example_#{counter}".to_sym
        break unless row.include?(key)
        break if row[key].blank?

        data << row[key]
        counter << 'i'
      end
      data
    end

    def parse_categories(row)
      return [] if row[:topicsc].blank?

      row[:topics].split(';').map { |c| c.strip }
    end

    def parse_labels(row)
      return [] if row[:labels].blank?

      row[:labels].split(';').map { |c| c.strip }
    end

    def parse_foreign(row)
      CSV_KEYS[:foreign].each_with_object({}) do |(column, csv_column), mem|
        mem[column] = row[csv_column]
      end
    end

    def downcase(text)
      UnicodeUtils.downcase(text)
    end

    def insert_or_update(table, value)
      response = DB[FINDERS[table].keys[0]].where(FINDERS[table].values[0] => value)
      return response.first[:id] if response.present?

      DB[FINDERS[table].keys[0]].insert(FINDERS[table].values[0] => value)
    end
  end
end
