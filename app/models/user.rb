class User < ApplicationRecord
  has_secure_password

  normalizes :student_num, with: ->(value) { value.strip }
  normalizes :email, with: ->(value) { value.strip.downcase }

  validates :student_num, presence: { message: "学籍番号を入力してください" },
    uniqueness: { message: "この学籍番号は使われています" }
  validates :name, presence: { message: "名前を入力してください" }
  validates :email, presence: { message: "メールアドレスを入力してください" },
    uniqueness: { message: "このメールアドレスは使われています" },
    format: { with: URI::MailTo::EMAIL_REGEXP, message: "正しいメールアドレス形式で入力してください", allow_blank: true }
  validates :password, length: { minimum: 8, message: "パスワードは8文字以上で入力してください" }, if: -> { password.present? }
  validates :password_confirmation, presence: { message: "パスワード確認を入力してください" }, if: -> { password.present? }
end
