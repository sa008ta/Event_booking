require "test_helper"

class AuthenticationScreensControllerTest < ActionDispatch::IntegrationTest
  setup do
    @attributes = {
      student_num: "JS2500", name: "山田太郎", email: "student@example.com",
      password: "password123", password_confirmation: "password123"
    }
  end

  test "login screen displays the requested fields and registration link" do
    get root_url

    assert_response :success
    assert_select "input[name='session[identifier]']"
    assert_select "input[name='session[password]'][type='password']"
    assert_select "input[type='submit']:not([disabled])"
    assert_select "a[href=?]", sign_up_path
  end

  test "registration screen displays the requested fields and login link" do
    get sign_up_url

    assert_response :success
    assert_select "input[name='user[student_num]']"
    assert_select "input[name='user[name]']"
    assert_select "input[name='user[email]'][type='email']"
    assert_select "input[name='user[password]'][type='password'][minlength='8']"
    assert_select "input[name='user[password_confirmation]'][type='password']"
    assert_select "input[type='submit']:not([disabled])"
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", verification_path, count: 0
  end

  test "registration stores a hashed password and opens the blank screen" do
    assert_difference "User.count", 1 do
      post sign_up_url, params: { user: @attributes }
    end

    user = User.last
    assert_not_equal @attributes[:password], user.password_digest
    assert user.authenticate(@attributes[:password])
    assert_redirected_to home_path
    follow_redirect!
    assert_response :success
    assert_empty response.body
  end

  test "invalid registration shows errors without creating a user" do
    User.create!(@attributes)
    assert_no_difference "User.count" do
      post sign_up_url, params: { user: @attributes.merge(password: "short", password_confirmation: "short") }
    end

    assert_response :unprocessable_entity
    assert_select "[role=alert]", text: /この学籍番号は使われています/
    assert_select "[role=alert]", text: /このメールアドレスは使われています/
    assert_select "[role=alert]", text: /パスワードは8文字以上で入力してください/
  end

  test "registration rejects missing or mismatched confirmation" do
    [ nil, "another-password" ].each do |confirmation|
      assert_no_difference "User.count" do
        post sign_up_url, params: { user: @attributes.merge(password_confirmation: confirmation) }
      end
      assert_response :unprocessable_entity
    end
  end

  test "login accepts a student number or email" do
    User.create!(@attributes)
    [ "JS2500", "STUDENT@example.com" ].each do |identifier|
      reset!
      post login_url, params: { session: { identifier: identifier, password: @attributes[:password] } }
      assert_redirected_to home_path
      follow_redirect!
      assert_response :success
      assert_empty response.body
    end
  end

  test "login rejects wrong credentials" do
    User.create!(@attributes)
    [ "JS2500", "unknown" ].each do |identifier|
      post login_url, params: { session: { identifier: identifier, password: "wrong" } }
      assert_response :unprocessable_entity
      assert_select "[role=alert]", text: "メールアドレス・学籍番号かパスワードが違います"
    end
  end

  test "home requires a logged in user" do
    get home_url

    assert_redirected_to login_path
  end
end
