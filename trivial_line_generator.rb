require "builder"

class Drawing
  def initialize(width, height)
    @width  = width
    @height = height
    
    @viewbox_width  = (@width  * 100).ceil
    @viewbox_height = (@height * 100).ceil

    @lines  = []
  end

  attr_reader :width, :height, :lines, :viewbox_width, :viewbox_height

  def line(params)
    @lines << { :x1    => params.fetch(:x1).to_s,
                :y1    => params.fetch(:y1).to_s, 
                :x2    => params.fetch(:x2).to_s, 
                :y2    => params.fetch(:y2).to_s,
                :style => "stroke: #{params.fetch(:stroke_color)}; "+
                          "stroke-width: #{params.fetch(:stroke_width)}" }
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
      lines.each { |params| svg.line(params) }
    end

    builder.target!
  end
end

drawing = Drawing.new(4,4)

drawing.line(:x1 => 100, :y1 => 100, :x2 => 200, :y2 => 250,
             :stroke_color => "blue", :stroke_width => 2)

drawing.line(:x1 => 300, :y1 => 100, :x2 => 200, :y2 => 250,
             :stroke_color => "blue", :stroke_width => 2)

File.write("sample.svg", drawing.to_svg)
