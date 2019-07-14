RSpec.describe 'S3UploadPresignedUrlCreator' do

  context 'when called' do
    it 'should return a Presigned Post object' do
      expect(S3UploadPresignedUrlCreator.call()).to be_kind_of(Aws::S3::PresignedPost)
    end

    it 'acl should be set to private' do
      expect(S3UploadPresignedUrlCreator.call().fields['acl']).to eq('private')
    end

    it 'success_action_status should be set to 201' do
      expect(S3UploadPresignedUrlCreator.call().fields['success_action_status']).to eq('201')
    end

  end

end
