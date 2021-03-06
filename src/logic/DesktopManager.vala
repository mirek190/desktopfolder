/*
 * Copyright (c) 2017 José Amuedo (https://github.com/spheras)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 */

/**
 * @class
 * Desktop Manager
 */
public class DesktopFolder.DesktopManager : DesktopFolder.FolderManager {

    /**
     * @constructor
     * @param DesktopFolderApp application the application owner of this window
     * @param string folder_name the name of the folder
     */
    public DesktopManager (DesktopFolderApp application) {
        // first, let's check the folder
        var directory = File.new_for_path (DesktopFolderApp.get_app_folder ()); // + "/" + DesktopFolder.DesktopWindow.DESKTOP_FAKE_FOLDER_NAME);
        if (!directory.query_exists ()) {
            DirUtils.create (directory.get_path (), 0755);
        }

        base (application, "");

        // we cannot be moved
        this.is_moveable = false;
        this.get_view ().set_type_hint (Gdk.WindowTypeHint.DOCK);

        Gdk.Screen screen = Gdk.Screen.get_default ();
        this.on_screen_size_changed (screen);

        this.get_view ().change_body_color (0);

    }

    /**
     * @name create_view
     * @description create the view associated with this manager
     * @overrided
     */
    protected override void create_view () {
        this.view = new DesktopFolder.DesktopWindow (this);
    }

    /**
     * @name on_screen_size_changed
     * @description detecting screen size changes
     */
    public override void on_screen_size_changed (Gdk.Screen screen) {
        this.get_view ().move (-12, -10);
        int w = screen.get_width () + 25;
        int h = screen.get_height () + 25;
        this.get_view ().resize (w, h);

        debug ("DESKTOP SIZE CHANGED! %d,%d - %d,%d", -12, -10, w, h);
    }

    /**
     * @name skip_file
     * @description we must skip the widget setting files
     * @override
     */
    protected override bool skip_file (File file) {
        string basename = file.get_basename ();

        if (FileUtils.test (file.get_path (), FileTest.IS_DIR)) {
            // is a panel?
            string flagfilepath = file.get_path () + "/.desktopfolder";
            // debug("is a panel? %s",flagfilepath);
            File flagfile       = File.new_for_commandline_arg (flagfilepath);
            return flagfile.query_exists ();
        } else {
            if (basename.has_suffix (DesktopFolder.OLD_NOTE_EXTENSION) || basename.has_suffix (DesktopFolder.OLD_PHOTO_EXTENSION)
                || basename.has_suffix (DesktopFolder.NEW_NOTE_EXTENSION) || basename.has_suffix (DesktopFolder.NEW_PHOTO_EXTENSION)) {
                return true;
            }
        }

        return base.skip_file (file);
    }

    /**
     * @overrided
     * we must create a .nopanel inside to avoid creating a panel from this folder
     */
    protected override void create_new_folder_inside (string folder_path) {
        debug ("esta si que si");
        File nopanel = File.new_for_path (folder_path + "/.nopanel");
        try {
            nopanel.create (FileCreateFlags.NONE);
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
            Util.show_error_dialog ("Error", e.message);
        }
    }

}
