class ApplicationController < ActionController::API

    include JsonWebToken

    before_action :authorize_request
  
    private
  
    # Decode the token and find the user
    def current_user
      @current_user ||= User.find(decoded_auth_token[:user_id]) if decoded_auth_token
    rescue ActiveRecord::RecordNotFound
      nil
    end
  
    # Decode the token from the Authorization header
    def decoded_auth_token
      token = request.headers['Authorization']&.split(' ')&.last
      JsonWebToken.decode(token) if token
    end
  
    # Set current_user and handle unauthorized requests
    def authorize_request
      render json: { errors: ['Not Authorized'] }, status: :unauthorized unless current_user
    end
  
end
