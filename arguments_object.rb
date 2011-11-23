require "builder"

class Drawing
  class Line
    def initialize(point1, point2)
      @x1, @y1 = point1
      @x2, @y2 = point2
    end

    attr_reader :x1, :y1, :x2, :y2
  end

  class Style
    def initialize(params)
      @stroke_width  = params.fetch(:stroke_width)
      @stroke_color  = params.fetch(:stroke_color)
    end

    attr_reader :stroke_width, :stroke_color
  end

  def initialize(width, height)
    @width  = width
    @height = height

    @lines  = []
  end

  def line(coords, style)
    @lines << { :x1 => coords.x1.to_s, :y1 => coords.y1.to_s, 
                :x2 => coords.x2.to_s, :y2 => coords.y2.to_s,
                :stroke => style.stroke_color, :"stroke-width" => style.stroke_width } 
  end

  attr_reader :width, :height, :lines

  def to_svg
    builder = Builder::XmlMarkup.new(:indent => 2)
    builder.instruct!
    builder.declare!(:DOCTYPE, :svg, :PUBLIC, "-//W3C//DTD SVG 1.1//EN",
                     "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd")

    svg_params = { :width   => "#{width}cm", 
                   :height  => "#{height}cm",
                   :viewBox => "0 0 #{(width*100).to_i} #{(height*100).to_i}",
                   :xmlns   => "http://www.w3.org/2000/svg",
                   :version => "1.1" }

    builder.svg(svg_params) do |svg|
      @lines.each { |params| svg.line(params) }
    end

    builder.target!
  end
end

drawing = Drawing.new(4,4)

line1_data = Drawing::Line.new([100, 100], [200, 250])
line2_data = Drawing::Line.new([125, 100], [200, 250])

line_style = Drawing::Style.new(:stroke_color => "blue", :stroke_width => "2")


drawing.line(line1_data, line_style)

drawing.line(line2_data, line_style)

File.write("sample.svg", drawing.to_svg)
