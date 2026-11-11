# Event Booking

## セットアップ

Ruby 3.4.12 と MySQL が必要です。`config/database.yml` に設定された
接続先を確認してください。開発・テスト用のMySQLユーザーを使う場合は、
そのユーザー名とパスワードを環境変数 `DB_USERNAME` と `DB_PASSWORD` に設定します。
設定しない場合は従来どおり root・パスワードなしで接続します。

次のコマンドを実行してください。

```sh
bundle install
bin/rails db:prepare
bin/rails server
```

ログイン画面は `/`、新規登録画面は `/sign_up` です。
新規登録後は自動的にログインし、空白画面に移動します。
メール認証は未実装のため、現在はメールアドレスの所有確認を行いません。

## テスト

```sh
bin/rails test test/controllers/authentication_screens_controller_test.rb
```
