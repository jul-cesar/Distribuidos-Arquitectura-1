# frozen_string_literal: true

module Api
  module V1
    class UsersController < ActionController::API
      # GET /api/v1/users/me
      # Returns current user info including admin status
      def me
        auth_header = request.headers['Authorization']
        
        if auth_header && auth_header.start_with?('Bearer ')
          token_value = auth_header.gsub('Bearer ', '')
          
          # Spree uses SHA256 to hash tokens, try both plain and hashed
          token = Spree::OauthAccessToken.find_by(token: token_value) ||
                  Spree::OauthAccessToken.find_by(token: Digest::SHA256.hexdigest(token_value))
          
          if token && !token.revoked? && token.expires_in_seconds > 0
            user = Spree::User.find(token.resource_owner_id)
            
            render json: {
              id: user.id,
              email: user.email,
              is_admin: user.has_spree_role?(:admin)
            }
          else
            render json: { error: 'Invalid or expired token' }, status: :unauthorized
          end
        else
          render json: { error: 'No authorization header' }, status: :unauthorized
        end
      rescue ActiveRecord::RecordNotFound => e
        render json: { error: 'User not found' }, status: :not_found
      end
    end
  end
end
