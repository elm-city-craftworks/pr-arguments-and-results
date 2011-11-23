require "builder"

class Drawing
  def initialize(width, height)
    @width  = width
    @height = height

    @viewbox_width  = (@width * 100).ceil
    @viewbox_height = (@height * 100).ceil

    @elements = []
  end

  attr_reader :width, :height, :elements, :viewbox_width, :viewbox_height


  def draw(shape, style)
    unless shape.bounded_by?(viewbox_width, viewbox_height)
      raise ArgumentError, "shape is not within view box"
    end

    @elements << shape.to_hash(style)
  end

  def to_svg
    builder = Builder::XmlMarkup.new(:indent => 2)
    builder.instruct!
    builder.declare!(:DOCTYPE, :svg, :PUBLIC, "-//W3C//DTD SVG 1.1//EN",
                     "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd")

    svg_params = { :width   => "#{width}cm", 
                   :height  => "#{height}cm",
                   :viewBox => "0 0 #{viewbox_width} #{viewbox_height}",
                   :xmlns   => "http://www.w3.org/2000/svg",
                   :version => "1.1" }

    builder.svg(svg_params) do |svg|
      elements.each do |e| 
        svg.tag!(e[:tag_name], e[:params]) 
      end
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
    include Enumerable

    def initialize(*point_data)
      @points = point_data.map { |e| Point.new(*e) }
    end

    def [](index)
      points[index]
    end

    def each
      if block_given?
        points.each { |point| yield(point) }
      else
        to_enum(__method__)
      end
    end

    def bounded_by?(x_max, y_max)
      points.all? { |p| p.x <= x_max && p.y <= y_max }
    end

    def to_hash(*args)
      raise NotImplementedError, 
        "This is an abstract method that subclasses need to implement"
    end

    private

    attr_reader :points
  end

  class Line < Shape
    def to_hash(style)
      { :tag_name => :line, 
        :params   => { :x1    => self[0].x.to_s, 
                       :y1    => self[0].y.to_s, 
                       :x2    => self[1].x.to_s, 
                       :y2    => self[1].y.to_s,
                       :style => style.to_css  } }
    end
  end

  class Polygon < Shape
    def to_hash(style)
      formatted_points = map { |point| "#{point.x},#{point.y}" }.join(" ")

      { :tag_name => :polygon,
        :params   => { :points => formatted_points,
                       :style  => style.to_css } }

    end
  end
  
  class Style
    def initialize(params)
      @stroke_width  = params.fetch(:stroke_width, 5)
      @stroke_color  = params.fetch(:stroke_color, "black")
      @fill_color    = params.fetch(:fill_color, "white")
    end

    attr_reader :stroke_width, :stroke_color

    def to_css
      "stroke: #{stroke_color}; "+
      "stroke-width: #{stroke_width}; "+
      "fill: #{@fill_color}"
    end
  end
end

drawing = Drawing.new(4,4)

line1 = Drawing::Line.new([100, 100], [200, 250])
line2 = Drawing::Line.new([300, 100], [200, 250])

triangle = Drawing::Polygon.new([350, 150], [250, 300], [150,150])

style = Drawing::Style.new(:stroke_color => "blue", :stroke_width => 2)

drawing.draw(line1, style)
drawing.draw(line2, style)
drawing.draw(triangle, style)

File.write("sample.svg", drawing.to_svg)
