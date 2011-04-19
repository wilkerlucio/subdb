require 'digest/md5'

class Subdb
  VIDEO_EXTENSIONS = ['.avi', '.mkv', '.mp4', '.mov', '.mpg', '.wmv', '.rm', '.rmvb', '.divx']
  SUB_EXTESNIONS   = ['.srt', '.sub']

  attr_reader :hash

  def initialize(path)
    fail "#{@path} is not a file" unless File.exists?(path)

    @path = path
    @hash = build_hash
  end

  protected

  def build_hash
    chunk_size = 64 * 1024

    size = File.size(@path)
    file = File.open(@path, "r")
    data = file.read(chunk_size)
    file.seek(size - chunk_size)
    data += file.read(chunk_size)

    Digest::MD5.hexdigest(data)
  end
end
