/**
 * Created by IntelliJ IDEA.
 * User: ilya
 * Date: 16.02.12
 * Time: 13:01
 * To change this template use File | Settings | File Templates.
 */
package ru.ipo.kio._12.diamond.view {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import ru.ipo.kio._12.diamond.Vertex2D;

public class VertexView extends Sprite {

//    private var _x_scale:int = 5;
//    private var _y_scale:int = 5;

    private var _x_min:int;
    private var _y_min:int;
    private var _x_max:int;
    private var _y_max:int;
    
    private var _v:Vertex2D;

    private var moving_point:Boolean = false;

    public static const VERTEX_MOVED:String = 'vertex moved';
    
    private var _current_view:DisplayObject = null;
    
    private const normal_view:Sprite = new Sprite();
    private const over_view:Sprite = new Sprite();
    private const down_view:Sprite = new Sprite();
    private const hit_test_view:Sprite = new Sprite();

    public function VertexView(v:Vertex2D, x_min:int, y_min:int, x_max:int, y_max:int) {
        _v = v;
        _x_min = x_min;
        _y_min = y_min;
        _x_max = x_max;
        _y_max = y_max;
        
        _v.addEventListener(Vertex2D.MOVE, vertex_moved);

        vertex_moved();

        addEventListener(MouseEvent.MOUSE_DOWN, mouse_down);
        addEventListener(MouseEvent.ROLL_OVER, roll_over);
        addEventListener(MouseEvent.ROLL_OUT, roll_out);
        addEventListener(Event.ADDED_TO_STAGE, function(event:Event):void {
            stage.addEventListener(MouseEvent.MOUSE_UP, mouse_up);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouse_move);
        });
        addEventListener(Event.REMOVED_FROM_STAGE, function(event:Event):void {
            stage.removeEventListener(MouseEvent.MOUSE_UP, mouse_up);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouse_move);
        });

        init_views();
        
        current_view = normal_view;
        
        hit_test_view.mouseEnabled = false;
        hitArea = hit_test_view;
        addChild(hit_test_view);
        hit_test_view.visible = false;
    }

    private function roll_over(event:MouseEvent):void {
        if (!moving_point)
            current_view = over_view;
    }
    
    private function roll_out(event:MouseEvent):void {
        if (!moving_point)
            current_view = normal_view;
    }

    private function init_views():void {
        hit_test_view.graphics.beginFill(0x000000);
        hit_test_view.graphics.drawCircle(0, 0, 5);
        hit_test_view.graphics.endFill();

        over_view.graphics.beginFill(0x00FFFF);
        over_view.graphics.drawCircle(0, 0, 5);
        over_view.graphics.endFill();

        down_view.graphics.beginFill(0xFF0000);
        down_view.graphics.drawCircle(0, 0, 5);
        down_view.graphics.endFill();
        
        normal_view.graphics.lineStyle(1, 0x00000);
        normal_view.graphics.drawRect(-3, -3, 6, 6);
    }

    private function vertex_moved(event:Event = null):void {
        //TODO set scale here
        x = _v.x;
        y = _v.y;
    }

    private function mouse_move(e:MouseEvent):void {
        if (!moving_point)
            return;

        //TODO scale here
        var _x:Number = x;
        var _y:Number = y;
        
        _x = Math.max(_x, _x_min);
        _y = Math.max(_y, _y_min);
        _x = Math.min(_x, _x_max);
        _y = Math.min(_y, _y_max);
        
        _v.setXY(_x, _y);
    }

    private function mouse_down(e:MouseEvent):void {
        //TODO scale here
        current_view = down_view;
        startDrag(false, new Rectangle(_x_min, _y_min, _x_max - _x_min, _y_max - _y_min));
        moving_point = true;
    }

    private function mouse_up(e:MouseEvent):void {
        if (!moving_point)
            return;

        stopDrag();
        moving_point = false;
        current_view = over_view;
    }
    
    public function get vertex():Vertex2D {
        return _v;
    }

    public function get screenPoint():Point {
        return new Point(x, y); //TODO set scale here
    }
    
    public function get current_view():DisplayObject {
        return _current_view;
    }

    public function set current_view(view:DisplayObject):void {
        if (_current_view == view)
            return;

        if (_current_view != null)
            removeChild(_current_view);
        addChild(view);
        _current_view = view;
    }
}
}
