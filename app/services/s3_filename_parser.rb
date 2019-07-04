class S3FilenameParser < ApplicationService
  attr_reader :aws_key

  def initialize(aws_key)
    @aws_key = aws_key
  end

  def call
    aws_key.split('/').last
  end

end
