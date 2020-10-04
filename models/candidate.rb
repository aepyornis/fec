# frozen_string_literal: true

class Candidate < ActiveRecord::Base
  self.primary_key = 'CAND_ID'

  belongs_to :pcc, foreign_key: 'CAND_PCC', optional: true, class_name: 'Committee'

  def incumbent?
    attributes['CAND_ICI'] == 'I'
  end

  def challeneger?
    attributes['CAND_ICI'] == 'C'
  end

  def open_seat?
    attributes['CAND_ICI'] == 'O'
  end

  def self.search(name)
    where 'CAND_NAME LIKE ?', "%#{name}%"
  end

  def self.republicans
    where 'CAND_PTY_AFFILIATION' => 'REP'
  end

  def self.democrats
    where 'CAND_PTY_AFFILIATION' => 'DEM'
  end

  def self.year(y)
    where 'CAND_ELECTION_YR' => y.to_i.to_s
  end
  # state is upcase and abbreviated
  def self.state(st)
    where 'CAND_OFFICE_ST' => st.upcase
  end

  def self.house_candidates
    where 'CAND_OFFICE' => 'H'
  end

  def self.senate_candidates
    where 'CAND_OFFICE' => 'S'
  end

  def self.random
    order('RANDOM()')
  end
end
