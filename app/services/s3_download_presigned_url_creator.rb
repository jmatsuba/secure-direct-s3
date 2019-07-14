class S3DownloadPresignedUrlCreator < ApplicationService
  attr_reader :s3_key

  def initialize(s3_key)
    raise ArgumentError, 's3 path required' if s3_key.blank?
    @s3_key = s3_key
  end

  def call
    S3_BUCKET.object(s3_key).presigned_url(:get)
  end

end
