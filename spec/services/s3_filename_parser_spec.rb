RSpec.describe 'S3FilenameParser' do

  context 'with a valid s3 key (path)' do
    it 'should parse the file name' do
      file_name = S3FilenameParser.call('uploads/0faa97a8-3bbc-4173-aade-f089480670a4/test.jpg')
      expect(file_name).to eq('test.jpg')
    end
  end

  context 'with a blank s3 key' do
    it 'should raise a ArguementError' do
      expect { S3FilenameParser.call('') }.to raise_error(ArgumentError)
    end

    it 'should raise a ArguementError' do
      expect { S3FilenameParser.call(nil) }.to raise_error(ArgumentError)
    end
  end

  context 'with a no s3 key' do
    it 'should raise a ArguementError' do
      expect { S3FilenameParser.call() }.to raise_error(ArgumentError)
    end
  end

end
