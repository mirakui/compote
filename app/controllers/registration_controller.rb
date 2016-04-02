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
      send_activation_email @user
      redirect_to root_path, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  def activate
    key = token_key params[:token]
    user_id = Rails.cache.read key
    if user_id
      @user = User.find_by_id user_id
      if @user.activating?
        @user.active!
        Rails.cache.delete key
        # FIXME
        redirect_to root_path, notice: 'activated'
      else
        Rails.cache.delete key
        render plain: 'invalid activation token', status: 404
      end
    else
      render plain: 'your activation token has been expired', status: 404
      # TODO error
    end
  end

  private
  def send_activation_email(user)
    token = Digest::SHA2.hexdigest rand.to_s
    Rails.cache.write token_key(token), user.id, expires_in: 1.day
    url = registration_activate_url token: token
    logger.info "activation: #{url}"
    # TODO send mail
  end

  def token_key(token)
    "registration/token/#{token}"
  end
end
