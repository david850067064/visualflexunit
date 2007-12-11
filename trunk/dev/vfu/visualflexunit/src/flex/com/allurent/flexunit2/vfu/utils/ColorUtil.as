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
    public class ColorUtil
    {
        /**
         * Accepts either a 24 bit or a 32 bit color value and returns an
         * Object instance with the following int values:
         *      .alpha (set to null for 24 bit colors)
         *      .red
         *      .green
         *      .blue
         */
        public static function separateColors(color:uint):Object
        {
            var o:Object = new Object();
            if (color > 0xFFFFFF)
            {
                // Color is 32 bit color
                o.alpha  = (color >>> 24);
                o.red    = (color >>> 16) & 0xFF;
            }
            else
            {
                // Color is 24 bit color
                o.alpha  = null;
                o.red    = (color >>> 16) & 0xFF;
            }
            o.green  = (color >>> 8) & 0xFF;
            o.blue   = color & 0xFF;
            return o;
        }
    }
}