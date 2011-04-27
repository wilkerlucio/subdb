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

class SubdbVideoTest < Test::Unit::TestCase
  TEST_FILES = {
    :sample1 => {
      :path => File.expand_path("../../fixtures/sample1.file", __FILE__),
      :hash => "799fe265563e2150ee0e26f1ea0036c2"
    },

    :sample2 => {
      :path => File.expand_path("../../fixtures/sample2.file", __FILE__),
      :hash => "2585d99169ddf3abc5708c638771dc85"
    },

    :dexter => {
      :hash => "ffd8d4aa68033dc03d1c8ef373b9028c"
    },

    :justified => {
      :hash => "edc1981d6459c6111fe36205b4aff6c2"
    }
  }

  TEST_SUB   = "1\n00:00:05,000 --> 00:00:15,000\nAtention: This is a test subtitle.\n \n2 \n00:00:25,000 --> 00:00:40,000\nSubDB - the free subtitle database\nhttp://thesubdb.com\n"
  SAMPLE_SUB = File.expand_path("../../fixtures/sample.srt", __FILE__)
  WRONG_SUB  = File.expand_path("../../fixtures/wrongsub.wro", __FILE__)

  def setup
    Subdb::Video.test_mode = true
  end

  def test_self_api_url
    assert_equal("http://sandbox.thesubdb.com/", Subdb::Video.api_url)

    Subdb::Video.test_mode = false
    assert_equal("http://api.thesubdb.com/", Subdb::Video.api_url)
  end

  def test_initialize_with_invalid_file
    assert_raise(RuntimeError) { Subdb::Video.new("invalid") }
  end

  def test_file_hash
    TEST_FILES.each do |name, file|
      next unless file[:path]

      sub = Subdb::Video.new(file[:path])
      assert_equal(file[:hash], sub.hash)
    end
  end

  def test_file_hash_with_less_than_128_kb
    assert_raise(ArgumentError, "The video file need to have at least 128kb") { Subdb::Video.new(SAMPLE_SUB) }
  end

  def test_search
    sub = Subdb::Video.new(TEST_FILES[:sample1][:path])
    sub.instance_variable_set(:@hash, TEST_FILES[:justified][:hash])

    assert_equal("pt,en", sub.search)
  end

  def test_search_not_found
    sub = Subdb::Video.new(TEST_FILES[:sample1][:path])
    sub.instance_variable_set(:@hash, TEST_FILES[:dexter][:hash])

    assert_equal(nil, sub.search)
  end

  def test_download
    Subdb::Video.test_mode = false
    sub = Subdb::Video.new(TEST_FILES[:sample1][:path])
    sub.instance_variable_set(:@hash, TEST_FILES[:justified][:hash])

    assert_equal(TEST_SUB, sub.download)
  end

  def test_download_not_found
    sub = Subdb::Video.new(TEST_FILES[:sample1][:path])
    sub.instance_variable_set(:@hash, TEST_FILES[:dexter][:hash])

    assert_equal(nil, sub.download)
  end

  def test_download_with_extra_languages
    Subdb::Video.test_mode = false
    sub = Subdb::Video.new(TEST_FILES[:sample1][:path])
    sub.instance_variable_set(:@hash, TEST_FILES[:justified][:hash])

    assert_equal(TEST_SUB, sub.download(["abc", "en"]))
  end

  def test_upload
    sub = Subdb::Video.new(TEST_FILES[:sample1][:path])
    sub.instance_variable_set(:@hash, TEST_FILES[:dexter][:hash])

    assert_equal(true, sub.upload(SAMPLE_SUB))
  end

  def test_upload_invalid
    sub = Subdb::Video.new(TEST_FILES[:sample1][:path])
    sub.instance_variable_set(:@hash, TEST_FILES[:justified][:hash])

    assert_raise(RuntimeError) { sub.upload(WRONG_SUB) }
  end
end
