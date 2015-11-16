class Balance < ActiveRecord::Base
  include ActiveModel::Dirty
  belongs_to :credit_agreement
  after_initialize :set_date
  after_save :update_following
  after_destroy :touch_credit_agreement

  delegate :interest_rate, to: :credit_agreement
  delegate :creditor, to: :credit_agreement

  scope :older_than, ->(from_date){ where(['date > ?', from_date]) }
  scope :younger_than, ->(from_date){ where(['date < ?', from_date]) }
  scope :automatic, ->{ where(manually_edited: false) }

  alias_method :update_end_amount!, :save

  ransacker(:year){ Arel.sql('extract(year from date)') }

  def to_partial_path
    'balances/balance'
  end

  def self.interest_sum
    all.to_a.sum{| b| b.interests_sum }
  end

  def interests_sum
    self[:interests_sum] ||= calculated_interests_sum
  end

  def interest_spans
    breakpoints.each_cons(2).map{ |pair| interest_span_class.new(self, pair) }
  end

  def start_amount
    @start_amount ||= last_years_balance.end_amount
  end

  def sum_upto(to_date)
    start_amount + deposits.younger_than_inc(to_date).sum(:amount) - disburses.younger_than_inc(to_date).sum(:amount)
  end

  def deposits
    credit_agreement.deposits.this_year_upto(date)
  end

  def disburses
    credit_agreement.disburses.this_year_upto(date)
  end

  def payments
    credit_agreement.payments.this_year_upto(date)
  end

  private
    def last_years_balance
      Balance.find_by(credit_agreement_id: credit_agreement_id, date: end_of_last_year) || NullBalance.new
    end

    def set_date
      self.date ||= Date.today
    end

    def set_interest_sum
      self.interests_sum = calculated_interests_sum
    end

    def update_following
      following_balance.update_end_amount!
    end

    def following_balance
      credit_agreement.balances.reload.older_than(date).order(:date).first || NullBalance.new
    end

    def past_years_payments
      credit_agreement.payments.younger_than_inc(end_of_last_year)
    end

    def calculated_interests_sum
      interest_spans.sum(&:amount)
    end

    def end_of_last_year
      date.prev_year.end_of_year
    end

    def touch_credit_agreement
      credit_agreement.touch
    end

  class NullBalance
    def end_amount
      0
    end

    def update_end_amount!
    end
  end
end
