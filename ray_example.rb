require 'ray'

class LazyObject < BasicObject
  def initialize(&callback)
    @callback = callback
  end

  def __result__
    @__result__ ||= @callback.call
  end

  def method_missing(*a, &b)
    __result__.send(*a, &b)
  end
end

class Location
  def self.[](x,y)
    @locations      ||= {}
    @locations[[x,y]] ||= new(x,y)
  end 

  def initialize(x,y)
    @x     = x
    @y     = y
    @color = [:green, :green, :blue].sample

    @north = LazyObject.new { Location[@x,@y-1] }
    @south = LazyObject.new { Location[@x,y+1] }
    @east  = LazyObject.new { Location[@x+1, @y] }
    @west  = LazyObject.new { Location[@x-1, @y] }
  end

  def ==(other)
    [x,y] == [other.x, other.y]
  end  

  attr_reader :x, :y, :color, :north, :south, :east, :west
end

Ray.game "Test" do

  register { add_hook :quit, method(:exit!) }

  scene :square do
    self.frames_per_second = 10

    @location = Location.new(16,12)
    @world = [@location, @location.north, @location.south, @location.east, @location.west]

    always do
      @location = @location.west if holding?(:left)
      @location = @location.east if holding?(:right)
      @location = @location.north if holding?(:up)
      @location = @location.south if holding?(:down)

      @world << @location.north unless @world.include?(@location.north)
      @world << @location.south unless @world.include?(@location.south)
      @world << @location.east unless @world.include?(@location.east)
      @world << @location.west unless @world.include?(@location.west)
    end

    render do |win|
      @normal_view = window.default_view
      @normal_view.center = @location.x*20 + 5, @location.y*20 + 5
      

      win.with_view(@normal_view) do
        @world.each { |location| 
          rect = Ray::Polygon.rectangle([0,0,20,20], Ray::Color.send(location.color))
          rect.pos = [location.x*20, location.y*20]
          win.draw(rect) 
        }

        marker = Ray::Polygon.rectangle([0,0,10,10], Ray::Color.red)
        marker.pos = [@location.x*20 + 5, @location.y*20 + 5]

        win.draw(marker)
      end
    end
  end

  scenes << :square
end
