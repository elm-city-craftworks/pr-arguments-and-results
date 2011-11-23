require "builder"

class Drawing
  def initialize(width, height)
    @width  = width
    @height = height

    @viewbox_width  = (@width  * 100).ceil
    @viewbox_height = (@height * 100).ceil

    @lines  = []
  end

  def line(data, style)
    @lines << { :x1 => data[0].x.to_s, :y1 => data[0].y.to_s, 
                :x2 => data[1].x.to_s, :y2 => data[1].y.to_s,
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
                   :viewBox => "0 0 #{@viewbox_width} #{@viewbox_height}",
                   :xmlns   => "http://www.w3.org/2000/svg",
                   :version => "1.1" }

    builder.svg(svg_params) do |svg|
      @lines.each { |params| svg.line(params) }
    end

    builder.target!
  end

  class Point
    def initialize(x, y)
      @x, @y = x, y
    end

    attr_reader :x, :y
  end

  class Shape
    def initialize(*point_data)
      @points = point_data.map { |e| Point.new(*e) }
    end

    def [](index)
      @points[index]
    end
  end
  
  class Style
    def initialize(params)
      @stroke_width  = params.fetch(:stroke_width)
      @stroke_color  = params.fetch(:stroke_color)
    end

    attr_reader :stroke_width, :stroke_color
  end
end

drawing = Drawing.new(4,4)

line1 = Drawing::Shape.new([100, 100], [200, 250])
line2 = Drawing::Shape.new([300, 100], [200, 250])

line_style = Drawing::Style.new(:stroke_color => "blue", :stroke_width => "2")

drawing.line(line1, line_style)

drawing.line(line2, line_style)

File.write("sample.svg", drawing.to_svg)
