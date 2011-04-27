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

require 'subdb'
require 'java'
require 'javalib/filedrop.jar'

import java.awt.BorderLayout
import java.awt.Color
import java.awt.Dimension
import java.awt.image.BufferedImage
import javax.imageio.ImageIO
import javax.swing.BorderFactory
import javax.swing.JLabel
import javax.swing.JFrame
import javax.swing.JPanel
import javax.swing.JProgressBar
import javax.swing.JScrollPane
import javax.swing.JTextArea
import javax.swing.SwingConstants
import javax.swing.UIManager

begin
  import com.apple.eawt.Application
  import com.apple.eawt.AppEventListener
  import com.apple.eawt.OpenFilesHandler
rescue
  # just fake classes
  class Application
    def self.getApplication
      self.new
    end

    def addApplicationListener(listener)

    end
  end

  module AppEventListener

  end

  module OpenFilesHandler

  end
end

include_class java.lang.System
include_class Java::FileDrop

module Subdb
  module UI
    class Swing < JFrame
      include FileDrop::Listener
      include AppEventListener
      include OpenFilesHandler

      def initialize
        super "SubDB Sync"

        @uploading = false

        app = Application.getApplication
        app.addAppEventListener(self)
        app.setOpenFileHandler(self)

        self.init_ui
      end

      def init_ui
        begin
          icon = ImageIO.read(getClass.getResource("images/subdb128.png"))
          set_icon_image icon
        rescue
        end

        border_size = 1

        @dropper = JPanel.new
        @dropper.set_border BorderFactory.createCompoundBorder(BorderFactory.createEmptyBorder(border_size, border_size, border_size, border_size), BorderFactory.createLineBorder(Color.black))

        @progress = JProgressBar.new(0, 100)
        @progress.set_string_painted true

        hint = JLabel.new("Arraste suas pastas ou arquivos com videos aqui.", SwingConstants::CENTER)
        hint.set_preferred_size Dimension.new(500, 60)

        @dropper.add(hint, BorderLayout::CENTER)

        @log = JTextArea.new
        @log.set_editable false

        @scroller = JScrollPane.new(@log)

        content_pane.add(@dropper, BorderLayout::NORTH)
        content_pane.add(@scroller, BorderLayout::CENTER)
        content_pane.add(@progress, BorderLayout::SOUTH)

        FileDrop.new(nil, @dropper, self)

        set_size 800, 300
        set_resizable true
        set_default_close_operation JFrame::EXIT_ON_CLOSE
        set_location_relative_to nil
        set_visible true
      end

      def openFiles(e)
        filesDropped(e.getFiles)
      end

      def filesDropped(files)
        return if @uploading

        files = files.map { |f| f.to_s }

        @uploading = true

        Thread.new do
          @progress.set_indeterminate true

          log "Gerando lista de arquivos..."

          files = Subdb::ClientUtils.scan_paths(files) do |path|
            log "Escaneando #{path}..."
          end

          log "Finalizado, #{files.length} arquivos para escanear."
          log_separator

          @progress.set_indeterminate false
          @progress.set_maximum files.length

          results = Subdb::ClientUtils.sync files, ["pt", "en"] do |action, arg|
            case action
            when :loading_cache      then log "Carregando cache de legendas enviadas..."
            when :scan               then log "Abrindo #{arg[0]}..."
            when :scanned            then log "Verificando #{arg.pathbase} [#{arg.hash}]..."
            when :uploading          then log "Enviando legenda local para o servidor..."
            when :upload_failed      then error "Erro ao enviar legenda #{arg[0]}: #{arg[1]}"
            when :downloading        then log "Procurando legenda no servidor..."
            when :download_ok        then log "Legenda baixada com sucesso: #{arg[1]}"
            when :download_not_found then log "Nenhuma legenda encontrada no seu idioma"
            when :download_failed    then error "Erro ao tentar baixar #{arg[0].path}: #{arg[1]}"
            when :scan_failed        then error "Erro ao abrir arquivo #{arg[0]}: #{arg[1]}"
            when :storing_cache      then log "Salvando cache de legendas enviadas..."
            when :file_done
              log "Concluido #{arg[0].path}"
              log_separator
              @progress.set_value arg[1]
            end
          end

          log "Concluido"
          log_separator

          if results[:download].length > 0
            log "Legendas baixadas:"
            results[:download].each { |s| log s }
            log_separator
          end

          log "#{results[:download].length} legendas baixadas"
          log "#{results[:upload].length} legendas enviadas"
          log_separator

          @uploading = false
        end
      end

      def log(msg)
        @log.append msg + "\n"

        sleep 0.1

        scroll = @scroller.vertical_scroll_bar
        scroll.value = scroll.maximum if scroll.value > scroll.maximum - (@scroller.height + 30)

        puts msg
      end

      def log_separator
        log "------------------------------"
      end

      def error(msg)
        log msg
      end
    end
  end
end

# try use system look and feel
begin
  UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
rescue
  # no lucky...
end

# start application
Subdb::UI::Swing.new
