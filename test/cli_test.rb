require "test_helper"

class FakeCursor
  def clear_screen_down; "" end
  def clear_line; "" end
end

class FakePrompt
  def initialize(input)
    @input = StringIO.new(input)
    @cursor = FakeCursor.new
  end
  attr :cursor
  attr :output
  def read_char
    @input.getc
  end
  def show; end
  def hide; end

  def print(*args); $stdout.print(*args); end
  def decorate(output, color); output; end
  def clear_lines(n); "" end
end

class GemsearchTest < Minitest::Test
  def test_search
    runner = Gemsearch::Runner.new(spinner_enabled: false,
                                   test_mode: true,
                                   prompt: FakePrompt.new("sinatra\rexit"))
    assert_output />.*sinatra.*sinatra-contrib.*sinatra-activerecor\.\.\..*sinatra-partial/m do
      runner.start
    end
  end
end
