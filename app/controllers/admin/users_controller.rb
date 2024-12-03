module Admin
  class UsersController < AdminController
    def index
      @users = User.all
      render json: @users
    end
  end
end 