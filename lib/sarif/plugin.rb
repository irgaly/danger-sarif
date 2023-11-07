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
  #          Dir['**/build/reports/lint-results-*.sarif'].each do |file|
  #            sarif.report file
  #          end
  #
  # @see  irgaly/danger-sarif
  # @tags lint, sarif
  #
  class DangerSarif < Plugin
    Warning = Struct.new(:message, :file, :line)
    Error = Struct.new(:message, :file, :line)

    def initialize(dangerfile)
      super(dangerfile)
      @fail_on_error = true
    end

    # Set the behavior that treating error as fail or not
    #
    # @param [bool] true: treat error as fail, false: treat error as warning
    # @return [void]
    def fail_on_error(value)
      @fail_on_error = value
    end

    # Report errors from SARIF file
    #
    # @return [void]
    def report(file, base_dir: nil)
      parse(file, base_dir: base_dir).each do |result|
        if @fail_on_error && result.instance_of?(Error) then
          warn(result.message, file: result.file, line: result.line)
        else
          fail(result.message, file: result.file, line: result.line)
        end
      end
    end

    # Parse SARIF file, then return Array of DangerSarif::Warning or DangerSarif::Error
    #
    # @return [Array] Array of DangerSarif::Warning or DangerSarif::Error
    def parse(file, base_dir: nil)
      raise "SARIF file was not found: #{file}" unless File.exist? file
      base_dir_path = Pathname.new(base_dir || Dir.pwd)
      json = JSON.parse(File.read(file))
      json["runs"].flat_map do |run|
        base_uris = run["originalUriBaseIds"] || {}
        tool = run["tool"]
        rules = {}
        tool["driver"]["rules"]&.each do |rule|
          rules[rule["id"]] = rule
        end
        tool["extensions"]&.each do |extension|
          extension["rules"]&.each do |rule|
            rules[rule["id"]] = rule
          end
        end
        run["results"].flat_map do |result|
          message = result["message"]["markdown"] || result["message"]["text"]
          rule_id = result["ruleId"]
          rule = rules[rule_id]
          level = result["level"]
          if !level then
            level = (rule["defaultConfiguration"] || {})["level"]
          end
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
            if level == "error" then
              Error.new(message: message, file: file, line: line)
            else
              Warning.new(message: message, file: file, line: line)
            end
          end
        end
      end
    end
  end
end
