require 'tmpdir'

RSpec.describe Dri::Exporter::BagIt::BagItExporter do

  describe 'export' do
    let(:service_output) do
      [
        {
          'pid' => 'test123',
          'metadata' => {
            "doi"=>[
              {"created_at"=>"2020-11-03T14:46:05.000Z",
                "version"=>0,
                "url"=>"https://doi.org/10.7486/test123"
              }
            ]
          },
          'files' => [
            { 'masterfile'=>'https://example.com/data.jpg' },
            { 'masterfile'=>'https://example.com/preservation_data.pdf', 'preservation'=>true }
          ]
        }
      ]
    end

    let(:output_directory) { Dir.mktmpdir }

    before(:each) do
      allow(Dri::Exporter::DriService).to receive(:parse).and_return(service_output)
      allow(Down).to receive(:download).
        with('https://repository.dri.ie/objects/test123/metadata?user_email=user@example.com&user_token=123').
        and_return(OpenStruct.new({ path: fixture_path('metadata.xml') }))
      allow(Down).to receive(:download).
        with('https://example.com/data.jpg?user_email=user@example.com&user_token=123').
        and_return(OpenStruct.new({ path: fixture_path('data.jpg'), original_filename: 'data.jpg' }))
      allow(Down).to receive(:download).
        with('https://example.com/preservation_data.pdf?user_email=user@example.com&user_token=123').
        and_return(OpenStruct.new({ path: fixture_path('preservation_data.pdf'), original_filename: 'preservation_data.pdf' }))
    end

    it 'should export a bag with identifier' do
      described_class.new(
        export_path: output_directory,
        user_email: 'user@example.com',
        user_token: '123'
      ).export(object_ids: ['test123'])

      expect(BagIt::Bag.new(File.join(output_directory, '1232')).valid?).to be true
    end

    it 'should export a bag using pid if no identifier' do
      allow(Down).to receive(:download).
        with('https://repository.dri.ie/objects/test123/metadata?user_email=user@example.com&user_token=123').
        and_return(OpenStruct.new({ path: fixture_path('metadata-noident.xml') }))

      described_class.new(
        export_path: output_directory,
        user_email: 'user@example.com',
        user_token: '123'
      ).export(object_ids: ['test123'])

      expect(BagIt::Bag.new(File.join(output_directory, 'test123')).valid?).to be true
    end

    it 'should add the DOI to the bag info' do
      described_class.new(
        export_path: output_directory,
        user_email: 'user@example.com',
        user_token: '123'
      ).export(object_ids: ['test123'])

      bag = BagIt::Bag.new(File.join(output_directory, '1232'))
      expect(bag.bag_info['External-Identifier']).to eq "https://doi.org/10.7486/test123"
    end
  end
end
