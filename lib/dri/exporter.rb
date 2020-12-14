require 'dri/exporter/version'
require 'csv'

module Dri
  module Exporter
    class Error < StandardError; end
    autoload :DriService, 'dri/exporter/dri_service'
    autoload :BagIt, 'dri/exporter/bagit'

    class << self
      attr_accessor :api_token, :user_email, :output_directory
      attr_writer :id_header

      def config
        yield self
      end

      def id_header
        @id_header || 'Id'
      end

      def export(csv: nil, object_ids: [])
        exporter = Dri::Exporter::BagIt::BagItExporter.new(
          export_path: self.output_directory,
          user_email: self.user_email,
          user_token: self.api_token
        )

        if  csv
          export_csv(csv, exporter)
        elsif !object_ids.empty?
          exporter.export(object_ids: object_ids)
        end
      end

      def export_csv(csv, exporter)
        o_ids = []
        CSV.foreach(csv, headers: true) do |row|
          o_ids << row[id_header]

          if o_ids.length == 20
            exporter.export(object_ids: o_ids)
            o_ids = []
          end
        end

        exporter.export(object_ids: o_ids) unless o_ids.empty?
      end
    end
  end
end
