# frozen_string_literal: true

require 'active_record'
require 'csv'
require 'fileutils'
require 'open-uri'
require 'optparse'
require 'zip'

module Fec
end

require_relative 'fec/tables'
require_relative 'fec/database'
require_relative 'fec/transaction_type'
require_relative 'fec/downloader'
require_relative 'fec/cli'

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
