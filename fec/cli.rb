# frozen_string_literal: true

module Fec
  module Cli
    Config = Struct.new(:table, :download, :import, :dbfile, :all, :clean)

    def self.run
      config = parse_options

      Fec::Database.dbfile = config.dbfile
      Fec::Database.establish_connection if config.import || config.clean

      FileUtils.mkdir_p(File.join(Dir.pwd, 'data')) if config.download

      if config.all
        Fec::Downloader.download_all if config.download
        Fec::Importer.import_all if config.import
      elsif config.table
        Fec::Downloader.new(config.table).download if config.download
        Fec::Importer.new(config.table).import if config.import
      end

      Fec::Database.clean_data if config.clean
    end

    def self.parse_options
      Config.new.tap do |config|
        OptionParser.new do |opts|
          opts.banner = "Usage: fec [options]"

          config.dbfile = File.absolute_path('./fec2020.db')

          opts.on("-f", "--table=[FILE]", "file name") do |file|
            config.dbfile = file
          end

          opts.on("-t", "--table=TABLE", "table name") do |table|
            config.table = table
          end

          opts.on("--all", "Use all tables") do |all|
            config.table = nil if all
            config.all = all
          end

          opts.on("-d", "--download", "Download data") do |download|
            config.download = download
          end

          opts.on("-i", "--import", "Import table") do |import|
            config.import = import
          end

          opts.on("-c", '--clean', "clean tables") do |clean|
            config.clean = clean
          end

          opts.on("-r", "--run", "Download and import tabes") do |run|
            if run
              config.download = true
              config.import = true
              config.clean = true
            end
          end

          opts.on("-h", "--help", "Prints this help") do
            puts opts
            exit
          end
        end.parse!
      end
    end
  end # end Fec::Cli
end
