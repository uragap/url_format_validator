require 'active_model'
require 'validates_url_format/validator'

module ActiveModel
  module Validations
    class UrlFormatValidator < ActiveModel::EachValidator
      DEFAULT_MESSAGES = {
        valid_url: 'is a valid URL',
        invalid_url: 'is not a valid URL',
        nil_or_blank_url: 'is nil or blank URL',
        invalid_scheme: 'a URL has invalid scheme',
        invalid_userinfo: 'a URL has invalid user info',
        local_url: 'is a local URL',
        space_symbol: 'a URL has space symbol',
        public_suffix: 'a URL is invalid by public suffix'
      }
      DEFAULT_SCHEMES = %w(http https)

      def initialize(options)
        options.reverse_merge!(messages: DEFAULT_MESSAGES, no_local: false, public_suffix: false)

        super(options)
      end

      def validate_each(record, attribute, value)
        return record.errors.add(attribute, options.dig(:messages, :valid), value: value) unless value.is_a?(String)

        is_valid, message = ValidatesUrlFormat::Validator.new.valid?(value, options)
        record.errors.add(attribute, options.dig(:messages, message), value: value) unless is_valid
      end
    end

    module ClassMethods
      # Validates whether the value of the specified attribute is valid url.
      #
      #  class Model
      #    include ActiveModel::Validations
      #    validates_url_format_of :homepage, allow_blank: true, schemes: ['ftp']
      #  end
      #
      # Configuration options:
      #   :messages - A custom error messages (default is: 'is not a valid URL').
      #   :allow_nil - If set to true, skips this validation if the attribute is nil (default is false).
      #   :allow_blank - If set to true, skips this validation if the attribute is blank (default is false).
      #   :schemes - Array of URI schemes to validate against. (default is ['http', 'https'])
      #   :public_suffix - If set to true, validates domain name by public suffix. (default is false)
      #   :no_local - If set to true, filtrates local adresses. (default is false)

      def validates_url_format_of(*attr_names)
        validates_with UrlFormatValidator, _merge_attributes(attr_names)
      end
    end
  end
end
