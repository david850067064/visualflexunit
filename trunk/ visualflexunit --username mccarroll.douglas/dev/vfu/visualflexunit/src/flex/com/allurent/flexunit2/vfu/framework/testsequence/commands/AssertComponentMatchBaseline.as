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

package com.allurent.flexunit2.vfu.framework.testsequence.commands
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import mx.controls.SWFLoader;
    import mx.core.Application;

    import flexunit.framework.AssertionFailedError;

    import com.allurent.flexunit2.vfu.errors.BitmapNotMatchBaselineError;
    import com.allurent.flexunit2.vfu.errors.MissingBaselineError;
    import com.allurent.flexunit2.vfu.framework.strategies.IBitmapMatchJudge;
    import com.allurent.flexunit2.vfu.framework.testsequence.TestSequenceManager;
    import com.allurent.flexunit2.vfu.model.BitmapDiff;
    import com.allurent.flexunit2.vfu.utils.bitmap.BitmapUtil;

    /**
     * Determines whether a displayed component's appearance matches appearance
     * of a bitmap stored as a baseline file. Actual decision is made by an instance
     * of IBitmapMatchJudge, passed into constructor, so this class's responsibilities
     * mainly consist of loading saved baseline file and translating match failures
     */
    public class AssertComponentMatchBaseline extends TestSequenceCommand
    {
        private var _comp:DisplayObject;
        private var _judgmentStrategy:IBitmapMatchJudge;
        private var _loader:SWFLoader;
        private var _testID:String;
        private var _url:String;

        /**
         * @param manager The TestSequenceManager that manages TestSequenceCommands such as this one
         * @param comp Component being tested
         * @param testID A simple ID passed in from your test function. Should be unique
         * within the test function. Used in naming baseline files.
         * @param timeout The amount of time that you'd like this command to wait before failing
         * @param judgmentStrategy The IBitmapMatchJudge instance that will decide whether
         * the appearance of the component that you've created and displayed is close
         * enough to the stored baseline. You can create your own or, if you don't, a
         * default version is created by TestSequenceManager.
         *
         * @inheritDoc
         */
        public function AssertComponentMatchBaseline(manager:TestSequenceManager, comp:DisplayObject, testID:String, timeout:int, judgmentStrategy:IBitmapMatchJudge):void
        {
            super(manager, timeout);
            _comp = comp;
            _testID = testID;
            _judgmentStrategy = judgmentStrategy;
        }

        /* ***************************************************************
         *
         *     SuperClass Override Methods
         *
         ****************************************************************/

        /**
         * Creates a SWFLoader and starts the image loading process.
         *
         * @inheritDoc
         */
        override public function execute():void
        {
            startTimeoutTimer();
            _url = Application.application.baselineFolderPath + "/" + _testID + ".png";
            _loader = new SWFLoader();
            _manager.addEventListener(_loader, Event.COMPLETE, handleCompleteEvent);
            _manager.addEventListener(_loader, IOErrorEvent.IO_ERROR, handleIOErrorEvent);
            _manager.addEventListener(_loader, SecurityErrorEvent.SECURITY_ERROR, handleSecurityErrorEvent);
            _manager.addDisplayObject(_loader);
            _loader.load(_url);
        }

        /**
         *
         *
         * @inheritDoc
         */
        override public function dispose():void
        {
            _comp = null;
            _loader = null;
            super.dispose();
        }

        /* ***************************************************************
         *
         *     Private Methods
         *
         ****************************************************************/

        private function handleCompleteEvent(e:Event):void
        {
            var bd:BitmapData = BitmapUtil.getDisplayObjectBitmapData(_comp);
            var bitmapDiff:BitmapDiff = BitmapUtil.getBitmapDiff(e.currentTarget.content.bitmapData, bd);
            if (!_judgmentStrategy.judgeMatch(bitmapDiff))
            {
                var error:BitmapNotMatchBaselineError = new BitmapNotMatchBaselineError(_manager.currentTestDescription + " failed" );
                error.expectedBMD = e.currentTarget.content.bitmapData;
                error.expectedBitmap = new Bitmap(e.currentTarget.content.bitmapData);
                error.actualBMD = bd;
                error.actualBitmap = new Bitmap(bd);
                error.testID = _testID;
                error.url = _url;
                error.actualDiffBMD = bitmapDiff.bitmap2DiffPixels;
                error.averageDiffAllPixels = bitmapDiff.averageDiffAllPixels;
                error.averageDiffNonMatchingPixels = bitmapDiff.averageDiffNonMatchingPixels;
                error.expectedDiffBMD = bitmapDiff.bitmap1DiffPixels;
                error.highestAbsoluteColorDiff = bitmapDiff.highestAbsoluteColorDiff;
                error.largestDiffAreaDimension = bitmapDiff.largestDiffAreaDimension;
                error.matchingPixelCount = bitmapDiff.matchingPixelCount;
                error.nonMatchingPixelCount = bitmapDiff.nonMatchingPixelCount;
                error.nonMatchingPixelData = bitmapDiff.nonMatchingPixelData;
                error.overlapPixelCount = bitmapDiff.overlapPixelCount;
                error.percentDifferent = bitmapDiff.percentDifferent;
                error.percentIdentical = bitmapDiff.percentIdentical;
                error.totalAbsoluteColorDiff = bitmapDiff.totalAbsoluteColorDiff;
                error.totalPixelCount = bitmapDiff.totalPixelCount;
                _manager.commandFinished(this, error);
            }
            else
            {
                _manager.commandFinished(this);
            }
        }

        private function handleIOErrorEvent(e:IOErrorEvent):void
        {
            var bd:BitmapData = BitmapUtil.getDisplayObjectBitmapData(_comp);
            var error:MissingBaselineError = new MissingBaselineError(_manager.currentTestDescription + " was unable to load baseline image at " + _url);
            error.actualBMD     = bd;
            error.actualBitmap  = new Bitmap(bd);
            error.testID        = _testID;
            error.url           = _url;
            _manager.commandFinished(this, error);
        }

        private function handleSecurityErrorEvent(e:SecurityErrorEvent):void
        {
            var bd:BitmapData = BitmapUtil.getDisplayObjectBitmapData(_comp);
            var error:AssertionFailedError = new AssertionFailedError( "securityError: " + String(_loader.source) );
            _manager.commandFinished(this, error);
        }

    }
}