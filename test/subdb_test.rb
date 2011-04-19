require 'test_helper'

class SubdbTest < Test::Unit::TestCase
  TEST_FILES = {
    :dexter => {
      :path => File.expand_path("../fixtures/dexter.mp4", __FILE__),
      :hash => "ffd8d4aa68033dc03d1c8ef373b9028c"
    },

    :justified => {
      :path => File.expand_path("../fixtures/justified.mp4", __FILE__),
      :hash => "edc1981d6459c6111fe36205b4aff6c2"
    }
  }

  def test_initialize_with_invalid_file
    assert_raise(RuntimeError) { Subdb.new("invalid") }
  end

  def test_file_hash
    TEST_FILES.each do |name, file|
      sub = Subdb.new(file[:path])
      assert_equal(file[:hash], sub.hash)
    end
  end
end
