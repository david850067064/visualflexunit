/**
 *  Copyright (c) 2007 Allurent, Inc.
 *  http://code.google.com/p/visualflexunit/
 *  
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
 *  
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 *  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package com.allurent.flexunit2.vfu.utils.misc
{
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.events.Event;
    import flash.geom.Rectangle;

    import mx.containers.Canvas;
    import mx.core.Application;
    import mx.managers.FocusManager;
    import mx.managers.IFocusManagerContainer;
    import mx.managers.ISystemManager;

    /**
     * InputBlocker prevents user input similar to how the PopUpManager
     * does whenever a modal popup window is created. An invisible pane
     * is drawn over top of the screen which prevents mouseclicks while
     * a FocusManager is created and activated, thereby preventing
     * tabbing to the UI being covered.
     */
    public class InputBlocker
    {
        // counter used to track blocking requests
        private static var _blockCount:int = 0;

        // glass pane
        private static var _pane:Canvas;

        /**
         * Blocks user input by creating an invisible pane which covers
         * the entire screen and a FocusManager which prevents tabbing
         * to the underlying UI.
         */
        public static function block():void
        {
            _blockCount++;
            if (_blockCount == 1)
            {
                addPane();
            }
        }

        /**
         * Unblocks user input by removing the pane and it's FocusManager.
         */
        public static function unblock():void
        {
            if (_blockCount > 0)
            {
                _blockCount--;
                if (_blockCount == 0)
                {
                    removePane();
                }
            }
        }

        /**
         * Adds the pane.
         */
        private static function addPane():void
        {
            // reference to the Application's system manager
            var sm:ISystemManager = Application.application.systemManager;

            // create a glass pane to eat mouse clicks, Canvas is used here
            // so that it can get a new FocusManager which will prevent tabbing
            // to elements below the pane
            _pane = new Canvas();

            // add the pane to the system manager
            sm.addChild(_pane);

            var g:Graphics = _pane.graphics;
            var s:Rectangle = sm.screen;

            // draw an invisible rectangle to intercept mouse clicks
            g.clear();
            g.beginFill(0x000000, 0);
            g.drawRect(s.x, s.y, s.width, s.height);
            g.endFill();

            // create a FocusManager to prevent tabbing and keyboard input
            IFocusManagerContainer(_pane).focusManager =
                new FocusManager(IFocusManagerContainer(_pane), true);
            sm.activate(IFocusManagerContainer(_pane));

            // setup event listener to handle resizes
            sm.addEventListener(Event.RESIZE, resizeHandler);
        }

        /**
         * Removes the pane.
         */
        private static function removePane():void
        {
            // reference to the Application's system manager
            var sm:ISystemManager = Application.application.systemManager;

            // remove event listener
            sm.removeEventListener(Event.RESIZE, resizeHandler);

            // remove FocusManager
            sm.removeFocusManager(IFocusManagerContainer(_pane));

            // remove glass pane
            sm.removeChild(_pane);
        }

        /**
         * Ensures glass pane will cover the whole screen.
         */
        private static function resizeHandler(event:Event):void
        {
            var s:Rectangle = ISystemManager(DisplayObject(event.target).root).screen;

            if (_pane && _pane.stage == DisplayObject(event.target).stage)
            {
                _pane.width = s.width;
                _pane.height = s.height;
                _pane.x = s.x;
                _pane.y = s.y;
            }
        }
    }
}