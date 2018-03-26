require "humanize-number"

module Gemsearch
  class Utils
    def initialize(opts = {})
      @prompt          = opts.fetch(:prompt) { TTY::Prompt.new }
      @spinner_enabled = opts.fetch(:spinner_enabled) { true } 
      @spinner         = opts.fetch(:spinner)
    end

    def humanize_number(n)
      HumanizeNumber.humanize(n)
    end

    def remove_special_characters(string)
      string.gsub(/[\n\t\r]/, '')
    end

    def truncate(text, n)
      text.gsub(/^(.{#{n - 4},}?).*$/m,'\1...')
    end

    def temp_hide_cursor
      hide_cursor
      yield
    rescue TTY::Reader::InputInterrupt, Interrupt
      exit
    ensure
      show_cursor
    end

    def with_spinner
      spinner.auto_spin if spinner_enabled
      yield
      spinner.stop if spinner_enabled
    end

    private

    attr :prompt
    attr :spinner_enabled
    attr :spinner

    def hide_cursor
      $stdout.print(prompt.hide)
    end

    def show_cursor
      $stdout.print(prompt.show)
    end
  end
end
