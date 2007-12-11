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
    import com.allurent.flexunit2.vfu.framework.VfuTestCase;
    import com.allurent.flexunit2.vfu.model.BitmapDiff;
    import com.allurent.flexunit2.vfu.utils.bitmap.BitmapUtil;

    import flash.display.BitmapData;

    public class BitmapUtilTest extends VfuTestCase
    {
        public function BitmapUtilTest(methodName:String=null)
        {
            super(methodName);
        }

        override public function setUp():void
        {
        }

        override public function tearDown():void
        {
        }

        public function testAreBitmapsIdentical():void
        {
            var bm1:BitmapData = new BitmapData( 1000, 1, false );
            var bm2:BitmapData = new BitmapData( 1000, 1, false );
            assertTrue(   BitmapUtil.areBitmapsIdentical(bm1, bm2));
            bm2.setPixel(0,0,0xff000001);
            assertFalse(  BitmapUtil.areBitmapsIdentical(bm1, bm2));
            var bm3:BitmapData = new BitmapData( 1001, 1, false );
            assertFalse(  BitmapUtil.areBitmapsIdentical(bm1, bm3));
        }

        /**
         * Returns an Object with these props:
         *    bitmap1DiffPixels:BitmapData - Shows pixels in bitmap1 that aren't precisely matched
         *                                   in bitmap2. All other pixels are set to transparent.
         *    bitmap2DiffPixels:BitmapData - Shows pixels in bitmap2 that aren't precisely matched
         *                                   in bitmap1. All other pixels are set to transparent.
         *    totalPixels:int              - The number of pixels that exist in either or both of
         *                                   bitmap1 and bitmap2
         *    overlapPixelCount:int        - The number of pixel locations that are included in both bitmaps
         *    matchingPixels:int           - The number of pixels that exist in both bitmaps and match precisely
         *    differentPixels:int          - The number of pixels that exist in either or both bitmaps but
         *                                   don't match (i.e. have different color or alpha values in the two
         *                                   bitmaps)
         *    percentIdentical:Number      - The percent of pixels in the two bitmaps that are identical.
         *                                   Areas in either bitmap that don't overlap the other bitmap
         *                                   are considered be part of total area and to be non-identical.
         *
         * @param bitmap1:BitmapData
         * @param bitmap2:BitmapData
         */
        public function testGetDiffInfo():void
        {
            var diffInfo:BitmapDiff;
            var bm1:BitmapData = new BitmapData( 100, 1, false );
            var bm2:BitmapData = new BitmapData( 100, 1, false );
            diffInfo = BitmapUtil.getBitmapDiff(bm1,bm2);
            assertEquals(100, diffInfo.totalPixelCount             );
            assertEquals(100, diffInfo.overlapPixelCount           );
            assertEquals(100, diffInfo.matchingPixelCount          );
            assertEquals(0,   diffInfo.nonMatchingPixelCount       );
            assertEquals(100, diffInfo.percentIdentical            );
            assertEquals(0,   diffInfo.percentDifferent            );
            assertEquals(0,   diffInfo.nonMatchingPixelData.length );
            var bm3:BitmapData = new BitmapData( 1, 100, false );
            diffInfo = BitmapUtil.getBitmapDiff(bm1,bm3);
            assertEquals(       199,           diffInfo.totalPixelCount             );
            assertEquals(       1,             diffInfo.overlapPixelCount           );
            assertEquals(       1,             diffInfo.matchingPixelCount          );
            assertEquals(       198,           diffInfo.nonMatchingPixelCount       );
            assertNumberEquals( (  1/199)*100, diffInfo.percentIdentical            );
            assertNumberEquals( (198/199)*100, diffInfo.percentDifferent            );
            assertEquals(        198,          diffInfo.nonMatchingPixelData.length );
            var bm4:BitmapData = new BitmapData( 1000, 1000, false );
            var bm5:BitmapData = new BitmapData( 1000, 1000, false );
            bm5.setPixel(0,0,0xff000001);
            diffInfo = BitmapUtil.getBitmapDiff(bm4,bm5);
            assertEquals(       1000000,              diffInfo.totalPixelCount             );
            assertEquals(       1000000,              diffInfo.overlapPixelCount           );
            assertEquals(       999999,               diffInfo.matchingPixelCount          );
            assertEquals(       1,                    diffInfo.nonMatchingPixelCount       );
            assertNumberEquals( (999999/1000000)*100, diffInfo.percentIdentical            );
            assertNumberEquals( (     1/1000000)*100, diffInfo.percentDifferent            );
            assertEquals(        1,                   diffInfo.nonMatchingPixelData.length );
            assertEquals(        0,                   diffInfo.nonMatchingPixelData[0].x   );
            assertEquals(        0,                   diffInfo.nonMatchingPixelData[0].y   );
            var bm6:BitmapData = new BitmapData( 500, 500, false );
            var bm7:BitmapData = new BitmapData( 500, 500, false );
            // Draw diagonal line
            for (var i:int = 100; i <= 200; i++)
            {
                bm7.setPixel(i, i, 0xff000001);
            }
            diffInfo = BitmapUtil.getBitmapDiff(bm6,bm7);
            assertEquals(1, diffInfo.largestDiffAreaDimension);
            // Draw rect
            for (var k:int = 300; k <= 450; k++)
            {
                for ( var l:int = 300; l <= 400; l++)
                {
                    bm7.setPixel(k, l, 0xff000001);
                }
            }
            diffInfo = BitmapUtil.getBitmapDiff(bm6,bm7);
            assertEquals(151, diffInfo.largestDiffAreaDimension);
            // Draw straight line
            for (var m:int = 200; m <= 400; m++)
            {
                bm7.setPixel(m, 490, 0xff000001);
            }
            diffInfo = BitmapUtil.getBitmapDiff(bm6,bm7);
            assertEquals(201, diffInfo.largestDiffAreaDimension);
        }

        public function testIsPixelInBitmap():void
        {
            var bm1:BitmapData = new BitmapData( 100, 10, false );
            assertTrue( BitmapUtil.isPixelInBitmap(bm1,0,0));
            assertTrue( BitmapUtil.isPixelInBitmap(bm1,0,9));
            assertTrue( BitmapUtil.isPixelInBitmap(bm1,99,0));
            assertTrue( BitmapUtil.isPixelInBitmap(bm1,99,9));
            assertFalse(BitmapUtil.isPixelInBitmap(bm1,0,-1));
            assertFalse(BitmapUtil.isPixelInBitmap(bm1,-1,0));
            assertFalse(BitmapUtil.isPixelInBitmap(bm1,0,10));
            assertFalse(BitmapUtil.isPixelInBitmap(bm1,100,0));
            assertFalse(BitmapUtil.isPixelInBitmap(bm1,1000000,1000000));
        }

    }
}