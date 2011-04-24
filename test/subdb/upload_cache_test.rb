# Copyright (c) 2011 Wilker Lúcio
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'test_helper'

class SubdbUploadCacheTest < Test::Unit::TestCase
  BLANK       = File.expand_path("../../fixtures/blank.data", __FILE__)
  PREDATA     = File.expand_path("../../fixtures/predata.data", __FILE__)
  SAMPLE_SUB  = File.expand_path("../../fixtures/sample.srt", __FILE__)
  SAMPLE_SUB2 = File.expand_path("../../fixtures/sample2.srt", __FILE__)

  UploadCache = Subdb::UploadCache

  def setup
    File.delete(BLANK) if File.exists?(BLANK)
  end

  def test_initialize_with_blank_file
    cache = UploadCache.new(BLANK)
    assert_equal({}, cache.hash)
    assert_equal(BLANK, cache.path)
  end

  def test_initialize_with_file_containing_data
    File.open(PREDATA, "wb") do |file|
      hash = {"1234567890" => ["321", "123"], "0987654321" => ["abc"]}
      file << Marshal.dump(hash)
    end

    cache = UploadCache.new(PREDATA)

    assert_equal(2, cache.hash.length)
    assert_equal("321", cache.hash["1234567890"][0])
    assert_equal("123", cache.hash["1234567890"][1])
    assert_equal("abc", cache.hash["0987654321"][0])
  end

  def test_initialize_with_corrupt_file
    File.open(PREDATA, "wb") do |file|
      file << "abc"
    end

    cache = UploadCache.new(PREDATA)

    assert_equal({}, cache.hash)
  end

  def test_generate_hash_for_subtitle
    hash = UploadCache.subtitle_hash(SAMPLE_SUB)

    assert_equal("deab9d28c488cff5d6fda8265c763e04da89ffa5", hash)
  end

  def test_check_if_subtitle_was_uploaded
    File.open(PREDATA, "wb") do |file|
      hash = {"1234567890" => ["deab9d28c488cff5d6fda8265c763e04da89ffa5"]}
      file << Marshal.dump(hash)
    end

    cache = UploadCache.new(PREDATA)

    assert cache.uploaded?("1234567890", SAMPLE_SUB)
  end

  def test_check_if_subtitle_was_not_uploaded
    cache = UploadCache.new(BLANK)

    assert !cache.uploaded?("1234567890", SAMPLE_SUB)
  end

  def test_push_uploaded_subtitle
    cache = UploadCache.new(BLANK)

    cache.push("abc", SAMPLE_SUB)
    assert_equal({"abc" => ["deab9d28c488cff5d6fda8265c763e04da89ffa5"]}, cache.hash)

    cache.push("abc", SAMPLE_SUB)
    assert_equal({"abc" => ["deab9d28c488cff5d6fda8265c763e04da89ffa5"]}, cache.hash)

    cache.push("abc", SAMPLE_SUB2)
    assert_equal({"abc" => ["deab9d28c488cff5d6fda8265c763e04da89ffa5", "7cbd39f81dc80d65ffd9ee24f6839991768188c8"]}, cache.hash)
  end

  def test_number_of_uploaded_versions_for_a_hash
    cache = UploadCache.new(BLANK)

    assert_equal(0, cache.versions("abc"))

    cache.push("abc", SAMPLE_SUB)
    assert_equal(1, cache.versions("abc"))

    cache.push("abc", SAMPLE_SUB2)
    assert_equal(2, cache.versions("abc"))
  end

  def test_store
    cache = UploadCache.new(BLANK)
    cache.push("abc", SAMPLE_SUB)
    cache.store!

    cache = UploadCache.new(BLANK)
    assert_equal({"abc" => ["deab9d28c488cff5d6fda8265c763e04da89ffa5"]}, cache.hash)
  end
end
