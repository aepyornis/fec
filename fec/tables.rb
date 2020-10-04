# frozen_string_literal: true

module Fec
  # Structure:
  #
  # table_name:
  #   filename:
  #   documentation:
  #   source:
  #     zip:
  #     header:
  #   output:
  #     data:
  #     header:
  TABLES = {
    expenditures: {
      filename: 'oppexp.txt',
      source: {
        zip: 'https://www.fec.gov/files/bulk-downloads/2020/oppexp20.zip',
        header: 'https://www.fec.gov/files/bulk-downloads/data_dictionaries/oppexp_header_file.csv'
      },
      output: {
        data: 'data/expenditures2020.csv',
        header: 'data/expenditures2020_header.csv'
      }
    },
    committees: {
      filename: 'cm.txt',
      source: {
        zip: "https://www.fec.gov/files/bulk-downloads/2020/cm20.zip",
        header: "https://www.fec.gov/files/bulk-downloads/data_dictionaries/cm_header_file.csv"
      },
      output: {
        data: 'data/committees2020.csv',
        header: 'data/committees2020_header.csv'
      }
    },
    candidates: {
      filename: 'cn.txt',
      source: {
        zip: "https://www.fec.gov/files/bulk-downloads/2020/cn20.zip",
        header: "https://www.fec.gov/files/bulk-downloads/data_dictionaries/cn_header_file.csv"
      },
      output: {
        data: 'data/candidates2020.csv',
        header: 'data/candidates2020_header.csv'
      },
      documentation: "https://www.fec.gov/campaign-finance-data/all-candidates-file-description/"
    },
    linkages: {
      filename: 'ccl.txt',
      source: {
        zip: "https://www.fec.gov/files/bulk-downloads/2020/ccl20.zip",
        header: "https://www.fec.gov/files/bulk-downloads/data_dictionaries/ccl_header_file.csv"
      },
      output: {
        data: 'data/linkages2020.csv',
        header: 'data/linkages2020_header.csv'
      }
    },
    individual_contributions: {
      filename: 'itcont.txt',
      source: {
        zip: "https://www.fec.gov/files/bulk-downloads/2020/indiv20.zip",
        header: "https://www.fec.gov/files/bulk-downloads/data_dictionaries/indiv_header_file.csv"
      },
      output: {
        data: 'data/individual_contributions2020.csv',
        header: 'data/individual_contributions2020_header.csv'
      },
      documentation: "https://www.fec.gov/campaign-finance-data/contributions-individuals-file-description/"
    },
    committee_contributions: {
      filename: 'itpas2.txt',
      source: {
        zip: "https://www.fec.gov/files/bulk-downloads/2020/pas220.zip",
        header: "https://www.fec.gov/files/bulk-downloads/data_dictionaries/pas2_header_file.csv"
      },
      output: {
        data: 'data/committee_contributions2020.csv',
        header: 'data/committee_contributions2020_header.csv'
      }
    },
    transactions: {
      filename: 'itoth.txt',
      source: {
        header: "https://www.fec.gov/files/bulk-downloads/data_dictionaries/oth_header_file.csv",
        zip: "https://www.fec.gov/files/bulk-downloads/2020/oth20.zip"
      },
      output: {
        data: 'data/transactions2020.csv',
        header: 'data/transactions2020_header.csv'
      }
    }
  }.freeze
end
