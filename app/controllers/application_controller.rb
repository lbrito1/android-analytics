class ApplicationController < ActionController::Base
  # skip all filters
  filters = _process_action_callbacks.map(&:filter)
  if Rails::VERSION::MAJOR >= 5
    skip_before_action(*filters, raise: false)
    skip_after_action(*filters, raise: false)
    skip_around_action(*filters, raise: false)
  else
    skip_action_callback *filters
  end

  protect_from_forgery with: :null_session # this is the hack
end
