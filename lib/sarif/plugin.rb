# frozen_string_literal: true

require "uri"
require "pathname"

module Danger
  # Danger plugin for reporting SARIF file.
  #
  # @example report from SARIF file
  #
  #          sarif.report 'app/build/reports/lint-results-debug.sarif'
  #
  # @example report from multiple SARIF files
  #
  #          Dir["**/build/reports/lint-results-*.sarif"].each do |file|
  #            sarif.report file
  #          end
  #
  # @see  irgaly/danger-sarif
  # @tags lint, sarif
  #
  class DangerSarif < Plugin
    Warning = Struct.new(:message, :file, :line)

    # Report errors from SARIF file
    #
    # @return [void]
    def report(file, base_dir: nil)
      parse(file, base_dir: base_dir).each do |warning|
        warn(warning.message, file: warning.file, line: warning.line)
      end
    end

    # Parse SARIF file, then return Warnings
    #
    # @return [DangerSarif::Warning]
    def parse(file, base_dir: nil)
      raise "SARIF file was not found: #{file}" unless File.exist? file
      base_dir_path = Pathname.new(base_dir || Dir.pwd)
      json = JSON.parse(File.read(file))
      json["runs"].flat_map do |run|
        base_uris = run["originalUriBaseIds"] || {}
        run["results"].flat_map do |result|
          message = result["message"]["markdown"] || result["message"]["text"]
          result["locations"].map do |location|
            physicalLocation = location["physicalLocation"]
            artifactLocation = physicalLocation["artifactLocation"]
            base_uri = base_uris[artifactLocation["uriBaseId"]]
            uri = artifactLocation["uri"]
            target_uri = if base_uri&.key?("uri") then
              File.join(base_uri["uri"], uri)
            else
              uri
            end
            file = begin
              target_path = Pathname.new(URI.parse(target_uri).path)
              target_path.relative_path_from(base_dir_path).to_s
              rescue ArgumentError
                target_path.to_s
            end
            line = physicalLocation["region"]["startLine"].to_i
            Warning.new(message: message, file: file, line: line)
          end
        end
      end
    end
  end
end
