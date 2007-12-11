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
    import flash.events.EventDispatcher;

    import com.allurent.flexunit2.vfu.framework.testsequence.TestSequenceManager;

    /**
     * TODO: keep?
     *
     * This class simply dispatches an event provided by you.
     */
    public class DispatchEvent extends TestSequenceCommand
    {
        private var _target:EventDispatcher;
        private var _event:Event;

        /**
         * @param manager    The TestSequenceManager that manages TestSequenceCommands such as this one
         * @param target     An EventDispatcher instance from which you'd like your event to be dispatched
         * @param event      An Event instance that you've created
         */
        public function DispatchEvent(manager:TestSequenceManager, target:EventDispatcher, event:Event):void
        {
            super(manager);
            _target = target;
            _event = event;
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
            _target.dispatchEvent(_event);
            _manager.commandFinished(this);
        }

        /**
         * @inheritDoc
         */
        override public function dispose():void
        {
            _target = null;
            _event = null;
            super.dispose();
        }
    }
}