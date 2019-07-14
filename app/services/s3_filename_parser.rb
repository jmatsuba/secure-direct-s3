class S3FilenameParser < ApplicationService
  attr_reader :s3_key

  def initialize(s3_key)
    raise ArgumentError, 's3 path required' if s3_key.blank?
    @s3_key = s3_key
  end

  def call
    s3_key.split('/').last
  end

end
