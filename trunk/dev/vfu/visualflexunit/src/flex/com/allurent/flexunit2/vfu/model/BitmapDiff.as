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
    import flash.display.BitmapData;

    /**
     * BitmapDiff's mission is to carry data describing the differences between
     * two BitmapData objects.
     *
     * @see com.allurent.flexunit2.vfu.model.PixelDiff#absoluteColorDiff
     */
    public class BitmapDiff
    {
        /**
         * The average absoluteColorDiff for all pixels. Note that "all" includes
         * pixels that exist in one bitmap but not in the other. See
         * PixelDiff.absoluteColorDiff for a definition of absoluteColorDiff.
         *
         * @see com.allurent.flexunit2.vfu.model.PixelDiff#absoluteColorDiff
         */
        public var averageDiffAllPixels:Number;

        /**
         * The average absoluteColorDiff for all non-matching pixels. Note that
         * this includes pixels that exist in one bitmap but not in the other. See
         * PixelDiff.absoluteColorDiff for a definition of absoluteColorDiff.
         *
         * @see com.allurent.flexunit2.vfu.model.PixelDiff#absoluteColorDiff
         */
        public var averageDiffNonMatchingPixels:Number;

        /**
         * Shows pixels in bitmap1 that aren't precisely matched
         * in bitmap2. All other pixels are set to transparent.
         */
        public var bitmap1DiffPixels:BitmapData;

        /**
         * Shows pixels in bitmap2 that aren't precisely matched
         * in bitmap1. All other pixels are set to transparent.
         */
        public var bitmap2DiffPixels:BitmapData;

        /**
         * This var showest highest absoluteColorDiff amongst all non-identical pixels.
         * See PixelDiff.absoluteColorDiff for a definition of absoluteColorDiff.
         *
         * @see com.allurent.flexunit2.vfu.model.PixelDiff#absoluteColorDiff
         */
        public var highestAbsoluteColorDiff:int;

        /**
         * This figure is derived in the following manner:
         *    1. Look at each continuous area of diff pixels (pixels that
         *       don't match precisely in both bitmaps). Contiguous is
         *       defined as pixels that are above, below, left or right
         *       of each other, and doesn't include pixels that only
         *       touch on the corner.
         *    2. Determine the bounding rect that encloses each area.
         *    3. Look at each vertical and horizontal dimension for these
         *       rects and select the longest one.
         */
        public var largestDiffAreaDimension:int;

        /**
         * The number of pixels that exist in both bitmaps and match precisely
         */
        public var matchingPixelCount:int;

        /**
         * The number of pixels that exist in either or both bitmaps but
         * don't match (i.e. have different color or alpha values in the two
         * bitmaps)
         */
        public var nonMatchingPixelCount:int;

        /**
         * An Array of PixelDiff instances, one for each pixel that exists
         * in either or both bitmaps but doesn't match.
         */
        public var nonMatchingPixelData:Array;

        /**
         * The number of pixel locations that are included in both bitmaps
         */
        public var overlapPixelCount:int;

        /**
         * Total absoluteColorDiff for all non-matching pixels. See
         * PixelDiff.absoluteColorDiff for a definition of absoluteColorDiff.
         *
         * @see com.allurent.flexunit2.vfu.model.PixelDiff#absoluteColorDiff
         */
        public var totalAbsoluteColorDiff:int;

        /**
         * The number of pixels that exist in either or both of
         * bitmap1 and bitmap2
         */
        public var totalPixelCount:int;

        /**
         * The percent of pixels in the two bitmaps that don't match.
         * Areas in either bitmap that don't overlap the other bitmap
         * are considered be part of total area and to be non-identical.
         */
        public function get percentDifferent():Number
        {
            return (nonMatchingPixelCount/totalPixelCount) * 100;
        }

        /**
         * The percent of pixels in the two bitmaps that are identical.
         * Areas in either bitmap that don't overlap the other bitmap
         * are considered be part of total area and to be non-identical.
         */
        public function get percentIdentical():Number
        {
            return (matchingPixelCount/totalPixelCount) * 100;
        }
    }
}