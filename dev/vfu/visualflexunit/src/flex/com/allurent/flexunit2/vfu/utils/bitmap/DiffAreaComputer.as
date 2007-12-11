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
    import com.allurent.flexunit2.vfu.IDisposable;
    import com.allurent.flexunit2.vfu.model.PixelDiff;
    import com.allurent.flexunit2.vfu.utils.misc.TwoDimensionalDictionary;

    import flash.geom.Point;
    import flash.geom.Rectangle;

    /**
    * This class is passed an array of PixelDiff instances and figures out
    * a) how many areas of contiguous pixels the array defines, and b) how large
    * they are. At present we only use this to getLargestDiffAreaDimension()
    * but it would be relatively easy to add getDiffAreaCount(),
    * getDiffAreaRect(index:int), etc.
    */
    public class DiffAreaComputer implements IDisposable
    {
        /*
        * Pixels are marked on this grid once they are determined to be
        * a member of a specific contiguous group. Each pixel's xy loc is set
        * to the group's ID.
        */
        private var _mappedPixels:TwoDimensionalDictionary;

        /*
        * All diff pixels are marked on this grid at startup by setting
        * the pixel's xy loc's value to the pixels BitmapDiff instance. At
        * present this information isn't used, and I could just as easily
        * have set these locs to 'true' but referencing the loc's PixelDiff
        * costs nothing and may be useful in the future.
        */
        private var _diffPixels:TwoDimensionalDictionary;

        /*
        * As contiguous group's rects are discovered they are added to
        * this object. Property names are groups IDs, property values
        * instances of flash.geom.Rectangle.
        */
        private var _diffRects:Object;
        private var _currentPixelGroupID:int = 0;
        private var _maxDimensions:Point;

        /**
         * @param nonMatchingPixelData An Array of PixelDiff instances
         */
        public function DiffAreaComputer(nonMatchingPixelData:Array):void
        {
            _maxDimensions = computeMaxDimensions(nonMatchingPixelData);
            _mappedPixels = new TwoDimensionalDictionary(_maxDimensions.x, _maxDimensions.y);
            _diffPixels = createDiffPixelsDictionary(nonMatchingPixelData);
            _diffRects = new Object();
            for (var i:int = 0; i < nonMatchingPixelData.length; i++)
            {
                var pd:PixelDiff = nonMatchingPixelData[i];
                if (!isPixelMapped(pd.x, pd.y))
                {
                    mapPixelGroup(pd.x, pd.y);
                }
            }
        }

        /* ***************************************************************
         *
         *     Public Methods
         *
         ****************************************************************/

        /**
        * @inheritDoc
        */
        public function dispose():void
        {
            _mappedPixels.dispose();
            _diffPixels.dispose();
            _diffRects = null;
        }

        /**
        * @return Returns largest single dimension (height or width) from
        * the set of all contiguous pixel groups.
        */
        public function getLargestDiffAreaDimension():int
        {
            var result:int = 0;
            for each (var diffRect:Rectangle in _diffRects)
            {
                result = Math.max(result, diffRect.height + 1);
                result = Math.max(result, diffRect.width + 1);
            }
            return result;
        }

        /****************************************************************
         *
         *     Private Methods
         *
         ****************************************************************/

        /*
         * Computes size for instances of TwoDimensionalDictionary used by class.
         * We don't know (or care) how large the original compared images were.
         * Instead we just create grids that are large enough to contain all diff
         * pixels.
         *
         * Note that we switch from zero-based positions to one-based dimension sizes
         */
        private function computeMaxDimensions(nonMatchingPixelData:Array):Point
        {
            var result:Point = new Point(0, 0);
            for (var i:int = 0; i < nonMatchingPixelData.length; i++)
            {
                var pd:PixelDiff = nonMatchingPixelData[i];
                result.x = Math.max(result.x, pd.x);
                result.y = Math.max(result.y, pd.y);
            }
            result.x ++;
            result.y ++;
            return result;
        }

        private function createDiffPixelsDictionary(nonMatchingPixelData:Array):TwoDimensionalDictionary
        {
            var result:TwoDimensionalDictionary = new TwoDimensionalDictionary(_maxDimensions.x, _maxDimensions.y);
            for (var i:int = 0; i < nonMatchingPixelData.length; i++)
            {
                var pd:PixelDiff = nonMatchingPixelData[i];
                result.setValue(pd.x, pd.y, pd);
            }
            return result;
        }

        private function isPixelADiffPixel(x:int, y:int):Boolean
        {
            return (_diffPixels.getValue(x, y) == null) ? false : true;
        }


        private function isPixelMapped(x:int, y:int):Boolean
        {
            return (_mappedPixels.getValue(x, y) == null) ? false : true;
        }

        /*
         * It would have been -much- simpler to write this as a regressive function
         * but ActionScript's limit on regression (1000 calls, modifiable via a compiler
         * setting) has forced me to use a loop instead.
         *
         * The basic sequence for this method is to process each candidate pixel by:
         *     1st: Examining self. If not a diff pixel simply return to previous pixel.
         *     2nd: Examining contiguous pixels, unless already examined, in this
         *          order: left, up, right, down.
         *     3rd: Marking self as examined and return to previous pixel.
         *
         * Note: For the present, I'm defining 'contiguous' as pixels which share an
         *       edge, not those at a 45 degree angle.
         *
         * The unfinishedPixels Array var is used as a stack to keep track of pixels
         *     whose examination has begun but has not been finished. Given the sequence
         *     explained above we could imagine the chain of execution starting
         *     with pixel A, moving to its lefthand neighbor pixel B, the to B's
         *     lefthand neighbor pixel C. At this point unfinishedPixels would
         *     contain A and B. When C is finished, B would be popped off the Array
         *     and its processing would continue.
         *
         * We remember each pixel's progress in this process by setting the pixel's value in
         *     a temporary TwoDimensionalDictionary var (pixelExamStatusRecorder), using
         *     these status values:
         *
         *     0:    Pixel hasn't been examined.
         *     1:    Pixel's Left pixel is currently being examined, or some branch off of
         *           Left pixel.
         *     2:    Pixel's Up pixel is currently being examined, or some branch off of
         *           Up pixel.
         *     3:    Pixel's Right pixel is currently being examined, or some branch off of
         *           Right pixel.
         *     4:    Pixel's Down pixel is currently being examined, or some branch off of
         *           Down pixel.
         *     5:    Pixel's examination is complete.
         */
        private function mapPixelGroup(startX:int, startY:int):void
        {
            const UNEXAMINED:int    = 0;
            const EXAMINE_LEFT:int  = 1;
            const EXAMINE_UP:int    = 2;
            const EXAMINE_RIGHT:int = 3;
            const EXAMINE_DOWN:int  = 4;
            const FINISHED:int      = 5;

            _currentPixelGroupID ++;
            var currentGroupRect:Rectangle = new Rectangle(startX, startY, 0, 0);
            var currentPixel:Point = new Point(startX, startY);
            var unfinishedPixels:Array = new Array();
            var pixelExamStatusRecorder:TwoDimensionalDictionary = new TwoDimensionalDictionary(_maxDimensions.x, _maxDimensions.y);
            var exitPixelReturnFlag:Boolean;
            var continueLooping:Boolean = true;
            while (continueLooping)
            {
                if (!pixelExamStatusRecorder.areCoordinatesValid(currentPixel.x, currentPixel.y))
                {
                    // Pixel is outside of image, don't go here!
                    exitPixel();
                    continue;
                }
                else if (!isPixelADiffPixel(currentPixel.x, currentPixel.y))
                {
                    // Pixel is inside image but isn't a diff pixel. Don't go here either.
                    exitPixel();
                    continue;
                }
                else if (getPixelStatus(currentPixel) == FINISHED)
                {
                    // Pixel is completely examined. Don't reexamine.
                    exitPixel();
                    continue;
                }
                else
                {
                    // Pixel is a diff pixel, isn't outside the image, and either hasn't
                    // been started or isn't finished. Actually, it may be finished but
                    // it hasn't been officially stamped as finished. If so, that stamp will
                    // occur shortly.
                    incrementPixelStatus(currentPixel);
                    // We just incremented, so status now shows 'what we should do next'
                    switch (getPixelStatus(currentPixel))
                    {
                        case EXAMINE_LEFT:
                            setCurrPixelToAdjoiningPixelIfUnexamined();
                            continue;
                        case EXAMINE_UP:
                            setCurrPixelToAdjoiningPixelIfUnexamined();
                            continue;
                        case EXAMINE_RIGHT:
                            setCurrPixelToAdjoiningPixelIfUnexamined();
                            continue;
                        case EXAMINE_DOWN:
                            setCurrPixelToAdjoiningPixelIfUnexamined();
                            continue;
                        case FINISHED:
                            _mappedPixels.setValue(currentPixel.x, currentPixel.y, _currentPixelGroupID);
                            exitPixelReturnFlag = exitPixel();
                            if (exitPixelReturnFlag)
                            {
                                // We just exited from the start pixel - stop the loop - we
                                // don't need to look at any more pixels
                                continueLooping = false;
                                pixelExamStatusRecorder.dispose();
                            }
                            continue;
                        default:
                            throw new Error("Pixel's status not handled by switch case");
                    }
                }
            }

            /*
             * Nested function exitPixel() encapsulates processes that occur when we're done
             * looking at a pixel (and its branch pixels).
             *
             *     1st:  If pixel is FINISHED, extend currentGroupRect to include pixel's loc, if
             *           it doesn't already do so.
             *
             *     2nd:  If there are any pixel locs remaining in unfinishedPixels, pop the most
             *           recent off and set currentPixel to that loc. The next iteration of
             *           mapPixelGroup()'s main loop will resume the examination of that pixel.
             *
             *           If not, we're exiting the starting point (pixel) of the entire
             *           exploratory process that was started when mapPixelGroup() was
             *           called. In this case we record the rect that we've discovered and exit.
             */
            function exitPixel():Boolean
            {
                switch (getPixelStatus(currentPixel))
                {
                    case FINISHED:
                        currentGroupRect.left   = Math.min(currentGroupRect.left,   currentPixel.x);
                        currentGroupRect.top    = Math.min(currentGroupRect.top,    currentPixel.y);
                        currentGroupRect.right  = Math.max(currentGroupRect.right,  currentPixel.x);
                        currentGroupRect.bottom = Math.max(currentGroupRect.bottom, currentPixel.y);
                        break;
                    case UNEXAMINED:
                        // We're backing out of a pixel that hasn't been and shouldn't be examined
                        break;
                    default:
                        throw new Error("exitPixel() is exiting a pixel that hasn't whose neighbors haven't been explored");
                }
                if (unfinishedPixels.length)
                {
                    var revertToPixel:Point = unfinishedPixels.pop();
                    currentPixel.x = revertToPixel.x;
                    currentPixel.y = revertToPixel.y;
                    return false;
                }
                else
                {
                    // The unfinishedPixels array has zero remaining elements, which indicates
                    // that we're currently exiting mapPixelGroup()'s start pixel. Let's do a
                    // quick check, then add the rect we've explored to _diffRects, and let the
                    // calling code know that it's work is about over.
                    if ((currentPixel.x != startX) || (currentPixel.y != startY))
                    {
                        throw new Error("exitPixel() erroneously believes that it is exiting mapPixelGroup()'s start pixel");
                    }
                    _diffRects[_currentPixelGroupID] = currentGroupRect;
                    return true;
                }
            }

            function getPixelStatus(point:Point):int
            {
                if (pixelExamStatusRecorder.areCoordinatesValid(point.x, point.y))
                {
                    var result:int = int(pixelExamStatusRecorder.getValue(point.x, point.y));
                    return result;
                }
                else
                {
                    return UNEXAMINED;
                }
            }

            function incrementPixelStatus(point:Point):void
            {
                var value:int = int(pixelExamStatusRecorder.getValue(point.x, point.y));
                value ++;
                pixelExamStatusRecorder.setValue(point.x, point.y, value);
            }

            function setCurrPixelToAdjoiningPixelIfUnexamined():void
            {
                var candidatePixel:Point = new Point(currentPixel.x, currentPixel.y);
                switch (getPixelStatus(currentPixel))
                {
                    case EXAMINE_LEFT:
                        candidatePixel.x --;
                        break;
                    case EXAMINE_UP:
                        candidatePixel.y --;
                        break;
                    case EXAMINE_RIGHT:
                        candidatePixel.x ++;
                        break;
                    case EXAMINE_DOWN:
                        candidatePixel.y ++;
                        break;
                    default:
                        throw new Error("currentPixel's status not handled by switch case");
                }
                if (getPixelStatus(candidatePixel) == UNEXAMINED)
                {
                    var prevPixel:Point = new Point(currentPixel.x, currentPixel.y);
                    currentPixel.x = candidatePixel.x;
                    currentPixel.y = candidatePixel.y;
                    unfinishedPixels.push(prevPixel);
                }
                else
                {
                    // Candidate pixel has already been traversed. We don't branch to it.
                    // The only way that we should go there is by returning to it. So
                    // we don't change currentPixel. On the next loop iteration currentPixel's
                    // status will be incremented and we will explore in another direction
                    // or finish.
                }
            }
        }
    }
}







