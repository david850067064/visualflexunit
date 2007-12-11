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
    import com.allurent.flexunit2.vfu.framework.testsequence.TestSequenceManager;

    import flash.events.Event;

    /**
     * This command simply executes a Function instance, provided by you.
     */
    public class DoAction extends TestSequenceCommand
    {
        private var _func:Function;

        /**
         * @param manager The TestSequenceManager that manages TestSequenceCommands such as this one
         * @param func    A function that you'd like to have executed
         */
        public function DoAction(manager:TestSequenceManager, func:Function):void
        {
            super(manager);
            _func = func;
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
            _func();
            _manager.commandFinished(this);
        }

        /**
         * @inheritDoc
         */
        override public function dispose():void
        {
            _func = null;
            super.dispose();
        }
    }
}