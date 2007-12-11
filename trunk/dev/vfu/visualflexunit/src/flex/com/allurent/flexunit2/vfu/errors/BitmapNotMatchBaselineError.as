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

package com.allurent.flexunit2.vfu.errors
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;

    /**
     * Class for reporting cases where a visual test finds that
     * a component displays with an appearance that doesn't match
     * a stored baseline image.
     */
    public class BitmapNotMatchBaselineError extends BlessableError
    {
        /**
         * BitmapData that shows the expected image appearance, as contained
         * in a saved baseline file.
         */
        [Bindable]
        public var expectedBMD:BitmapData;

        /**
         * Bitmap that shows the expected image appearance, as contained
         * in a saved baseline file.
         */
        [Bindable]
        public var expectedBitmap:Bitmap;

        /**
         * BitmapData that shows diff pixels, as they appear when created by
         * running the test. All other pixels are transparent (0x00000000).
         */
        [Bindable]
        public var actualDiffBMD:BitmapData;

        /**
         * BitmapData that shows diff pixels, as they appear in saved baseline
         * image. All other pixels are transparent (0x00000000).
         */
        [Bindable]
        public var expectedDiffBMD:BitmapData;

        /**
         * @see com.allurent.flexunit2.vfu.model
         * @see com.allurent.flexunit2.vfu.model#averageDiffAllPixels
         */
        [Bindable]
        public var averageDiffAllPixels:Number;

        /**
         * @see com.allurent.flexunit2.vfu.model
         * @see com.allurent.flexunit2.vfu.model#averageDiffNonMatchingPixels
         */
        [Bindable]
        public var averageDiffNonMatchingPixels:Number;

        /**
         * @see com.allurent.flexunit2.vfu.model
         * @see com.allurent.flexunit2.vfu.model#highestAbsoluteColorDiff
         */
        [Bindable]
        public var highestAbsoluteColorDiff:int;

        /**
         * @see com.allurent.flexunit2.vfu.model
         * @see com.allurent.flexunit2.vfu.model#largestDiffAreaDimension
         */
        [Bindable]
        public var largestDiffAreaDimension:int;

        /**
         * @see com.allurent.flexunit2.vfu.model
         * @see com.allurent.flexunit2.vfu.model#matchingPixelCount
         */
        [Bindable]
        public var matchingPixelCount:int;

        /**
         * @see com.allurent.flexunit2.vfu.model
         * @see com.allurent.flexunit2.vfu.model#nonMatchingPixelCount
         */
        [Bindable]
        public var nonMatchingPixelCount:int;

        /**
         * @see com.allurent.flexunit2.vfu.model
         * @see com.allurent.flexunit2.vfu.model#nonMatchingPixelData
         */
        [Bindable]
        public var nonMatchingPixelData:Array;

        /**
         * @see com.allurent.flexunit2.vfu.model
         * @see com.allurent.flexunit2.vfu.model#overlapPixelCount
         */
        [Bindable]
        public var overlapPixelCount:int;

        /**
         * @see com.allurent.flexunit2.vfu.model
         * @see com.allurent.flexunit2.vfu.model#percentDifferent
         */
        [Bindable]
        public var percentDifferent:Number;

        /**
         * @see com.allurent.flexunit2.vfu.model
         * @see com.allurent.flexunit2.vfu.model#percentIdentical
         */
        [Bindable]
        public var percentIdentical:Number;

        /**
         * @see com.allurent.flexunit2.vfu.model
         * @see com.allurent.flexunit2.vfu.model#totalAbsoluteColorDiff
         */
        [Bindable]
        public var totalAbsoluteColorDiff:int;

        /**
         * @see com.allurent.flexunit2.vfu.model
         * @see com.allurent.flexunit2.vfu.model#totalPixelCount
         */
        [Bindable]
        public var totalPixelCount:int;

        public function BitmapNotMatchBaselineError(message:String="")
        {
            super(message);
        }
    }
}