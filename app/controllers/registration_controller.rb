class RegistrationController < ApplicationController
  def new
    @user = User.new
  end

  def create
    user_params = params.require(:user).permit(
      :email, :password, :password_confirmation
    )
    @user = User.new(user_params)

    User.transaction do
      if @user.save
        send_activation_email @user
        redirect_to root_path, notice: "#{@user.email} にメールを送信しました。メールに書かれたリンクをクリックしてアカウント登録を完了してください"
      else
        render :new
      end
    end
  end

  def activate
    token = RegistrationToken.find params[:token]
    token.validate!
    @user = User.find_by_id token.user_id
    if @user.activating?
      @user.active!
      token.delete
      # FIXME
      redirect_to root_path, notice: "メールアドレス #{@user.email} の認証が完了しました"
    else
      token.delete
      render plain: 'invalid activation token', status: 404
    end
  rescue RegistrationToken::InvalidToken
    render plain: 'your activation token is invalid', status: 401
  rescue RegistrationToken::NotFound
    render plain: 'your activation token has been expired', status: 401
  end

  private
  def send_activation_email(user)
    token = RegistrationToken.create user_id: user.id
    token.save!
    url = registration_activate_url token: token.value
    logger.info "activation: #{url}"
    # TODO send mail
  end
end
