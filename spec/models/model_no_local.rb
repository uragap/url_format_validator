class ModelNoLocal
  include ActiveModel::Validations

  attr_accessor :url

  validates_url_format_of :url, no_local: true
end
