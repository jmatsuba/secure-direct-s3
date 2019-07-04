class S3DownloadPresignedUrlCreator < ApplicationService
  attr_reader :aws_key

  def initialize(aws_key)
    @aws_key = aws_key
  end

  def call
    S3_BUCKET.object(aws_key).presigned_url(:get)
  end

end
