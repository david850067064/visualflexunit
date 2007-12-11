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
     * This type is used by AssertComponentMatchBaseline to
     * decide whether a component's displayed bitmap is "close
     * enough" to a saved baseline. While we have a default
     * stategy - DefaultBitmapMatchJudge - test writer are free
     * to write their own classes that implement this interface
     * and to pass an instance of their custom class in when they
     * call VfuTestCase.testSequence.addAssertComponentMatchBaseline().
     */
    public interface IBitmapMatchJudge
    {
        /**
         * This method should return a boolean based in some way
         * on the contents of the information passed in via the
         * diffInfo arg.
         *
         * @param diffInfo An instance of com.allurent.flexunit2.vfu.model.BitmapDiff
         *
         * @see com.allurent.flexunit2.vfu.model.BitmapDiff
         */
        function judgeMatch(diffInfo:BitmapDiff):Boolean
    }
}