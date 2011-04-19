# Copyright (c) 2011 Wilker Lucio da Silva
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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

  TEST_SUB = "1\n00:00:05,000 --> 00:00:15,000\nAtention: This is a test subtitle.\n \n2 \n00:00:25,000 --> 00:00:40,000\nSubDB - the free subtitle database\nhttp://thesubdb.com\n"

  def setup
    Subdb.test_mode = true
  end

  def test_self_api_url
    assert_equal("http://sandbox.thesubdb.com/", Subdb.api_url)

    Subdb.test_mode = false
    assert_equal("http://api.thesubdb.com/", Subdb.api_url)
  end

  def test_initialize_with_invalid_file
    assert_raise(RuntimeError) { Subdb.new("invalid") }
  end

  def test_file_hash
    TEST_FILES.each do |name, file|
      sub = Subdb.new(file[:path])
      assert_equal(file[:hash], sub.hash)
    end
  end

  def test_search
    sub = Subdb.new(TEST_FILES[:justified][:path])

    assert_equal("pt,en", sub.search)
  end

  def test_download
    sub = Subdb.new(TEST_FILES[:justified][:path])

    assert_equal(TEST_SUB, sub.download)
  end
end
