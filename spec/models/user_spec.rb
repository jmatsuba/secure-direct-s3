require 'rails_helper'

RSpec.describe User, type: :model do
  before(:example) do
    @user = User.new
  end

  context 'with a file1 s3 key (path)' do
    before(:example) do
      @user.file1_key = 'uploads/0faa97a8-3bbc-4173-aade-f089480670a4/test.jpg'
    end

    it 'should parse the file name' do
      expect(@user.file1_filename).to eq('test.jpg')
    end

    it 'should have a secure download link' do
      expect(@user.file1_secure_url).to include("Amz-Credential", "Amz-Signature")
    end
  end

  context 'without a file1 s3 key (path)' do
    it 'should parse the file name' do
      expect(@user.file1_filename).to be_nil
    end

    it 'should have a secure download link' do
      expect(@user.file1_secure_url).to be_nil
    end
  end

end
