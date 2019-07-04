class S3UploadPresignedUrlCreator < ApplicationService

  def call
    S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'private')
  end

end
