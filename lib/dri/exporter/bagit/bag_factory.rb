require 'bagit'

module Dri::Exporter::BagIt
  class BagFactory

    attr_reader :bag

    def initialize(base_path:, bag_info: {})
      @bag = ::BagIt::Bag.new base_path
      bag.write_bag_info({ "Source-Organization" => "Digital Repository of Ireland" })
      bag.write_bag_info(bag_info)
    end

    def add_metadata(src_path)
      bag.add_file(File.join('metadata', 'metadata.xml'), src_path)
    end

    def add_data(relative_path, src_path)
      bag.add_file(relative_path, src_path)
    rescue RuntimeError => e
      puts e.message
    end

    def create_bag
      bag.manifest!
    end
  end
end
