class ModelOnCreate
  include ActiveModel::Validations

  attr_accessor :url

  validates_url_format_of :url, on: :create
end
