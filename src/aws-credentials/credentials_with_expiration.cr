module Aws::Credentials
  module CredentialsWithExpiration
    def unresolved_or_expired(maybe_resolved_credentials : Credentials?, current_time_provider : Proc(Time))
      return true unless maybe_resolved_credentials
      expired?(maybe_resolved_credentials, current_time_provider)
    end

    # Returns `true` if the credentials expire within `buffer` from now.
    #
    # A non-zero `buffer` lets callers refresh credentials ahead of time, so
    # they don't expire while a request signed with them is still in flight.
    def expired?(credentials : Credentials, current_time_provider : Proc(Time), buffer : Time::Span = Time::Span.zero)
      credentials.expiration.try { |exp|
        exp - buffer <= current_time_provider.call
      } || false
    end
  end
end
