module JsonWebToken
  SECRET = Rails.application.credentials.secret_key_base

  module_function

  def encode(payload, exp: 30.days.from_now)
    payload = payload.dup
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET)
  end

  def decode(token)
    body = JWT.decode(token, SECRET)[0]
    HashWithIndifferentAccess.new(body)
  rescue JWT::DecodeError
    nil
  end
end
