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

module Subdb
  module ClientUtils
    VIDEO_EXTENSIONS = ['.avi', '.mkv', '.mp4', '.mov', '.mpg', '.wmv', '.rm', '.rmvb', '.divx']
    SUB_EXTESNIONS   = ['.srt', '.sub']

    class << self
      def scan_paths(paths)
        video_ext = VIDEO_EXTENSIONS.join(",")

        files = []

        for path in paths
          if File.directory?(path)
            path = path.chomp(File::SEPARATOR)
            globpath = "#{path.gsub("\\", "/")}/**/*{#{video_ext}}"

            yield globpath if block_given?

            files = files.concat(Dir.glob(globpath))
          else
            files << path if VIDEO_EXTENSIONS.include?(File.extname(path))
          end
        end

        files.sort
      end

      def sync(paths, languages = ["en"])
        yield :loading_cache
        cache = Subdb::UploadCache.new(cache_file_path)

        results = {:download => [], :upload => []}
        i = 0

        for path in paths
          base = File.dirname(path) + File::SEPARATOR + File.basename(path, File.extname(path))
          sub  = find_subtitle(path)

          yield :scan, [path, i]

          begin
            video = Video.new(path)

            yield :scanned, video

            if sub and !cache.uploaded?(video.hash, sub)
              yield :uploading, video

              begin
                video.upload(sub)
                cache.push(video.hash, sub)
                results[:upload].push(sub)
                yield :upload_ok, video
              rescue
                yield :upload_failed, [video, $!]
              end
            end

            if !sub
              yield :downloading, video

              begin
                downloaded = video.download(languages)

                if downloaded
                  sub = base + ".srt"

                  File.open(sub, "wb") do |f|
                    f << downloaded
                  end

                  cache.push(video.hash, sub)
                  results[:download].push(sub)
                  yield :download_ok, [video, sub]
                else
                  yield :download_not_found, video
                end
              rescue
                yield :download_failed, [video, $!]
              end
            end
          rescue
            yield :scan_failed, path, $!
          end

          i += 1

          yield :file_done, [video, i]
        end

        yield :storing_cache
        cache.store!

        results
      end

      def find_subtitle(path)
        base = File.dirname(path) + File::SEPARATOR + File.basename(path, File.extname(path))

        for subext in SUB_EXTESNIONS
          subpath = base + subext

          return subpath if File.exists?(subpath)
        end

        nil
      end

      def cache_file_path
        File.join((ENV["HOME"] || ENV["USERPROFILE"]), ".subdb_cache")
      end
    end
  end
end
