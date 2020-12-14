require 'down'
require 'rexml/document'
require 'zaru'

module Dri::Exporter::BagIt
  class BagItExporter
    include REXML

    attr_reader :export_path, :user_email, :user_token

    BASE_URL = 'https://repository.dri.ie'.freeze

    def initialize(export_path:, user_email:, user_token:)
      @export_path = export_path
      @user_email = user_email
      @user_token = user_token
    end

    def export(object_ids:)
      response = ::Dri::Exporter::DriService.parse(url, object_ids)

      response.each do |r|
        metadata = r['metadata']

        metadata_download = ::Down.download(metadata_url(r['pid']))
        identifier = extract_identifier(metadata_download.path) || r['pid']

        if r['metadata'].key?('doi')
          doi = r['metadata']['doi'].first['url']
        end

        bag_info = {}
        bag_info['Internal-Sender-Identifier'] = identifier
        bag_info['Internal-Sender-Description'] = BASE_URL + '/catalog/' + r['pid']
        bag_info['External-Identifier'] = doi if doi

        filename = identifier ? ::Zaru.sanitize!(identifier) : r['pid']
        base_path = File.join(export_path, filename)
        factory = BagFactory.new(base_path: base_path, bag_info: bag_info)
        if !factory.empty?
          puts "bag already exists for #{identifier} #{r['pid']}"
          next
        end

        factory.add_metadata(metadata_download.path)

        r['files'].each do |file|
          next unless file.key?('masterfile')
          masterfile_download = ::Down.download(file['masterfile'] + "?" + auth_params)

          data_dir = file.key?('preservation') ? 'preservation' : 'data'

          factory.add_data(
            File.join(data_dir, masterfile_download.original_filename),
            masterfile_download.path
          )
        end

        factory.create_bag
      end
    end

    private

    def extract_identifier(metadata_download_path)
      xmlfile = File.new(metadata_download_path)
      xmldoc = Document.new(xmlfile)

      identifier = XPath.match(xmldoc, "//dc:identifier").map {|i| i.text }
      identifier.empty? ? nil : identifier.first
    end

    def metadata_url(id)
      BASE_URL + "/objects/" + id + "/metadata?" + auth_params
    end

    def url
      BASE_URL + "/get_objects.json?" + auth_params + "&preservation=true"
    end

    def auth_params
      "user_email=" + user_email + "&user_token=" + user_token
    end

  end
end
