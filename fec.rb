#!/usr/bin/env ruby
# frozen_string_literal: true

# This script builds a sqlite database of 2019-2020 campaign finance data
# A csv file is also saved for each table, but the original zip and csv files are not kept.
#
# To the install the requirements on debian:
#   apt-get install ruby ruby-zip sqlite3
#
# The database ends up being over 2gb but all processing is done streaming,
# and the program should only require a few hundred mb of memory.
#
# The database is saved to fec2020.db

require 'csv'
require 'open-uri'
require 'open3'
require 'zip'

CONFIG = {
  expenditures: {
    header: 'https://www.fec.gov/files/bulk-downloads/data_dictionaries/oppexp_header_file.csv',
    zip: 'https://www.fec.gov/files/bulk-downloads/2020/oppexp20.zip',
    filename: 'oppexp.txt',
    csv: File.absolute_path('./expenditures2020.csv')
  },
  committees: {
    header: "https://www.fec.gov/files/bulk-downloads/data_dictionaries/cm_header_file.csv",
    zip: "https://www.fec.gov/files/bulk-downloads/2020/cm20.zip",
    filename: 'cm.txt',
    csv: File.absolute_path('./committees2020.csv')
  },
  candidates: {
    header: "https://www.fec.gov/files/bulk-downloads/data_dictionaries/cn_header_file.csv",
    zip: "https://www.fec.gov/files/bulk-downloads/2020/cn20.zip",
    filename: 'cn.txt',
    csv: File.absolute_path('./candidates2020.csv')
  },
  linkages: {
    header: "https://www.fec.gov/files/bulk-downloads/data_dictionaries/ccl_header_file.csv",
    zip: "https://www.fec.gov/files/bulk-downloads/2020/ccl20.zip",
    filename: 'ccl.txt',
    csv: File.absolute_path('./linkages2020.csv')
  },
  individual_contributions: {
    header: "https://www.fec.gov/files/bulk-downloads/data_dictionaries/indiv_header_file.csv",
    zip: "https://www.fec.gov/files/bulk-downloads/2020/indiv20.zip",
    filename: 'itcont.txt',
    csv: File.absolute_path('./individual_contributions2020.csv')
  },
  committee_contributions: {
    header: "https://www.fec.gov/files/bulk-downloads/data_dictionaries/pas2_header_file.csv",
    zip: "https://www.fec.gov/files/bulk-downloads/2020/pas220.zip",
    filename: 'itpas2.txt',
    csv: File.absolute_path('./committee_contributions2020.csv')
  },
  transactions: {
    header: "https://www.fec.gov/files/bulk-downloads/data_dictionaries/oth_header_file.csv",
    zip: "https://www.fec.gov/files/bulk-downloads/2020/oth20.zip",
    filename: 'itoth.txt',
    csv: File.absolute_path('./transactions2020.csv')
  }
}.freeze

DATABASE_PATH = File.absolute_path './fec2020.db'

# Executes the SQL script
def db_exec(sql)
  Open3.popen2 "sqlite3 #{DATABASE_PATH}" do |stdin|
    stdin.print sql
  end
end

# Input: <IO>, String, Block
# Open a zip file and read the entry (a file inside) line by line
def stream_lines(zip_file, entry, &block)
  Zip::File.open_buffer(zip_file) do |zip|
    zip.get_entry(entry).get_input_stream.each_line(&block)
  end
end

# Using the data in the CONFIG constant, this function downloads
# the header and zip file, opens the correct csv located inside the
# zip file, parses it, and saves a csv in the current directory.
#
# The block is optional. It allows a different line transformation function to be used.
# By default CSV.parse_line is used with "|" as the column separator and no quote char.
def process(table, &block)
  puts "Processing #{table}"
  config = CONFIG.fetch(table)
  headers = open(config[:header]).read.strip.split(',')

  CSV.open(config[:csv], "w", headers: headers, write_headers: true) do |csv_file|
    open(config[:zip]) do |zip_file|
      stream_lines(zip_file, config[:filename]) do |line|
        if block_given?
          csv_file << block.call(line)
        else
          csv_file << CSV.parse_line(line, col_sep: '|', quote_char: "\x00")
        end
      end
    end
  end
end

def import_csv(table)
  puts "Importing #{table}"
  db_exec <<~SQL
    .mode csv
    .header on
    .import #{CONFIG.fetch(table)[:csv]} #{table}
  SQL
end

db_exec <<~SQL
  CREATE TABLE IF NOT EXISTS expenditures (
    CMTE_ID TEXT NOT NULL,
    AMNDT_IND TEXT,
    RPT_YR INT,
    RPT_TP TEXT,
    IMAGE_NUM TEXT,
    LINE_NUM TEXT,
    FORM_TP_CD TEXT,
    SCHED_TP_CD TEXT,
    NAME TEXT,
    CITY TEXT,
    STATE TEXT,
    ZIP_CODE TEXT,
    TRANSACTION_DT DATE,
    TRANSACTION_AMT NUMBER,
    TRANSACTION_PGI TEXT,
    PURPOSE TEXT,
    CATEGORY TEXT,
    CATEGORY_DESC TEXT,
    MEMO_CD TEXT,
    MEMO_TEXT TEXT,
    ENTITY_TP TEXT,
    SUB_ID INTEGER NOT NULL UNIQUE,
    FILE_NUM INTEGER,
    TRAN_ID TEXT,
    BACK_REF_TRAN_ID TEXT
  )
