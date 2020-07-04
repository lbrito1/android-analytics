class Hits < Sequel::Model
  VALID_DOMAINS = ENV['VALID_DOMAINS'].split(',')

  def validate
    super
    errors.add(:domain, 'is invalid') if VALID_DOMAINS.none? { |domain| url.match?(domain) }

    time_overlap = ((created_at - 2.5.seconds)..(created_at + 2.5.seconds))
    similar_reqs = self.class.where(ip: ip, created_at: time_overlap)

    errors.add(:ip, 'too many requests') if similar_reqs.count > 10
  end
end
