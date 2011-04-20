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

module Subdb::ClientUtils
  VIDEO_EXTENSIONS = ['.avi', '.mkv', '.mp4', '.mov', '.mpg', '.wmv', '.rm', '.rmvb', '.divx']
  SUB_EXTESNIONS   = ['.srt', '.sub']

  class << self
    def scan_paths(paths)
      video_ext = VIDEO_EXTENSIONS.join(",")

      paths.inject([]) do |files, path|
        if File.directory?(path)
          path = path.chomp("/")
          files = files.concat(Dir.glob("#{path}/**/*{#{video_ext}}"))
        else
          files << path if VIDEO_EXTENSIONS.include?(File.extname(path))
        end

        files
      end.sort
    end

    def sync(paths, languages = ["en"])
      i = 0

      for path in paths
        base = File.dirname(path) + "/" + File.basename(path, File.extname(path))
        sub  = find_subtitle(path)

        yield :scan, [path, i]

        begin
          subdb  = Subdb.new(path)

          yield :scanned, subdb

          remote = subdb.search

          yield :remote, remote

          if sub and !remote
            yield :uploading, subdb

            begin
              subdb.upload(sub)
              yield :upload_ok, subdb
            rescue
              yield :upload_failed, [subdb, $!]
            end
          end

          if !sub and remote
            yield :downloading, subdb

            begin
              downloaded = subdb.download(languages)

              if downloaded
                File.open(base + ".srt", "w") do |f|
                  f << downloaded
                end

                yield :download_ok, subdb
              else
                yield :download_not_found, subdb
              end
            rescue
              yield :download_failed, [subdb, $!]
            end
          end
        rescue
          yield :scan_failed, $!
        end

        i += 1

        yield :file_done, [subdb, i]
      end
    end

    def find_subtitle(path)
      base = File.dirname(path) + "/" + File.basename(path, File.extname(path))

      for subext in SUB_EXTESNIONS
        subpath = base + subext

        return subpath if File.exists?(subpath)
      end

      nil
    end
  end
end
