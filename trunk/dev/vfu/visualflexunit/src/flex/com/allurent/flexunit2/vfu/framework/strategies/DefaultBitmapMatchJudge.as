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

package com.allurent.flexunit2.vfu.framework.strategies
{
    import com.allurent.flexunit2.vfu.model.BitmapDiff;

    /**
     * Default 'BitmapMatchJudge' class used by Visual FlexUnit
     * to judge whether a component's appearance is close enough
     * to the test's saved baseline to pass. The goal is that
     * a result image that isn't visually distinguishable from its
     * baseline should pass, and that one that isn't shouldn't.
     */
    public class DefaultBitmapMatchJudge implements IBitmapMatchJudge
    {
        /**
         * I expect that the criteria used by this method will be
         * repeatedly tweaked so I'm not going to repeat it in this
         * method documentation. Look at the method body. :)
         */
        public function judgeMatch(diffInfo:BitmapDiff):Boolean
        {
            if (diffInfo.highestAbsoluteColorDiff > 70)
            {
                return false;
            }
            if (diffInfo.totalAbsoluteColorDiff > 200)
            {
                return false;
            }
            if (diffInfo.largestDiffAreaDimension > 4)
            {
                return false;
            }
            return true;
        }

    }
}