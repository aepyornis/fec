# frozen_string_literal: true

module Fec
  class Importer
    attr_reader :table

    def initialize(table)
      @table = table
    end

    def import
      Database.execute <<~SQL
        .mode csv
        .import #{CONFIG.dig(table, :output, :csv)} #{table}
      SQL
    end

    def self.import_all
      setup_database

      Fec::TABLES.keys.each do |table|
        puts "Loading #{table}"
        new(table).import
      end
    end

    def self.setup_database
      Database.execute <<~SQL
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

      Database.execute <<~SQL
        CREATE TABLE IF NOT EXISTS committees (
          CMTE_ID TEXT NOT NULL UNIQUE,
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

      Database.execute <<~SQL
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

      Database.execute <<~SQL
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
      Database.execute <<~SQL
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
          SUB_ID INTEGER NOT NULL UNIQUE
        )
      SQL

      Database.execute <<~SQL
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
          SUB_ID INTEGER NOT NULL UNIQUE
        )
      SQL

      Database.execute <<~SQL
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
    end
  end
end
