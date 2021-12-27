class ModelCustomScheme
  include ActiveModel::Validations

  attr_accessor :url

  validates_url_format_of :url, schemes: ['ftp']
end
