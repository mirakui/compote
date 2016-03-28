class RegistrationController < ApplicationController
  def new
    @user = User.new
  end

  def create
    user_params = params.require(:user).permit(
      :email, :password, :password_confirmation
    )
    @user = User.new(user_params)

    if @user.save
      send_ticket_email @user
      redirect_to root_path, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  private
  def send_ticket_email(user)
    registration_token = Digest::SHA2.hexdigest rand.to_s
    expires_at = 1.day.from_now
  end
end
