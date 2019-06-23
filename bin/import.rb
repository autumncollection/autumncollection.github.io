require 'csv'
require 'active_support/all'

require_relative '../config/initializers/ini_database'

class Import
  class << self
    FINDERS = {
      grammar_id: { :grammars => :grammar },
      grammar_description_id: { :grammar_descriptions => :grammar_description },
      category_id: { :categories => :category },
      :examples => :example
    }

    CSV_KEYS = {
      foreign: {
        grammar_id: 'Grammar',
        grammar_description_id: 'Grammar description',
        category_id: 'Category' },
      headword: {
        headword: 'Headword',
        definition: 'Definition',
        translation: 'Translation',
        learner_errors: 'Learner errors',
        skell: 'SkeLL',
        prirucka: 'prirucka',
        note: 'Note'
      }
    }

    def perform(file)
      %i[headwords examples].each { |table| DB[table].truncate }
      parse_file(file)
    end

  private

    def parse_file(file)
      parsed = []
      CSV.parse(File.read(file), headers: true) do |row|
        ini_data = parse_foreign(row)
        examples = parse_examples(row)
        parse_headword!(row, ini_data)
        parsed << { data: ini_data, examples: examples }
      end
      create_foreigns!(parsed)
      save_rows(parsed)
    end

    def save_rows(parsed)
      parsed.each_with_index.map do |row, index|
        id = DB[:headwords].insert(row[:data])
        row[:examples].each do |example|
          DB[:examples].insert(example: example, headword_id: id)
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
      counter = 'I'
      data    = []
      loop do
        key = "Example #{counter}"
        break unless row.include?(key)
        data << row[key]
        counter << 'I'
      end
      data
    end

    def parse_foreign(row)
      CSV_KEYS[:foreign].each_with_object({}) do |(column, csv_column), mem|
        mem[column] = row[csv_column]
      end
    end

    def insert_or_update(table, value)
      response = DB[FINDERS[table].keys[0]].where(FINDERS[table].values[0] => value)
      return response.first[:id] if response.present?

      DB[FINDERS[table].keys[0]].insert(FINDERS[table].values[0] => value)
    end
  end
end
