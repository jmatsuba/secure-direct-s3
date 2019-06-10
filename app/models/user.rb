class User < ApplicationRecord

  ["file1", "file2", 'file3'].each do |file|
    define_method "#{file}_secure_url" do
      secure_aws_url(read_attribute("#{file}_key"))
    end

    define_method "#{file}_filename" do
      parse_filename(read_attribute("#{file}_key"))
    end
  end

  private

  def secure_aws_url(key)
    key.present? ? S3_BUCKET.object(key).presigned_url(:get) : nil
  end

  def parse_filename(key)
    key.present? ? key.split('/').last : nil
  end
end
