require 'public_suffix'
require 'ipaddr'

module ValidatesUrlFormat
  class Validator
    IPv4_PART   = /\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]/  # 0-255
    IPv4_REGEXP = %r{\A(#{IPv4_PART}(\.#{IPv4_PART}){3})\z}
    IPv6_REGEXP = %r{
      (
      ([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|          # 1:2:3:4:5:6:7:8
      ([0-9a-fA-F]{1,4}:){1,7}:|                         # 1::                              1:2:3:4:5:6:7::
      ([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|         # 1::8             1:2:3:4:5:6::8  1:2:3:4:5:6::8
      ([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|  # 1::7:8           1:2:3:4:5::7:8  1:2:3:4:5::8
      ([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|  # 1::6:7:8         1:2:3:4::6:7:8  1:2:3:4::8
      ([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|  # 1::5:6:7:8       1:2:3::5:6:7:8  1:2:3::8
      ([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|  # 1::4:5:6:7:8     1:2::4:5:6:7:8  1:2::8
      [0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|       # 1::3:4:5:6:7:8   1::3:4:5:6:7:8  1::8
      :((:[0-9a-fA-F]{1,4}){1,7}|:)|                     # ::2:3:4:5:6:7:8  ::2:3:4:5:6:7:8 ::8       ::
      fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|     # fe80::7:8%eth0   fe80::7:8%1 (link-local IPv6 addresses with zone index)
      ::(ffff(:0{1,4}){0,1}:){0,1}
      ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
      (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|          # ::255.255.255.255   ::ffff:255.255.255.255  ::ffff:0:255.255.255.255 (IPv4-mapped IPv6 addresses and IPv4-translated addresses)
      ([0-9a-fA-F]{1,4}:){1,4}:
      ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
      (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])           # 2001:db8:3:4::192.0.2.33  64:ff9b::192.0.2.33 (IPv4-Embedded IPv6 Address)
      )
    }x
    ACCEPTED_SCRIPTS = '\p{Common}\p{Latin}\p{Cyrillic}\p{Arabic}\p{Georgian}'
    # A TLD's maximum length is 63 characters. https://developer.mozilla.org/en-US/docs/Learn/Common_questions/What_is_a_domain_name
    DOMAINNAME_REGEXP = %r{
      \A(xn--)?[#{ACCEPTED_SCRIPTS}_]+([-._][#{ACCEPTED_SCRIPTS}]+)*\.[^\d&&[#{ACCEPTED_SCRIPTS}]]{2,63}\.?\z
    }x
    USERINFO_REGEXP = %r{\A[^:&&[#{ACCEPTED_SCRIPTS}]]+:?[#{ACCEPTED_SCRIPTS}]*\z}

    LOCAL_TOP_DOMAINS = %W(local localhost intranet internet internal private corp home lan)

    DEFAULT_SCHEMES = %w(http https)

    def valid?(value, options)
      @options = options
      schemes = (options[:schemes] || DEFAULT_SCHEMES).map(&:to_s)

      return [false, :nil_or_blank_url] if not_allowed_nil_or_blank?(value)
      return [true, :valid_url] if value.nil? || value.blank?

      validate_url(value, schemes)
    end

    private

    def validate_url(value, schemes)
      encoded_value = URI.encode(value)
      uri = URI.parse(encoded_value)
      host = uri && uri.host && URI.decode(uri.host)
      scheme = uri && uri.scheme&.downcase

      return [false, :invalid_scheme] unless host && scheme && schemes.include?(scheme)
      return [false, :invalid_userinfo] unless uri.userinfo.nil? || uri.userinfo.match?(USERINFO_REGEXP)

      case host
      when IPv6_REGEXP
        # TODO: Add IPv6 local addresses filtration
        [true, :valid_url]
      when IPv4_REGEXP
        return [false, :local_url] if filter_local? && ipv4_local_address?(host)

        [true, :valid_url]
      when DOMAINNAME_REGEXP
        return [false, :space_symbol] if value.include?(' ')
        return [false, :local_url] if filter_local? && domainname_local_address?(host)
        return [false, :public_suffix] if check_by_publicsuffix? && !PublicSuffix.valid?(host, :default_rule => nil)

        [true, :valid_url]
      else
        [false, :invalid_url]
      end
    rescue URI::InvalidURIError
      [false, :invalid_url]
    end

    def not_allowed_nil_or_blank?(value)
      (value.nil? && !@options[:allow_nil]) ||
        (value.blank? && !@options[:allow_blank])
    end

    def filter_local?
      @options[:no_local]
    end

    def check_by_publicsuffix?
      @options[:public_suffix]
    end

    def ipv4_local_address?(value)
      ip = IPAddr.new(value)
      # 127.0.0.0 - 127.255.255.255 loopback
      # 10.0.0.0 - 10.255.255.255 private
      # 192.168.0.0 - 192.168.255.255 private
      # 172.16.0.0 - 172.31.255.255 private
      # 169.254.0.0 - 169.254.255.255 link-local
      return true if ip.loopback? || ip.private? || ip.link_local?
      return true if ip == '0.0.0.0'          # unknown or non-applicable target
      return true if ip == '255.255.255.255'  # local broadcast

      false
    end

    def domainname_local_address?(value)
      return true unless value.include?('.')

      top_level_domain = value.split('.').last
      return true if LOCAL_TOP_DOMAINS.include?(top_level_domain)

      false
    end
  end
end
