#!/usr/bin/env ruby

require 'pry'
require 'active_record'

# FEC tables
require_relative 'models/candidate'
require_relative 'models/committee'
require_relative 'models/contribution'
require_relative 'models/committee_contribution'
require_relative 'models/expenditure'
require_relative 'models/transaction'
# Our Tables
require_relative 'models/donor'
require_relative 'models/client'

require_relative 'database'

def run
  Database.establish_connection('./fec2020.db')
  Database.clean_data
  # binding.pry
  puts Database.uniq_test(Contribution.table_name, 'TRAN_ID')
  puts Database.uniq_test(Contribution.table_name, 'IMAGE_NUM')
end

run
