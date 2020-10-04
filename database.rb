# frozen_string_literal: true

module Database
  def self.establish_connection(dbfile)
    return unless File.exist? dbfile

    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: dbfile)
  end

  def self.execute(*args)
    ActiveRecord::Base.connection.exec_query(*args)
  end

  def self.row_count(table)
    execute("SELECT COUNT(*) AS c FROM #{table}").first.fetch('c')
  end

  def self.distinct_column_count(table, column)
    execute("SELECT COUNT(DISTINCT #{column}) AS c FROM #{table}").first.fetch('c')
  end

  def self.uniq_test(table, column)
    count = row_count(table)
    uniq_values = distinct_column_count(table, column)

    if count == uniq_values
      "#{table}.#{column} is unique"
    else
      "#{table}.#{column} unique factor  is #{ (uniq_values / count.to_f ) }"
    end
  end

  def self.convert_column_blank_strings_to_null(table, column)
    execute "UPDATE #{table} SET #{column} = NULL WHERE #{column} = ''"
  end

  def self.clean_data
    convert_column_blank_strings_to_null 'committees', 'CAND_ID'
  end
end
