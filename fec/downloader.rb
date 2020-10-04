# frozen_string_literal: true

module Fec
  # Using the data in the Fec::TABLES constant, this class downloads
  # and saves two csvs, one for the header and one with the data.
  # The data itself is stored in a zip file but the zipfile is disregarded
  class Downloader
    attr_reader :table, :config

    def self.download_all
      Fec::TABLES.keys.each do |table|
        puts "Downloading #{table}"
        new(table).download
      end
    end

    def initialize(table)
      @table_name = table
      @config = Fec::TABLES.fetch(table)
      @line_parser = if @table_name == :expenditures
                       ->(line) { CSV.parse_line(line, col_sep: '|', quote_char: "\x00")[0..24] }
                     else
                       ->(line) { CSV.parse_line(line, col_sep: '|', quote_char: "\x00") }
                     end
    end

    def download
      save_header(config)

      CSV.open(@config[:output][:data], "w") do |csv_file|
        URI.open(@config[:source][:zip]) do |zip_file|
          stream_lines(zip_file, @config[:filename]) do |line|
            csv_file << @line_parser.call(line)
          end
        end
      end
    end

    private

    # Input: <IO>, String, Block
    # Open a zip file and read the entry (a file inside) line by line
    def stream_lines(zip_file, entry, &block)
      Zip::File.open_buffer(zip_file) do |zip|
        zip.get_entry(entry).get_input_stream.each_line(&block)
      end
    end

    def save_header(table_config)
      File.open(table_config[:output][:header], 'w') do |f|
        f.write URI.open(table_config[:source][:header]).read
      end
    end
  end
end
