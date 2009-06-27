require 'erb'
require 'nono/config'
require 'nono/out'
module Nono
  class HTMLOut
    include Out
    def initialize(file, css_colors, plate)
      @file = file
      @plate = plate
      @css_colors = css_colors
      if @css_colors.empty?
        @css_colors = [Config::DEFAULT_COLOR_CSS]
      end

      @yhint_html = create_yhint_html
      @xhint_html = create_xhint_html
    end

    def to_color_for_html(cell)
      if cell.fixed?
        if cell.blank?
          "<td>&nbsp;</td>"
        else
          "<td class=\"#{cell.color}\">&nbsp;</td>"
        end
      else
        "<td>?</td>"
      end
    end

    def display
      xhint_size = xhint_max_size
      td_color_style = ""
      @css_colors.each do |color|
        id, col = color.split(/=/)
        td_color_style += "td.H#{id} {color: #{col};}\n"
        td_color_style += "td.#{id} {background-color: #{col};}\n"
      end

      answer = @yhint_html.join("\n")
      answer += "\n"

      @plate.height.times do |y|
        answer += "<tr>"
        answer += @xhint_html[y]
        bar = @plate.ansbars[y]
        bar.cells.each do |cell|
          answer += to_color_for_html(cell)
        end
        answer += "</tr>"
      end

      msg = create_msg
      erb = ERB.new(Config::HTML_TEMPLATE)
      html = erb.result(binding)

      open(html_file_name, "w") {|ofs|
        ofs.puts html
      }
    end

    def html_file_name
      File.basename(@file) + ".ans.html"
    end

    def create_yhint_html
      str = []
      yhint_size = yhint_max_size
      xhint_size = xhint_max_size
      yhint_size.times do |i|
        buf = ""
        xhint_size.times do |j|
          buf += "<td class=\"SP\">&nbsp;</td>"
        end
        @plate.width.times do |x|
          yhint = @plate.yhints[x]
          keys = yhint.keys
          if keys.size >= yhint_size - i
            j = keys.size - yhint_size + i
            buf += "<td align=\"center\" class=\"H#{keys[j].color}\">#{keys[j].length}</td>"
          else
            buf += "<td>&nbsp;</td>"
          end
        end
        str.push "<tr>#{buf}</tr>"
      end
      str
    end

    def create_xhint_html
      strs = []
      xhint_size = xhint_max_size
      @plate.height.times do |y|
        buf = ""
        hint = @plate.xhints[y]
        l = hint.keys.collect {|key|
          "<td align=\"center\" class=\"H#{key.color}\">#{key.length}</td>"
        }.join("")
        (xhint_size - hint.size).times do |i|
          buf += "<td>&nbsp;</td>"
        end
        buf += l
        strs.push(buf)
      end
      strs
    end

  end
end

