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
    import flexunit.framework.AssertionFailedError;

    /**
     * As suggested by its name, most (all?) of the asserts used
     * in Visual FlexUnit consist of instanciating and displaying
     * a visual component, then looking at that component's bitmap.
     * This may be followed in some cases by saving that bitmap to
     * a file as a "blessed" baseline for the component. This class
     * carries the information that's needed by VFU in order to do this.
     */
    public class BlessableError extends AssertionFailedError
    {
        /**
         * BitmapData that shows the tested component's appearance, as
         * determined by running visual test.
         */
        [Bindable]
        public var actualBMD:BitmapData;

        /**
         * BitmapData that shows the tested component's appearance, as
         * determined by running visual test.
         */
        [Bindable]
        public var actualBitmap:Bitmap;

        /**
         * This is the same testID that is passed into
         * VfuTestCase.testSequence.addAssertComponentMatchBaseline()
         * in your test methods.
         */
        [Bindable]
        public var testID:String;

        /**
         * URL where Visual FlexUnit hopes to find baseline image file.
         * If not found this class's subclass, MissingBaselineError,
         * carries the URL so that actualBitmap can be blessed and
         * saved to this loc.
         */
        [Bindable]
        public var url:String;

        /**
         * This prop is used in VfuTestRunnerBase.mxml - a kludge to facilitate
         * tacking VFU onto FlexUnit. Details on its use are in that file.
         */
        public var itemForFailureList:Object;

        /**
         * This prop is used in VfuTestRunnerBase.mxml - a kludge to facilitate
         * tacking VFU onto FlexUnit. Details on its use are in that file.
         */
        public var itemForAllTestsList:Object;

        public function BlessableError(message:String="")
        {
            super(message);
        }
    }
}