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
    import flash.events.Event;
    import mx.core.Application;

    import com.allurent.flexunit2.vfu.framework.testsequence.TestSequenceManager;

    /**
     * This command tells Visual FlexUnit to render all visual content
     * ASAP. Under the hood it is calling UIComponent.validateNow().
     * While Adobe's documentation for this method might lead you to
     * believe that it causes immediate rendering, this isn't actually
     * the case. Rendering occurs much more rapidly than it will if
     * this method isn't called but it isn't immediate - there are
     * clearly asynchronous processes involved some or all of the time.
     * For this reason this command should probably always be followed
     * by a quiesce command, before an assert command. You'll note that
     * TestSequenceManager.addRefresh() does this for you automatically.
     */
    public class ValidateNow extends TestSequenceCommand
    {
        /**
         * @param manager    The TestSequenceManager that manages TestSequenceCommands such as this one
         */
        public function ValidateNow(manager:TestSequenceManager):void
        {
            super(manager);
        }

        /* ***************************************************************
         *
         *     SuperClass Override Methods
         *
         ****************************************************************/

        /**
         * @inheritDoc
         */
        override public function execute():void
        {
            _manager.validateNow();
            _manager.commandFinished(this);
        }
    }
}