# frozen_string_literal: true

# https://www.fec.gov/campaign-finance-data/contributions-individuals-file-description/
class Contribution < ActiveRecord::Base
  self.table_name = 'individual_contributions'
  self.primary_key = 'SUB_ID'

  belongs_to :committee, foreign_key: 'CMTE_ID', class_name: 'Committee'

  def amendment_indicator
    case attributes['AMMDT_IND']
    when 'N'
      :new
    when 'A'
      :amendment
    when 'T'
      :termination
    end
  end

  def election_type
    case attributes['TRANSACTION_PGI']
    when 'P'
      :primary
    when 'G'
      :general
    when 'O'
      :other
    when 'C'
      :convention
    when 'R'
      :runoff
    when 'S'
      :special
    when 'E'
      :recount
    end
  end


  def transaction_type
    Fec::TransactionType.parse attributes['TRANSACTION_TP']
  end
end
