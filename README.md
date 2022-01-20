# ValidatesUrlFormat

This gem helps to validate URLs using ActiveModel.

## Installation

Add this to your `Gemfile`:

```ruby
gem 'validates_url_format'
```
And then execute:

```sh
bundle install
```

Or install it yourself:

```sh
gem install validates_url_format
```

## Usage

### With ActiveRecord
```ruby
class Model < ActiveRecord::Base
  attr_accessor :url, :second_url

  validates_url_format_of :url, allow_blank: true
  validates :second_url, url_format: { allow_blank: true }
end
```

### With ActiveModel

```ruby
class Model
  include ActiveModel::Validations

  attr_accessor :url

  validates_url_format_of :url, allow_blank: true
end
```

Configuration options:
- :messages - A custom error messages hash. Default is:
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
- :allow_nil - If set to true, skips this validation if the attribute is nil (default is false).
- :allow_blank - If set to true, skips this validation if the attribute is blank (default is false).
- :schemes - Array of URI schemes to validate against. (default is ['http', 'https'])
- :public_suffix - If set to true, validates domain name by public suffix. (default is false)
- :no_local - If set to true, filtrates local adresses. (default is false)

### Plain Ruby

```ruby
ValidatesUrlFormat::Validator.new(options).validate(value)
```
Returns hash { is_valid: (true or false), message:  message_symbol }
Message symbols: :valid_url, :invalid_url, :nil_or_blank_url, :invalid_scheme,
                 :invalid_userinfo, :local_url, :space_symbol, :public_suffix
Options:
- :schemes - Array of URI schemes to validate against. (default is ['http', 'https'])
- :public_suffix - If set to true, validates domain name by public suffix. (default is false)
- :no_local - If set to true, filtrates local adresses. (default is false)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/validates_url_format.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
