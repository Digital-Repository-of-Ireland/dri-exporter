require "dri/exporter/version"

module Dri
  module Exporter
    class Error < StandardError; end
    # Your code goes here...
    autoload :DriService, 'dri/exporter/dri_service'
    autoload :BagIt, 'dri/exporter/bagit'
  end
end
