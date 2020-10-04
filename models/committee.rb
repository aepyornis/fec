# frozen_string_literal: true

class Committee < ActiveRecord::Base
  self.primary_key = 'CMTE_ID'

  belongs_to :candidate, foreign_key: 'CAND_ID'

  # has_one :primary_candidate, foreign_key: 'CAND_PCC', inverse_of: :pcc

  def committee_id
    attributes['CMTE_ID']
  end
end
