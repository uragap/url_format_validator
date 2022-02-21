require 'rspec'
require 'active_record'
require 'validates_url_format'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(
    'adapter' => 'sqlite3',
    'database' => ':memory:'
)

autoload :Model,                          'models/model'
autoload :ModelNoLocal,                   'models/model_no_local'
autoload :ModelAllowBlank,                'models/model_allow_blank'
autoload :ModelAllowNil,                  'models/model_allow_nil'
autoload :ModelCustomScheme,              'models/model_custom_scheme'
autoload :ModelPublicSuffix,              'models/model_public_suffix'
autoload :ModelOnCreate,                  'models/model_on_create'

RSpec.configure(&:disable_monkey_patching!)
