require "tty-prompt"
require "tty-spinner"

require_relative "gemsearch/version"
require_relative "gemsearch/utils"
require_relative "gemsearch/keys"
require_relative "gemsearch/fetcher"
require_relative "gemsearch/installer"

module Gemsearch
  class Runner
    def initialize(opts = {})
      @query            = ""
      @last_response    = []
      @index            = -1

      @spinner          = opts.fetch(:spinner) { TTY::Spinner.new("[:spinner] Searching") }
      @prompt           = opts.fetch(:prompt) { TTY::Prompt.new }
      @spinner_enabled  = opts.fetch(:spinner_enabled) { true }
      @test_mode        = opts.fetch(:test_mode) { false }
      @exit_string      = opts.fetch(:exit_string) { "exit" }

      @utils            = Utils.new(prompt: @prompt,
                                    spinner: @spinner,
                                    spinner_enabled: @spinner_enabled)
      @fetcher          = Fetcher.new
      @installer        = Installer.new(prompt: @prompt)
    end

    def start
      utils.temp_hide_cursor do
        loop do
          print_prompt
          print_results
          handle_input
          break if test_mode && query == exit_string
        end
      end
    end

    attr_accessor :index

    private

    attr_accessor :query
    attr_accessor :last_response

    attr :spinner
    attr :prompt
    attr :spinner_enabled
    attr :test_mode
    attr :exit_string
    attr :utils
    attr :fetcher
    attr :installer

    def prompt_line
      "📦  " + prompt.decorate("Search:", :bold) + " #{query}\n\n"
    end

    def handle_input
      input = prompt.read_char

      case input
      when /#{Regexp.escape(KEYS[:arrow_up])}|#{Regexp.escape(KEYS[:ctrl_k])}/
        clear_screen
        self.index -= 1 if index > 0
      when /#{Regexp.escape(KEYS[:arrow_down])}|#{Regexp.escape(KEYS[:ctrl_j])}/
        clear_screen
        self.index += 1 if index < last_response.length - 1
      when /#{Regexp.escape(KEYS[:backspace])}/
        handle_backspace
      when /#{Regexp.escape(KEYS[:enter])}/
        handle_enter
      else
        query << input
        clear_screen
      end
    end

    def results
      ([""] * 5).zip(last_response).map do |_, object| 
        if object
          result_line(object)
        else
          "\n"
        end
      end
    end

    def result_line(object)
      "#{utils.humanize_number(object["downloads"])}".ljust(7) +
      "#{utils.remove_special_characters(utils.truncate(object["name"], 23))}".ljust(23) +
      "#{utils.remove_special_characters(utils.truncate(object["info"], 45)).strip}".ljust(45) + 
      "\n"
    end

    def print_results
      results.each_with_index do |r, i|
        selected = i == index
        $stdout.print prompt.decorate("#{selected ? ">" : " "} #{r}", selected ? :bright_blue : :bright_black)
      end
    end

    def print_prompt
      $stdout.print prompt_line
    end

    def clear_screen(n = 1)
      $stdout.print(prompt.clear_lines((prompt_line + results.join).count("\n") + n) + prompt.cursor.clear_screen_down)
    end

    def delete_last_char
      self.query = query[0..-2]
    end

    def handle_backspace
      delete_last_char
      clear_screen
    end

    def handle_enter
      if query.length > 0
        utils.with_spinner do
          self.last_response = fetcher.fetch(query)[0..3]
        end
      else
        install
      end

      after_enter
    end

    def after_enter
      clear_screen(query.length > 0 ? 2 : 1)
      self.query = ""
      self.index = last_response.empty? ? -1 : 0
    end

    def install
      return if last_response.empty?

      installer.install(selected_gem)
    end

    def selected_gem
      last_response[index]
    end
  end
end
