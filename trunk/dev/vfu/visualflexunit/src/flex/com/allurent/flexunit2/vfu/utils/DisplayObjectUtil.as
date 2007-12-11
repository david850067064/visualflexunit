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

package com.allurent.flexunit2.vfu.utils
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import mx.core.Application;

    public class DisplayObjectUtil
    {
        /**
         * Sets the x and y properties on a DisplayObject instance, based on its size
         * and the size and the size of a DisplayObjectContainer. Note that some
         * DisplayObjects, SWFLoader for example, need to load their bitmap before
         * being passed in, otherwise their size will be read as 0 by 0 pixels.
         */
        public static function center(displayObject:DisplayObject, container:DisplayObjectContainer):void
        {
            var x:int = (container.width - displayObject.width) / 2;
            var y:int = (container.height - displayObject.height) / 2;
            displayObject.x = x;
            displayObject.y = y;
        }

        /**
         * Returns the "outermost" DisplayObjectContainer for a DisplayObject.
         * For example if you pass in a Button contained by a Panel contained by
         * a Canvas, this method would return a reference to the Canvas instance.
         */
        public static function getOutermostDisplayContainer(displayObject:DisplayObject):DisplayObjectContainer
        {
            if (displayObject is Application)
            {
                return DisplayObjectContainer(displayObject);
            }
            else if (displayObject.parent == null)
            {
                if (displayObject is DisplayObjectContainer)
                {
                    return DisplayObjectContainer(displayObject);
                }
                else
                {
                    return null;
                }
            }
            else
            {
                return getOutermostDisplayContainer(displayObject.parent);
            }
        }

        /**
         * Returns a boolean based on whether or not the DisplayObject is ultimately
         * contained within a Application container.
         */
        public static function isAttachedToDisplayList(displayObject:DisplayObject):Boolean
        {
            return (getOutermostDisplayContainer(displayObject) is Application)
        }
    }
}













