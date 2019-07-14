RSpec.describe 'S3DownloadPresignedUrlCreator' do

  context 'with a s3 key (path)' do
    it 'should return a secure url' do
      expect(S3DownloadPresignedUrlCreator.call('uploads/0faa97a8-3bbc-4173-aade-f089480670a4/test.jpg')).to include("Amz-Credential", "Amz-Signature")
    end
  end

  context 'with a blank s3 key' do
    it 'should raise a ArguementError' do
      expect { S3DownloadPresignedUrlCreator.call('') }.to raise_error(ArgumentError)
    end

    it 'should raise a ArguementError' do
      expect { S3DownloadPresignedUrlCreator.call(nil) }.to raise_error(ArgumentError)
    end
  end

end
