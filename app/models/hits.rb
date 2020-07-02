class Hits < Sequel::Model
  VALID_DOMAINS = ENV['VALID_DOMAINS'].split(',')

  def validate
    super
    errors.add(:domain, 'is invalid') if VALID_DOMAINS.none? { |domain| url.match?(domain) }
  end
end
