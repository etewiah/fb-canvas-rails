class ApplicationController < ActionController::Base
  before_filter :detect_facebook_post!
  protect_from_forgery
  layout :set_layout

  helper_method :get_session
  helper_method :logged_in?

  #
  # Detect if we're received a POST with a signed_request parameter.
  #
  # The request has already been turned into a GET request at this point to
  # preserve RESTfulness, but we can access the signed_request and it's
  # deencrypted version through request.env['facebook.signed_request']
  # and request.env['facebook.params'].
  #
  def detect_facebook_post!
    if request.env['facebook.params']
      logger.info "Received POST w/ signed_request from Facebook."
      log_in_with_facebook request.env['facebook.params']
    end
    true
  end

  def redirect_to_auth_facebook!
    redirect_to '/auth/facebook'
  end

  def log_in_with_facebook(auth_hash)
    if auth_hash['uid'] || auth_hash['user_id']
      logger.info "Logging in with Facebook..."
      if get_session[:user].nil? || (auth_hash['uid'] || auth_hash['user_id']).try(:to_i) != get_session[:user][:uid]
        logger.info "Logging in user #{auth_hash['uid'] || auth_hash['user_id']}"

        # In real life, you'd perform some real authentication here
        u = {}
        u[:uid]              = (auth_hash['uid'] || auth_hash['user_id']).to_i
        u[:token]            = auth_hash.value_at_path 'credentials', 'token'
        u[:token_expires_at] = Time.at(auth_hash.value_at_path('credentials', 'expires_at').to_i)
        u[:logged_in_at]     = Time.now
        session[:user] = u
      end
      true
    else
      logger.info "Tried to login with Facebook. :uid was not specified. Aborting."
      log_out
      false
    end
  end

  def logged_in?
    !! get_session[:user]
  end

  def log_out
    session[:user] = nil
  end

  # Get the session. If it's present in the header, this has precedence over the regular cookie session.
  def get_session
    if has_session_in_header?
      logger.info "Reading session from header"
      return @header_session if @header_session
      encrypted_session = request.headers['X-Session']
      secret = FBCanvasRails::Application.config.secret_token
      verifier = ActiveSupport::MessageVerifier.new(secret, 'SHA1')
      @header_session = verifier.verify(encrypted_session).with_indifferent_access
    else
      logger.info "Reading session from cookies"
      session
    end
  end

private
    # Change layout if request was CJAX
    def set_layout
      if request.headers['X-CJAX']
        logger.info "CJAX request received."
        "cjax"
      else
        logger.info "Regular, non-CJAX request received."
        "application"
      end
    end

  # Session present in request header (for CJAX requests)
  def has_session_in_header?
    !!(request.headers['X-Session'])
  end
end
