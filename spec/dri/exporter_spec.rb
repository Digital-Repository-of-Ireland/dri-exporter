RSpec.describe Dri::Exporter do
  it "has a version number" do
    expect(Dri::Exporter::VERSION).not_to be nil
  end

  it 'is possible to provide config options' do
    described_class.config do |c|
      expect(c).to eq(described_class)
    end
  end

  describe 'parameters' do
    let(:fake_class) { class_double('Dri::Exporter') }
    it 'is possible to set api_token' do
      expect(fake_class).to receive(:api_token=).with('123.abc')
      fake_class.api_token = '123.abc'
    end
    it 'is possible to set user_email' do
      expect(fake_class).to receive(:user_email=).with('test@example.com')
      fake_class.user_email = 'test@example.com'
    end
    it 'is possible to set output directory' do
      expect(fake_class).to receive(:output_directory=).with('/tmp')
      fake_class.output_directory = '/tmp'
    end
    it 'is possible to set id header' do
      expect(fake_class).to receive(:id_header=).with('pid')
      fake_class.id_header = 'pid'
    end
    it 'id header should have a default' do
      expect(Dri::Exporter.id_header).to eq 'Id'
    end
  end

  describe 'export' do
    let(:fake_class) { class_double('Dri::Exporter') }

    it 'should accept a list of object ids' do
      expect(fake_class).to receive(:export).with(object_ids: ['test'])
      fake_class.export(object_ids: ['test'])
    end

    it 'should call export with a list of object ids' do
      expect_any_instance_of(Dri::Exporter::BagIt::BagItExporter).to receive(:export).with(object_ids: ['test'])
      described_class.config do |c|
        c.api_token = '123'
        c.user_email = 'test@example.com'
        c.output_directory = '/tmp'
      end

      described_class.export(object_ids: ['test'])
    end

    it 'should call export with a list of ids from csv' do
      expect_any_instance_of(Dri::Exporter::BagIt::BagItExporter).to receive(:export).twice
      described_class.config do |c|
        c.api_token = '123'
        c.user_email = 'test@example.com'
        c.output_directory = '/tmp'
      end

      tmpfile = Tempfile.new
      CSV.open(tmpfile, "w") do |csv|
        csv << ['Id']

        30.downto(0){ |i| csv << ["test#{i}"] }
      end
      described_class.export(csv: tmpfile.path)
    end
  end
end
