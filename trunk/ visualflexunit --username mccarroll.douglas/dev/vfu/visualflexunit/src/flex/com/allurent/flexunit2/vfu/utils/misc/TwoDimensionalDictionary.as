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
    import com.allurent.flexunit2.vfu.IDisposable;
    import com.allurent.flexunit2.vfu.utils.StringUtil;

    /**
     * TwoDimensionalDictionary offers a simple two dimensional model that
     * allows you to set and retrieve values using x and y coordinates.
     *
     * <p>This class uses terms like height, width, x, and y for convenience
     * but is intended to serve as a lookup table for any data that can be
     * most conveniently stored within a two-dimensional abstraction.</p>
     *
     * <p>Note that while x and y values are zero-based, height and width
     * are not. Thus a TwoDimensionalDictionary with a height and width set
     * to 100 expects x and y values between 0 and 99.</p>
     */
    public class TwoDimensionalDictionary implements IDisposable
    {
        private var _width:int;
        private var _height:int;
        private var _dictionary:Object;
        private var _maxCharsPerDimension:int;

        /**
         * Constructor
         *
         * @param width The first dimension's size - not zero based.
         * @param height The second dimension's size - ditto.
         */
        public function TwoDimensionalDictionary(width:int, height:int):void
        {
            _width = width;
            _height = height;
            _maxCharsPerDimension = Math.max(String(width).length, String(height).length)
            _dictionary = new Object();
        }

        /* ***************************************************************
         *
         *     Public Methods
         *
         ****************************************************************/

        /**
         * Use this method to confirm that a pair of coordinates falls within
         * the dictionary's defined size.
         *
         * @param x Zero-based x loc
         * @param y Zero-based y loc
         */
        public function areCoordinatesValid(x:int, y:int):Boolean
        {
            var result:Boolean;
            try
            {
                checkCoordinates(x, y);
                result = true
            }
            catch (e:Error)
            {
                result = false;
            }
            return result;
        }

        /**
        * @inheritDoc
        */
        public function dispose():void
        {
            for each (var o:Object in _dictionary)
            {
                if (o is IDisposable)
                {
                    o.dispose();
                }
            }
            _dictionary = null;
        }

        /**
         * Sets value for specified coordinates.
         *
         * @param x Zero-based x loc
         * @param y Zero-based y loc
         * @param value Any Object or subclass of Object
         */
        public function setValue(x:int, y:int, value:Object):void
        {
            checkCoordinates(x, y);
            var key:String = convertDimensionsToKey(x, y);
            _dictionary[key] = value;
        }

        /**
         * Retrieves value for specified coordinates.
         *
         * @param x Zero-based x loc
         * @param y Zero-based y loc
         * @return Value set for coordinates, or null if no value is set.
         */
        public function getValue(x:int, y:int):Object
        {
            checkCoordinates(x, y);
            var key:String = convertDimensionsToKey(x, y);
            return _dictionary[key];
        }

        /* ***************************************************************
         *
         *     Accessor Methods
         *
         ****************************************************************/

        public function get width():int
        {
            return _width;
        }

        public function get height():int
        {
            return _height;
        }

        /* ***************************************************************
         *
         *     Private Methods
         *
         ****************************************************************/

        private function checkCoordinates(x:int, y:int):void
        {
            if (x < 0)
            {
                throw new Error("TwoDimensionalDictionary: x < 0");
            }
            if (y < 0)
            {
                throw new Error("TwoDimensionalDictionary: y < 0");
            }
            if (x > (_width - 1))
            {
                throw new Error("TwoDimensionalDictionary: x too large");
            }
            if (y > (_height - 1))
            {
                throw new Error("TwoDimensionalDictionary: y too large");
            }
        }

        private function convertDimensionsToKey(x:int, y:int):String
        {
            return StringUtil.pad(String(x), _maxCharsPerDimension, "_") + StringUtil.pad(String(y), _maxCharsPerDimension, "_");
        }
    }
}