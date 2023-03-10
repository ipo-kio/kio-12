/**
 *
 * @author: Vasily Akimushkin
 * @since: 29.01.12
 */
package ru.ipo.kio._12.train.model {
import ru.ipo.kio._12.train.model.types.StationType;
import ru.ipo.kio._12.train.view.PassengerView;

public class Passenger extends VisibleEntity {

    private var _destination:StationType;
    
    private var _time:int = 0;

    public function Passenger(destination:StationType) {
        this._destination=destination;
        this.view = new PassengerView(this);
    }

    public function get destination():StationType {
        return _destination;
    }

    public function get time():int {
        return _time;
    }

    public function set time(value:int):void {
        _time = value;
    }

    public function get type():int {
        if(destination==StationType.FIRST)
            return 1;
        if(destination==StationType.SECOND)
            return 2;
        if(destination==StationType.THIRD)
            return 3;
        if(destination==StationType.FOURTH)
            return 4;
        return 0;
    }
}
}
