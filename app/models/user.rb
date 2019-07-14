class User < ApplicationRecord

  ["file1", "file2", 'file3'].each do |file|
    define_method "#{file}_secure_url" do
      s3_key = read_attribute("#{file}_key")
      s3_key.present? ? S3DownloadPresignedUrlCreator.call(s3_key) : nil
    end

    define_method "#{file}_filename" do
      s3_key = read_attribute("#{file}_key")
      s3_key.present? ? S3FilenameParser.call(s3_key) : nil
    end
  end

end
