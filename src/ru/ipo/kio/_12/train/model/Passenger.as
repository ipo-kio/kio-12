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

    public function Passenger(destination:StationType) {
        this._destination=destination;
        this.view = new PassengerView(this);
    }

    public function get destination():StationType {
        return _destination;
    }

}
}
