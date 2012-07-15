include_class 'org.jdesktop.jxlayer.plaf.ext.LockableUI'
include_class 'org.jdesktop.swingx.painter.BusyPainter'
include_class 'java.awt.geom.Ellipse2D'

class CenteredBusyPainter < BusyPainter
  def initialize(*args)
    super
    # Workaround for JRuby bug #2861
    @do_paint_method = BusyPainter.java_class.declared_method("doPaint", java.awt.Graphics2D, java.lang.Object, :int,           :int)
#    @do_paint_method = BusyPainter.java_class.declared_method("doPaint", java.awt.Graphics2D, java.lang.Object, java.lang.Long, java.lang.Long)
 #   @do_paint_method.accessible = true
  end
  
  def doPaint(graphics, object, width, height)
#    LOGGER.warn "doPaint called with object #{object.pretty_inspect }"  JGBDEBUG
    rectangle = trajectory.bounds
    translated_width = width - rectangle.width - (2 * rectangle.x)
    translated_height = height - rectangle.height - (2 * rectangle.y)
    graphics.translate(translated_width / 2, translated_height / 2)
   # @do_paint_method.invoke(self.java_object, graphics.java_object, object.java_object, Java.ruby_to_java(width), Java.ruby_to_java(height))
    
   # h = height.to_i + 1
   # h = h - 1
   # w = width.to_i + 1
   # w = w -1
   #LOGGER.warn "#{__LINE__} has graphics.java_object = #{graphics.java_object.inspect}"
   #LOGGER.warn "#{__LINE__} has object.java_object = #{object.java_object.inspect}"
    
    do_paint graphics.java_object, object.java_object, width, height

#    do_paint( graphics.java_object, true, w, h) # DEBUG Just guessing here
    # We can avoid some of that bug workaround, but still get the error about type mismatch :(
  
  end
end

class BusyPainterUI < LockableUI
  include Java::java::awt::event::ActionListener
  def initialize(*effects)
    super(effects.to_java('org.jdesktop.jxlayer.plaf.effect.LayerEffect'))
    
    @timer = javax.swing.Timer.new(100, self)
    @frame_number = 0
    @busy_painter = CenteredBusyPainter.new(Ellipse2D::Double.new(0, 0, 15, 15), Ellipse2D::Double.new(0,0,100,100))

    # Workaround for JRuby bug #2861
    @paint_layer_method = LockableUI.java_class.declared_method("paintLayer", java.awt.Graphics2D, JXLayer)
    @paint_layer_method.accessible = true
    
    @set_dirty_method = org.jdesktop.jxlayer.plaf.AbstractLayerUI.java_class.declared_method("setDirty", :boolean)
    @set_dirty_method.accessible = true
  end
  
  def setLocked(locked)
    super
    if locked
      @timer.start
    else
      @timer.stop
    end
  end
  alias_method :locked=, :setLocked
  alias_method :set_locked, :setLocked
  
  def paintLayer(graphics, layer)
    @paint_layer_method.invoke(self.java_object, graphics.java_object, layer.java_object)
    @busy_painter.paint(graphics, layer, layer.width, layer.height) if locked?
  end
  
  def actionPerformed(event)
    @frame_number += 1
    @frame_number %= 8
    @busy_painter.frame = @frame_number

    #@set_dirty_method.invoke(self.java_object, Java.ruby_to_java(true))
    @set_dirty_method.invoke(self.java_object, true)
  end
end
