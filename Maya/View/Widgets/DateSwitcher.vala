//
//  Copyright (C) 2011-2012 Maxwell Barvian
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

namespace Maya.View.Widgets {

    public class DateSwitcher : Gtk.EventBox {

        // Signals
        public signal void left_clicked ();
        public signal void right_clicked ();

        // Constants
        protected const int PADDING = 5;

        private bool _is_pressed = false;
        protected bool is_pressed {
            get { return _is_pressed; }
            set {
                _is_pressed = value;
                if (hovered == 0 || hovered == 2)
                    container_grid.get_children ().nth_data (hovered).set_state (value ? Gtk.StateType.SELECTED : Gtk.StateType.NORMAL);
                queue_draw ();
            }
        }

        private int _hovered = -1;
        protected int hovered {
            get { return _hovered; }
            set {
                _hovered = value;
                queue_draw ();
            }
        }

        private Gtk.Grid container_grid;

        public Gtk.Label label { get; protected set; }
        public string text {
            get { return label.label; }
            set { label.label = value; }
        }

        /**
         * Creates a new DateSwitcher.
         *
         * @param chars_width
         *          The width of the label. Automatic if -1 is given.
         */
        public DateSwitcher (int width_chars) {

            // EventBox properties
            events |= Gdk.EventMask.POINTER_MOTION_MASK
                   |  Gdk.EventMask.BUTTON_PRESS_MASK
                   |  Gdk.EventMask.BUTTON_RELEASE_MASK
                   |  Gdk.EventMask.SCROLL_MASK
                   |  Gdk.EventMask.LEAVE_NOTIFY_MASK;
            set_visible_window (false);

            // Initialize everything
            container_grid = new Gtk.Grid();
            container_grid.border_width = 0;
            container_grid.set_row_homogeneous (true);
            label = new Gtk.Label ("");
            label.width_chars = width_chars;

            // Add everything in appropriate order
            container_grid.attach (Util.set_paddings (new Gtk.Arrow (Gtk.ArrowType.LEFT, Gtk.ShadowType.NONE), 0, PADDING, 0, PADDING),
                    0, 0, 1, 1);
            container_grid.attach (label, 1, 0, 1, 1);
            container_grid.attach (Util.set_paddings (new Gtk.Arrow (Gtk.ArrowType.RIGHT, Gtk.ShadowType.NONE), 0, PADDING, 0, PADDING),
                    2, 0, 1, 1);

            add (container_grid);
        }

        protected override bool scroll_event (Gdk.EventScroll event) {

            switch (event.direction) {
                case Gdk.ScrollDirection.LEFT:
                    left_clicked ();
                    break;
                case Gdk.ScrollDirection.RIGHT:
                    right_clicked ();
                    break;
            }

            return true;
        }

        protected override bool button_press_event (Gdk.EventButton event) {

            is_pressed = (hovered == 0 || hovered == 2);

            return true;
        }

        protected override bool button_release_event (Gdk.EventButton event) {

            is_pressed = false;
            if (hovered == 0)
                right_clicked ();
            else if (hovered == 2)
                left_clicked ();

            return true;
        }

        protected override bool motion_notify_event (Gdk.EventMotion event) {

            Gtk.Allocation box_size, left_size, right_size;
            container_grid.get_allocation (out box_size);
            container_grid.get_children ().nth_data (0).get_allocation (out left_size);
            container_grid.get_children ().nth_data (2).get_allocation (out right_size);

            double x = event.x + box_size.x;

            if (x > left_size.x && x < left_size.x + left_size.width)
                hovered = 0;
            else if (x > right_size.x && x < right_size.x + right_size.width)
                hovered = 2;
            else
                hovered = -1;

            return true;
        }

        protected override bool leave_notify_event (Gdk.EventCrossing event) {

            is_pressed = false;
            hovered = -1;

            return true;
        }

        protected override bool draw (Cairo.Context cr) {

            Gtk.Allocation box_size;
            container_grid.get_allocation (out box_size);

            style.draw_box (cr, Gtk.StateType.NORMAL, Gtk.ShadowType.ETCHED_OUT, this, "button", 0, 0, box_size.width, box_size.height);

            if (hovered == 0 || hovered == 2) {

                Gtk.Allocation arrow_size;
                container_grid.get_children ().nth_data (hovered).get_allocation (out arrow_size);

                cr.save ();

                cr.rectangle (arrow_size.x - box_size.x, 0, arrow_size.width, arrow_size.height);
                cr.clip ();

                if (is_pressed)
                    style.draw_box (cr, Gtk.StateType.SELECTED, Gtk.ShadowType.IN, this, "button", 0, 0, box_size.width, box_size.height);
                else
                    style.draw_box (cr, Gtk.StateType.PRELIGHT, Gtk.ShadowType.ETCHED_OUT, this, "button", 0, 0, box_size.width, box_size.height);

                cr.restore ();
            }

            propagate_draw (container_grid, cr);

            return true;
        }

    }

}
