class Hits < ApplicationRecord
  DOMAINS=%w(lbrito1.github.io enpassant.tk)

  validate :domain_in_whitelist
  validate :too_many_requests

  validates :url,        length: { maximum: 256 }
  validates :ip,         length: { maximum: 32 }
  validates :user_agent, length: { maximum: 256 }
  validates :country,    length: { maximum: 128 }
  validates :region,     length: { maximum: 128 }
  validates :city,       length: { maximum: 128 }
  validates :device,     length: { maximum: 32 }
  validates :os,         length: { maximum: 32 }

  def domain_in_whitelist
    errors.add(:url, 'is invalid') if DOMAINS.none? { |domain| url.match?(domain) }
  end

  def too_many_requests
    time_overlap = ((created_at - 2.5.second)..(created_at + 2.5.second))
    similar_reqs = self.class.where(ip: ip, created_at: time_overlap)

    errors.add(:ip, 'too many requests') if similar_reqs.count > 10
  end
end
