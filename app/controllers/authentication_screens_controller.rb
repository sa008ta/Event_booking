class AuthenticationScreensController < ApplicationController
  before_action :require_login, only: :home

  def login
  end

  def sign_up
    @user = User.new
  end

  def create_user
    @user = User.new(user_params)
    if @user.save
      reset_session
      session[:user_id] = @user.id
      redirect_to home_path
    else
      render :sign_up, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    raise if @user.valid?

    render :sign_up, status: :unprocessable_entity
  end

  def create_session
    identifier = params.dig(:session, :identifier).to_s.strip
    password = params.dig(:session, :password).to_s
    user = User.find_by(student_num: identifier)
    user ||= User.find_by(email: identifier.downcase)

    if user&.authenticate(password)
      reset_session
      session[:user_id] = user.id
      redirect_to home_path
    else
      @login_error = "メールアドレス・学籍番号かパスワードが違います"
      render :login, status: :unprocessable_entity
    end
  end

  def verification
  end

  def home
    head :ok
  end

  private

  def user_params
    params.require(:user).permit(:student_num, :name, :email, :password, :password_confirmation)
  end

  def require_login
    redirect_to login_path unless User.exists?(id: session[:user_id])
  end
end
