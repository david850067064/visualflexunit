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


package com.allurent.flexunit2.vfu.utils.bitmap
{
    import com.allurent.flexunit2.vfu.model.BitmapDiff;
    import com.allurent.flexunit2.vfu.model.PixelDiff;
    import com.allurent.flexunit2.vfu.utils.ColorUtil;

    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.geom.Matrix;

    /**
     * Bitmap utility methods.
     */
    public class BitmapUtil
    {
         private static const TRANSPARENT:uint     = 0x00000000;

        /**
         * Returns a boolean which indicates whether two bitmap data objects hold
         * identical bitmaps.
         *
         * @param bitmap1:BitmapData
         * @param bitmap2:BitmapData
         */
        public static function areBitmapsIdentical(bitmap1:BitmapData, bitmap2:BitmapData):Boolean
        {
            var comparedBitmap:Object = bitmap1.compare(bitmap2);
            return (comparedBitmap == 0);
        }

        /* ***************************************************************
         *
         *     Public Methods
         *
         ****************************************************************/

        /**
         * Compares two BitmapData instances and return a BitmapDiff describing
         * their differences.
         *
         * @see com.allurent.flexunit2.vfu.model.BitmapDiff
         *
         * @param bitmap1:BitmapData
         * @param bitmap2:BitmapData
         *
         * @return com.allurent.flexunit2.vfu.model.BitmapDiff
         */
        public static function getBitmapDiff(bmd1:BitmapData, bmd2:BitmapData):BitmapDiff
        {
            var w:int = Math.max(bmd1.width, bmd2.width);
            var h:int = Math.max(bmd2.height, bmd2.height);
            var bitmap1DiffPixels:BitmapData = new BitmapData(w, h);
            var bitmap2DiffPixels:BitmapData = new BitmapData(w, h);
            var totalPixelCount:int        = 0;
            var overlapPixelCount:int      = 0;
            var matchingPixelCount:int     = 0;
            var nonMatchingPixelCount:int  = 0;
            var in1:Boolean;
            var in2:Boolean;
            var nonMatchingPixelData:Array  = new Array();

            for (var i:int = 0; i < w; i++)
            {
                for (var j:int = 0; j < h; j++)
                {
                    in1 = isPixelInBitmap(bmd1, i, j);
                    in2 = isPixelInBitmap(bmd2, i, j);
                    if ( !( in1 || in2 ) )
                    {
                        // Pixel is in neither bitmap
                        bitmap1DiffPixels.setPixel32(i, j, TRANSPARENT);
                        bitmap2DiffPixels.setPixel32(i, j, TRANSPARENT);
                        continue;
                    }
                    // pixel is in at least one bitmap
                    totalPixelCount++;
                    if ( in1 && in2 )
                    {
                        // Pixel is in both bitmaps
                        overlapPixelCount++;
                        var pixel1:uint = bmd1.getPixel32(i, j);
                        var pixel2:uint = bmd2.getPixel32(i, j);
                        if (pixel1 == pixel2)
                        {
                            // Pixels are identical
                            matchingPixelCount++;
                            bitmap1DiffPixels.setPixel32(i, j, TRANSPARENT);
                            bitmap2DiffPixels.setPixel32(i, j, TRANSPARENT);
                        }
                        else
                        {
                            // Pixels are different - so part of Diff
                            nonMatchingPixelCount++;
                            nonMatchingPixelData.push( createPixelDiff(bmd1, bmd2, i, j) );
                            bitmap1DiffPixels.setPixel32(i, j, pixel1);
                            bitmap2DiffPixels.setPixel32(i, j, pixel2);
                        }
                    }
                    else
                    {
                        // Pixel is in one bitmap but not the other
                        nonMatchingPixelCount++;
                        nonMatchingPixelData.push( createPixelDiff(bmd1, bmd2, i, j) );
                        if (in1)
                        {
                            bitmap1DiffPixels.setPixel32(i, j, bmd1.getPixel32(i, j));
                            bitmap2DiffPixels.setPixel32(i, j, TRANSPARENT);
                        }
                        else if (in2)
                        {
                            bitmap1DiffPixels.setPixel32(i, j, TRANSPARENT);
                            bitmap2DiffPixels.setPixel32(i, j, bmd1.getPixel32(i, j));
                        }
                        else
                        {
                            throw new Error("BitmapUtil.getBitmapDiff() thinks a pixel exists in only one bitmap, but it appears to exist in neither");
                        }
                    }
                }
            }
            if ((matchingPixelCount + nonMatchingPixelCount) != totalPixelCount) throw new Error("BitmapUtil.getBitmapDiff()'s figures for matching and non-matching pixels don't add up to total pixels");
            var averageDiffAllPixels:Number = computeAverageColorDiffForAllPixels(nonMatchingPixelData, totalPixelCount);
            var averageDiffNonMatchingPixels:Number = computeAverageColorDiffForNonMatchingPixels(nonMatchingPixelData);
            var highestAbsoluteColorDiff:int = computeHighestAbsoluteColorDiff(nonMatchingPixelData);
            var totalAbsoluteColorDiff:int = computeTotalAbsoluteColorDiff(nonMatchingPixelData);
            var result:BitmapDiff = new BitmapDiff()
            if (nonMatchingPixelData.length)
            {
                var diffAreaComputer:DiffAreaComputer = new DiffAreaComputer(nonMatchingPixelData);
                var largestDiffAreaDimension:int = diffAreaComputer.getLargestDiffAreaDimension();
                diffAreaComputer.dispose();
                result.largestDiffAreaDimension = largestDiffAreaDimension;
            }
            else
            {
                result.largestDiffAreaDimension = 0;
            }
            result.bitmap1DiffPixels = bitmap1DiffPixels;
            result.bitmap2DiffPixels = bitmap2DiffPixels;
            result.totalPixelCount = totalPixelCount;
            result.overlapPixelCount = overlapPixelCount;
            result.matchingPixelCount = matchingPixelCount;
            result.nonMatchingPixelCount = nonMatchingPixelCount;
            result.nonMatchingPixelData = nonMatchingPixelData;
            result.averageDiffAllPixels = averageDiffAllPixels;
            result.averageDiffNonMatchingPixels = averageDiffNonMatchingPixels;
            result.highestAbsoluteColorDiff = highestAbsoluteColorDiff;
            result.totalAbsoluteColorDiff = totalAbsoluteColorDiff;
            return result;
        }

        /**
         * Returns the bitmap data for a given DisplayObject.
         *
         * @param target DisplayObject to get the bitmap data for
         *
         * @return BitmapData instance
         */
        public static function getDisplayObjectBitmapData(target:DisplayObject):BitmapData
        {
            var bd:BitmapData = new BitmapData(target.width, target.height);
            var m:Matrix = new Matrix();
            bd.draw(target, m);
            return bd;
        }

        /**
         * Check method, used to establish whether a pixel loc exists within a bitmap
         *
         * @param bitmap BitmapData instance
         * @param x Zero indexed int
         * @param y Zero indexed int
         *
         * @return Boolean
         */
        public static function isPixelInBitmap(bitmap:BitmapData, x:int, y:int):Boolean
        {
            if ( x < 0 ) return false;
            if ( x > (bitmap.width-1) ) return false;
            if ( y < 0 ) return false;
            if ( y > (bitmap.height-1) ) return false;
            return true;
        }

        /****************************************************************
         *
         *     Private Methods
         *
         ****************************************************************/

        private static function computeAverageColorDiffForAllPixels(nonMatchingPixelData:Array, totalPixelCount:int):Number
        {
            var result:Number = computeTotalAbsoluteColorDiff(nonMatchingPixelData) / totalPixelCount;
            return result;
        }

        private static function computeAverageColorDiffForNonMatchingPixels(nonMatchingPixelData:Array):Number
        {
            var result:Number = computeTotalAbsoluteColorDiff(nonMatchingPixelData) / nonMatchingPixelData.length;
            return result;
        }

        private static function computeHighestAbsoluteColorDiff(nonMatchingPixelData:Array):int
        {
            var result:int = 0;
            for each (var pixelDiff:Object in nonMatchingPixelData)
            {
                result = Math.max(result, pixelDiff.absoluteColorDiff);
            }
            return result;
        }

        private static function computeTotalAbsoluteColorDiff(nonMatchingPixelData:Array):int
        {
            var totalDiff:int = 0;
            for each (var pixelDiff:Object in nonMatchingPixelData)
            {
                totalDiff = totalDiff + pixelDiff.absoluteColorDiff;
            }
            return totalDiff;
        }

        private static function createPixelDiff(bmd1:BitmapData, bmd2:BitmapData, x:int, y:int):PixelDiff
        {
            var o:PixelDiff = new PixelDiff();
            o.x             = x;
            o.y             = y;
            o.color1        = bmd1.getPixel32(x,y);
            o.color2        = bmd2.getPixel32(x,y);
            var cd1:Object  = ColorUtil.separateColors(o.color1);
            var cd2:Object  = ColorUtil.separateColors(o.color2);
            o.alpha1        = cd1.alpha;
            o.alpha2        = cd2.alpha;
            o.alphaDiff     = cd1.alpha - cd2.alpha;
            o.alphaDiffAbs  = Math.abs( cd1.alpha - cd2.alpha );
            o.red1          = cd1.red;
            o.red2          = cd2.red;
            o.redDiff       = cd1.red - cd2.red;
            o.redDiffAbs    = Math.abs( cd1.red - cd2.red );
            o.green1        = cd1.green;
            o.green2        = cd2.green;
            o.greenDiff     = cd1.green - cd2.green;
            o.greenDiffAbs  = Math.abs( cd1.green - cd2.green );
            o.blue1         = cd1.blue;
            o.blue2         = cd2.blue;
            o.blueDiff      = cd1.blue - cd2.blue;
            o.blueDiffAbs   = Math.abs( cd1.blue - cd2.blue );
            o.absoluteColorDiff  = o.alphaDiffAbs + o.redDiffAbs + o.greenDiffAbs + o.blueDiffAbs;
            return o;
        }


    }
}