require "../spec_helper"

include Aws::Credentials::CredentialsWithExpiration

module Aws::Credentials
  describe CredentialsWithExpiration do
    it "resolved" do
      current = Time.parse_iso8601 "2019-05-20T23:00:00Z"
      credentials = Credentials.new(
        access_key_id: "ACCESSKEY",
        secret_access_key: "SECRET",
        session_token: Random::Secure.hex(16),
        expiration: Time.parse_iso8601 "2019-05-21T00:00:00Z"
      )
      actual = unresolved_or_expired(credentials, ->{ current })
      actual.should be_false
    end
  end
  it "unresolved" do
    current = Time.parse_iso8601 "2019-05-20T00:00:00Z"
    actual = unresolved_or_expired(nil, ->{ current })
    actual.should be_true
  end
  it "expired" do
    current = Time.parse_iso8601 "2019-05-21T00:10:00Z"
    credentials = Credentials.new(
      access_key_id: "ACCESSKEY",
      secret_access_key: "SECRET",
      session_token: Random::Secure.hex(16),
      expiration: Time.parse_iso8601 "2019-05-21T00:00:00Z"
    )
    actual = unresolved_or_expired(credentials, ->{ current })
    actual.should be_true
  end
  it "not expired without a buffer right before expiration" do
    current = Time.parse_iso8601 "2019-05-20T23:59:59Z"
    credentials = Credentials.new(
      access_key_id: "ACCESSKEY",
      secret_access_key: "SECRET",
      session_token: Random::Secure.hex(16),
      expiration: Time.parse_iso8601 "2019-05-21T00:00:00Z"
    )
    expired?(credentials, ->{ current }).should be_false
  end
  it "expired within the buffer" do
    current = Time.parse_iso8601 "2019-05-20T23:56:00Z"
    credentials = Credentials.new(
      access_key_id: "ACCESSKEY",
      secret_access_key: "SECRET",
      session_token: Random::Secure.hex(16),
      expiration: Time.parse_iso8601 "2019-05-21T00:00:00Z"
    )
    expired?(credentials, ->{ current }, 5.minutes).should be_true
    expired?(credentials, ->{ current }, 3.minutes).should be_false
  end
end
