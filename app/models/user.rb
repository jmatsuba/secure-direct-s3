class User < ApplicationRecord

  ["file1", "file2", 'file3'].each do |file|
    define_method "#{file}_secure_url" do
      aws_key = read_attribute("#{file}_key")
      aws_key.present? ? S3DownloadPresignedUrlCreator.call(aws_key) : nil
    end

    define_method "#{file}_filename" do
      aws_key = read_attribute("#{file}_key")
      aws_key.present? ? S3FilenameParser.call(aws_key) : nil
    end
  end

end
