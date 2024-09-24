module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      if verified_user = MockUser.find_by(id: JWT.decode(request.params[:token], Rails.application.secret_key_base).first["sub"])
        verified_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
