/**
 * Created by IntelliJ IDEA.
 * User: ilya
 * Date: 11.02.12
 * Time: 23:52
 * To change this template use File | Settings | File Templates.
 */
package ru.ipo.kio._12.diamond {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import ru.ipo.kio._12.diamond.model.Diamond;
import ru.ipo.kio._12.diamond.model.Spectrum;
import ru.ipo.kio._12.diamond.view.*;
import ru.ipo.kio.api.KioApi;
import ru.ipo.kio.api.KioProblem;
import ru.ipo.kio.api.Settings;
import ru.ipo.kio.api.controls.GraphicsButton;
import ru.ipo.kio.api.controls.RecordBlinkEffect;

//TODO дискретные лучи (?)
//TODO дискретные точки (?)

public class DiamondProblem extends Sprite implements KioProblem {

    [Embed(source="loc/Diamond.ru.json-settings",mimeType="application/octet-stream")]
    public static var DIAMOND_RU:Class;
    [Embed(source="loc/Diamond.en.json-settings",mimeType="application/octet-stream")]
    public static var DIAMOND_EN:Class;
    [Embed(source="loc/Diamond.es.json-settings",mimeType="application/octet-stream")]
    public static var DIAMOND_ES:Class;
    [Embed(source="loc/Diamond.bg.json-settings",mimeType="application/octet-stream")]
    public static var DIAMOND_BG:Class;
    [Embed(source="loc/Diamond.th.json-settings",mimeType="application/octet-stream")]
    public static var DIAMOND_TH:Class;

    [Embed(source='resources/Button_09a.png', mimeType='image/png')]
    public static const BT_0:Class;
    [Embed(source='resources/Button_09b.png', mimeType='image/png')]
    public static const BT_1:Class;
    [Embed(source='resources/Button_09c.png', mimeType='image/png')]
    public static const BT_2:Class;

    [Embed(source='resources/Button_10a.png', mimeType='image/png')]
    public static const BT_I0:Class;
    [Embed(source='resources/Button_10b.png', mimeType='image/png')]
    public static const BT_I1:Class;
    [Embed(source='resources/Button_10c.png', mimeType='image/png')]
    public static const BT_I2:Class;

    [Embed(source='resources/b1.jpg')]
    public static const b1:Class;
    [Embed(source='resources/b2.jpg')]
    public static const b2:Class;
    [Embed(source='resources/b3.jpg')]
    public static const b3:Class;
    [Embed(source='resources/b4.jpg')]
    public static const b4:Class;
    [Embed(source='resources/b5.jpg')]
    public static const b5:Class;

    [Embed(source='resources/034.png')]
    public static const LV_1_BG:Class;
    [Embed(source='resources/024.png')]
    public static const LV_2_BG:Class;
    [Embed(source='resources/Pic_04.png')]
    public static const LV_1_ILLUSTRATION:Class;
    [Embed(source='resources/Pic_01.png')]
    public static const LV_2_ILLUSTRATION:Class;

    public static const ID:String = 'diamond';

    private var _level:int = 1;
    private var api:KioApi;
    private var eye:Eye;
    private var diamond:Diamond;
    
    private var current_ray_info:InfoField;
    private var current_info:InfoField;
    private var record_info:InfoField;

    private var illustration_image:DisplayObject;

    //level 1 record
    private var _record_points:int = 0;
    private var _record_var:Number = 0;

    //level 2 record
    private var _record_light:Number = 0;

    public function DiamondProblem(level:int) {
        _level = level;

        KioApi.registerLocalization(ID, KioApi.L_RU, new Settings(DIAMOND_RU).data);
        KioApi.registerLocalization(ID, KioApi.L_EN, new Settings(DIAMOND_EN).data);
        KioApi.registerLocalization(ID, KioApi.L_ES, new Settings(DIAMOND_ES).data);
        KioApi.registerLocalization(ID, KioApi.L_BG, new Settings(DIAMOND_BG).data);
        KioApi.registerLocalization(ID, KioApi.L_TH, new Settings(DIAMOND_TH).data);

        KioApi.initialize(this);

        api = KioApi.instance(ID);

        init();

        //stage mouse listener
        addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
            stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouse_up);
        });
        addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void {
            stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouse_up);
        });
    }

    private function init(e:Event = null):void {
        diamond = new Diamond(level);
        diamond.addVertex(new Vertex2D(35, 10));
        diamond.addVertex(new Vertex2D(35, -15));
        diamond.addVertex(new Vertex2D(45, 5));
        diamond.addVertex(new Vertex2D(55, -10));
        
        if (_level == 1)
            addChild(new LV_1_BG);
        else
            addChild(new LV_2_BG);

        eye = new Eye(diamond, _level);

        eye.x = level == 2 ? 140 : 88;
        eye.y = 25;

        addChild(eye);
        
        var loc:Object = api.localization;

        if (level == 2) {
            var spectrumView:CircleSpectrumView = new CircleSpectrumView(diamond, eye);
            spectrumView.x = eye.x + eye.origin.x;
            spectrumView.y = eye.y + eye.origin.y;
            addChild(spectrumView);

            //current ray info
            current_ray_info = new InfoField(
                    loc.ray_info,
                    [loc.mean_brightness, loc.color_variance]
            );
            current_ray_info.x = 58;
            current_ray_info.y = 504;
            addChild(current_ray_info);

            eye.addEventListener(Eye.ANGLE_CHANGED, ray_moved);
            diamond.addEventListener(Diamond.UPDATE, ray_moved);
            ray_moved(null);

            //current info
            current_info = new InfoField(
                    loc.current_result,
                    [loc.global_mean_brightness, loc.mean_variance]
            );
            current_info.x = 294;
            current_info.y = 504;
            addChild(current_info);


            //record info
            record_info = new InfoField(
                    loc.record,
                    [loc.global_mean_brightness, loc.mean_variance]
            );
            record_info.x = 529;
            record_info.y = 504;
            addChild(record_info);

            diamond.addEventListener(Diamond.UPDATE, update_current_info_2);
            update_current_info_2(null, true);
        } else {
            current_info = new InfoField(
                    loc.current_result,
                    [loc.points_count, loc.points_uniformity]
            );

            current_info.x = 66;
            current_info.y = 500;
            addChild(current_info);

            //record info
            record_info = new InfoField(
                    loc.record,
                    [loc.points_count, loc.points_uniformity]
            );
            record_info.x = 460;
            record_info.y = 500;
            addChild(record_info);

            diamond.addEventListener(Diamond.UPDATE, update_current_info_1);
            eye.addEventListener(Eye.ANGLE_CHANGED, update_current_info_1);
            update_current_info_1(null, true);
        }

        //1 - 72 461
        //2 - 78 459
        var illustration_button:GraphicsButton = new GraphicsButton(
                loc.button_illustration,
                new BT_I0().bitmapData,
                new BT_I1().bitmapData,
                new BT_I2().bitmapData,
                'KioTahoma',
                12, 12, 2, 2, -7, -5
        );
        illustration_button.x = level == 1 ? 72 : 78;
        illustration_button.y = level == 1 ? 431 : 439;
        illustration_button.addEventListener(MouseEvent.MOUSE_DOWN, function (event:Event):void {
            if (illustration_image == null) {
                illustration_image = new (level == 1 ? LV_1_ILLUSTRATION : LV_2_ILLUSTRATION);
                illustration_image.x = 6;
                illustration_image.y = 7;
                addChild(illustration_image);
            }
        });
        addChild(illustration_button);

        var remove_extra_button:GraphicsButton = new GraphicsButton(
                loc.button_remove_extra_points,
                new BT_0().bitmapData,
                new BT_1().bitmapData,
                new BT_2().bitmapData,
                'KioTahoma',
                12, 12, 2, 2, 0, -3
        );
        remove_extra_button.x = 570;
        remove_extra_button.y = 425;
        addChild(remove_extra_button);
        remove_extra_button.addEventListener(MouseEvent.CLICK, function (event:Event):void {
            diamond.only_hullize();
        });
    }

    private function stage_mouse_up(e:MouseEvent):void {
        if (illustration_image != null) {
            removeChild(illustration_image);
            illustration_image = null;
        }
    }

    private function update_current_info_1(event:Event = null, no_autosave:Boolean = false):void {
        var o:Object = eye.evaluate_outer_intersections();
        current_info.set_values([o.points, o.variance]);
        if (! no_autosave)
            api.autoSaveSolution();
        
        if (o.points > _record_points || o.points == _record_points && o.variance < _record_var) {
            _record_points = o.points;
            _record_var =  o.variance;
            record_info.set_values([_record_points, _record_var]);
            if (! no_autosave)
                api.saveBestSolution();
            RecordBlinkEffect.blink(this, record_info.x - 2, record_info.y - 2 + 30, record_info.width + 4, record_info.height + 4 - 30);
        }
    }

    private function update_current_info_2(event:Event = null, no_autosave:Boolean = false):void {
        current_info.set_values([diamond.spectrum.mean_light, diamond.spectrum.mean_disp]);
        if (! no_autosave)
            api.autoSaveSolution();
        
        if (diamond.spectrum.mean_light > _record_light) {
             _record_light = diamond.spectrum.mean_light;
            record_info.set_values([diamond.spectrum.mean_light, diamond.spectrum.mean_disp]);
            if (! no_autosave)
                api.saveBestSolution();
            RecordBlinkEffect.blink(this, record_info.x - 2, record_info.y - 2 + 30, record_info.width + 4, record_info.height + 4 - 30);
        }
    }

    private function ray_moved(event:Event):void {
        var cols:Array = Spectrum.color_ray(eye.angle, diamond);
        var mn:Number = Spectrum.mean(cols);
        var vr:Number = Spectrum.variance(cols);
        
        current_ray_info.set_values([mn, vr]);
    }

    public function get id():String {
        return ID;
    }

    public function get year():int {
        return 2012;
    }

    public function get level():int {
        return _level;
    }

    public function get display():DisplayObject {
        return this;
    }

    public function get solution():Object {
        return {
            diamond: diamond.serialize(),
            angle: eye.angle
        };
    }

    public function get best():Object {
        return {}; //TODO implement
    }

    public function loadSolution(solution:Object):Boolean {
        if (solution == null)
            return false;
        
        diamond.unserialize(solution.diamond);
        eye.angle = solution.angle;

        if (level == 1)
            update_current_info_1();
        else
            update_current_info_2();

        return true;
    }

    public function check(solution:Object):Object {
        return {}; //TODO implement
    }

    public function compare(solution1:Object, solution2:Object):int {
        return 0; //TODO implement
    }

    [Embed(source='resources/intro.png')]
    private static var INTRO:Class;

    public function get icon():Class {
        return INTRO;
    }

    public function get icon_help():Class {
        if (level == 1)
            return b3;
        else
            return b1;
    }

    public function get icon_statement():Class {
        if (level == 1)
            return b4;
        else
            return b5;
    }
}
}
