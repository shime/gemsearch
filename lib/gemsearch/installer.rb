require "bun"

module Gemsearch
  class Installer
    def initialize(opts = {})
      @prompt = opts.fetch(:prompt) { TTY::Prompt.new }
    end

    def install(selected_gem)
      print_install_message(selected_gem)
      Bun.add("#{selected_gem["name"]}:#{selected_gem["version"]}")
      exit
    rescue Bun::Errors::DuplicateGemError
      $stdout.puts prompt.decorate("Gem #{selected_gem["name"]} already present in the Gemfile. Aborting.", :red)
    end

    private

    attr :prompt

    def print_install_message(selected_gem)
      $stdout.puts prompt.decorate("Adding #{selected_gem["name"]} #{selected_gem["version"]} to Gemfile and installing...", :bold)
    end
  end
end
