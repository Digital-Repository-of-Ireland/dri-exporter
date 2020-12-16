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

      attr_writer :logger

      def logger
        @logger ||= Logger.new($stdout).tap do |log|
          log.progname = self.name
        end
      end

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

        export_csv(csv, exporter) if csv
        exporter.export(object_ids: object_ids) unless object_ids.empty?
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
