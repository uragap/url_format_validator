class ModelAllowBlank
  include ActiveModel::Validations

  attr_accessor :url

  validates_url_format_of :url, allow_blank: true
end
