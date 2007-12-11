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

package com.allurent.flexunit2.vfu.model
{
    /**
     * This class contains data that describes the differences between
     * two pixels at the same location in two separate images. Most of
     * its properties consist of the same four pieces of data for each of:
     *    - Its three colors
     *    - Its alpha value
     * These four pieces of data are:
     *    - The value for the specified color or alpha for the first image:
     *         e.g. alpha1, red1, green1, blue1
     *    - The value for the specified color or alpha for the second image:
     *         e.g. alpha2, red2, green2, blue2
     *    - The difference between the values for the two images
     *         e.g. alphaDiff = alpha1 - alpha2
     *         e.g. redDiff = red1 - red2
     *         etc.
     *    - The absolute difference between the values for the two images
     *         e.g. alphaDiffAbs = Math.abs( alpha1 - alpha2 )
     *         e.g. redDiffAbs = Math.abs( red1 - red2 )
     *         etc.
     *
     * <p>This accounts for 16 of the properties below. The others are documented
     * individually.</p>
     */
    public class PixelDiff
    {
        /**
         * The pixels' x value
         */
        public var x:int;

        /**
         * The pixels' y value
         */
        public var y:int;

        /**
         * The pixel's 32 bit color value in the first image
         */
        public var color1:uint;

        /**
         * The pixel's 32 bit color value in the second image
         */
        public var color2:uint;

        /**
         * absoluteColorDiff is the figure that one arrives at when one
         * adds the absolute differences between the alpha, red, green and blue
         * values for two pixels. Here's an example:
         *    Pixel A has the following color values:  alpha:255, red:78, green:201, blue:21
         *    Pixel B has the following color values:  alpha:255, red:76, green:203, blue:21
         *    Diff values: alpha:0, red:2, green:-2, blue:0
         *    absoluteColorDiff = 4</p>
         */
        public var absoluteColorDiff:int;

        public var alpha1:int;
        public var alpha2:int;
        public var alphaDiff:int;
        public var alphaDiffAbs:int;
        public var red1:int;
        public var red2:int;
        public var redDiff:int;
        public var redDiffAbs:int;
        public var green1:int;
        public var green2:int;
        public var greenDiff:int;
        public var greenDiffAbs:int;
        public var blue1:int;
        public var blue2:int;
        public var blueDiff:int;
        public var blueDiffAbs:int;
    }
}