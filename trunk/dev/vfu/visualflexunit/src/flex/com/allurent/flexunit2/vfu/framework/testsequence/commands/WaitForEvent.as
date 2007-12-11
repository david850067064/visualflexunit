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
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;

    /**
     * Frankly, we're not sure whether this command is actually useful.
     * We've switched to using WaitForEventOrQuiesce as part of the
     * refresh process, and we don't currently use this anywhere else.
     * But we're keeping it on hand in case test writers want to wait
     * for an event, and throw an error if it doesn't arrive. Be
     * aware that events dispatched as a result of a previous command
     * may have already occurred before this command is executed, and
     * approach its use with an experimental attitude, if at all.
     */
    public class WaitForEvent extends TestSequenceCommand
    {
        private var _eventTarget:EventDispatcher;
        private var _eventType:String;
        private var _testFunc:Function;

        /**
         * @param manager    The TestSequenceManager that manages TestSequenceCommands such as this one
         * @param target     An EventDispatcher instance from which you are awaiting an event
         * @param eventType  The event type that you are waiting for
         * @param timeout    The amount of time that you'd like this command to wait before failing
         * @param testFunc   A test function that you'd like the command to call when the event is received
         */
        public function WaitForEvent(manager:TestSequenceManager, target:EventDispatcher, eventType:String, timeout:int, testFunc:Function):void
        {
            super(manager, timeout);
            _eventTarget = target;
            _eventType = eventType;
            _testFunc = testFunc;
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
            startTimeoutTimer();
            _manager.addEventListener(_eventTarget, _eventType, handleAwaitedEvent);
        }

        /**
         * @inheritDoc
         */
        override public function dispose():void
        {
            _eventTarget = null;
            _testFunc = null;
            super.dispose();
        }

        /* ***************************************************************
         *
         *     Private Methods
         *
         ****************************************************************/

        private function handleAwaitedEvent(e:Event):void
        {
            if (e.type != _eventType) throw new Error("WaitForEvent.handleAwaitedEvent() has received an unexpected event type");
            if (_testFunc is Function)
            {
                _testFunc(e);
            }
            _manager.commandFinished(this);
        }
    }
}