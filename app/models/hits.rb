class Hits < Sequel::Model
  VALID_DOMAINS=%w(lbrito1.github.io enpassant.tk)

  def validate
    super
    errors.add(:domain, 'is invalid') if VALID_DOMAINS.none? { |domain| url.match?(domain) }
  end
end