SQL

db_exec <<~SQL
  CREATE TABLE IF NOT EXISTS committees (
    CMTE_ID TEXT NOT NULL,
    CMTE_NM TEXT,
    TRES_NM TEXT,
    CMTE_ST1 TEXT,
    CMTE_ST2 TEXT,
    CMTE_CITY TEXT,
    CMTE_ST TEXT,
    CMTE_ZIP TEXT,
    CMTE_DSGN TEXT,
    CMTE_TP TEXT,
    CMTE_PTY_AFFILIATION TEXT,
    CMTE_FILING_FREQ TEXT,
    ORG_TP TEXT,
    CONNECTED_ORG_NM TEXT,
    CAND_ID TEXT
  )
SQL

db_exec <<SQL
  CREATE TABLE IF NOT EXISTS candidates (
    CAND_ID TEXT NOT NULL,
    CAND_NAME TEXT,
    CAND_PTY_AFFILIATION TEXT,
    CAND_ELECTION_YR TEXT,
    CAND_OFFICE_ST TEXT,
    CAND_OFFICE TEXT,
    CAND_OFFICE_DISTRICT TEXT,
    CAND_ICI TEXT,
    CAND_STATUS TEXT,
    CAND_PCC TEXT,
    CAND_ST1 TEXT,
    CAND_ST2 TEXT,
    CAND_CITY TEXT,
    CAND_ST TEXT,
    CAND_ZIP TEXT
  )
SQL

db_exec <<~SQL
  CREATE TABLE IF NOT EXISTS linkages (
    CAND_ID TEXT NOT NULL,
    CAND_ELECTION_YR INT,
    FEC_ELECTION_YR INT,
    CMTE_ID TEXT,
    CMTE_TP TEXT,
    CMTE_DSGN TEXT,
    LINKAGE_ID INTEGER NOT NULL
  )
SQL

db_exec <<~SQL
  CREATE TABLE IF NOT EXISTS individual_contributions (
    CMTE_ID TEXT NOT NULL,
    AMNDT_IND TEXT,
    RPT_TP TEXT,
    TRANSACTION_PGI TEXT,
    IMAGE_NUM TEXT,
    TRANSACTION_TP TEXT,
    ENTITY_TP TEXT,
    NAME TEXT,
    CITY TEXT,
    STATE TEXT,
    ZIP_CODE TEXT,
    EMPLOYER TEXT,
    OCCUPATION TEXT,
    TRANSACTION_DT DATE,
    TRANSACTION_AMT NUMBER,
    OTHER_ID TEXT,
    TRAN_ID TEXT,
    FILE_NUM TEXT,
    MEMO_CD TEXT,
    MEMO_TEXT TEXT,
    SUB_ID INTEGER NOT NULL
  )
SQL

db_exec <<~SQL
  CREATE TABLE IF NOT EXISTS committee_contributions (
    CMTE_ID TEXT NOT NULL,
    AMNDT_IND TEXT,
    RPT_TP TEXT,
    TRANSACTION_PGI TEXT,
    IMAGE_NUM TEXT,
    TRANSACTION_TP TEXT,
    ENTITY_TP TEXT,
    NAME TEXT,
    CITY TEXT,
    STATE TEXT,
    ZIP_CODE TEXT,
    EMPLOYER TEXT,
    OCCUPATION TEXT,
    TRANSACTION_DT DATE,
    TRANSACTION_AMT NUMBER,
    OTHER_ID TEXT,
    CAND_ID TEXT,
    TRAN_ID TEXT,
    FILE_NUM TEXT,
    MEMO_CD TEXT,
    MEMO_TEXT TEXT,
    SUB_ID INTEGER NOT NULL
  )
SQL

db_exec <<~SQL
  CREATE TABLE IF NOT EXISTS transactions (
    CMTE_ID TEXT NOT NULL,
    AMNDT_IND TEXT,
    RPT_TP TEXT,
    TRANSACTION_PGI TEXT,
    IMAGE_NUM TEXT,
    TRANSACTION_TP TEXT,
    ENTITY_TP TEXT,
    NAME TEXT,
    CITY TEXT,
    STATE TEXT,
    ZIP_CODE TEXT,
    EMPLOYER TEXT,
    OCCUPATION TEXT,
    TRANSACTION_DT DATE,
    TRANSACTION_AMT NUMBER,
    OTHER_ID TEXT,
    TRAN_ID TEXT,
    FILE_NUM INTEGER,
    MEMO_CD TEXT,
    MEMO_TEXT TEXT,
    SUB_ID INTEGER NOT NULL UNIQUE
  )
SQL

process(:expenditures) { |line| CSV.parse_line(line, col_sep: '|', quote_char: "\x00")[0..24] }
process :committees
process :candidates
process :linkages
process :individual_contributions
process :committee_contributions
process :transactions

import_csv :expenditures
import_csv :committees
import_csv :candidates
import_csv :linkages
import_csv :individual_contributions
import_csv :committee_contributions
import_csv :transactions
