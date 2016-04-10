class SessionController < ApplicationController
  before_action :login_required, only: [:destroy]
  def new
  end

  def create
    user = User.find_by_email(params[:email]) if params[:email]
    if user.present? && params[:password].present? && user.authenticate(params[:password])
      session[:user_id] = user.id
      # FIXME
      redirect_to root_path
    else
      flash.now.alert = 'メールアドレスまたはパスワードが間違っています'
      render :new
    end
  end

  def destroy
    session.delete :user_id
    redirect_to root_path
  end
end
