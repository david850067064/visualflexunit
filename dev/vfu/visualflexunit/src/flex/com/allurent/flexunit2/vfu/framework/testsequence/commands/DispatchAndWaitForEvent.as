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

    import flexunit.framework.AssertionFailedError;

    /**
     * This class dispatches an event (provided by you) then waits
     * and confirms that the event has indeed been dispatched. We
     * combine these two functions into one command because:
     *
     * <p>1. It doesn't work to execute a DispatchEvent command, then
     * execute a WaitForEvent command when the former has finished.
     * In most cases the first event will have finished before the second
     * command is executed.</p>
     *
     * <p>2. It doesn't work to execute a WaitForEvent command, then execute
     * a DispatchEvent command when the former is finished. In this case the
     * first command will wait patiently until it times out, then a) abort the
     * test sequence, and b) report an error.</p>
     *
     * @inheritDoc
     */
    public class DispatchAndWaitForEvent extends TestSequenceCommand
    {
    /*
     * TODO: On the other hand, it's open to question whether we really need this
     * class at all. Do we really need to confirm that the events we launch
     * are dispatched? Doing this suggests a lack of faith in the Flash player's
     * fundamental event handling infrastructure.
     */
        private var _target:EventDispatcher;
        private var _event:Event;
        private var _eventType:String;
        private var _testFunc:Function;

        /**
         * @param target       An EventDispatcher instance from which you'd like your event to be dispatched
         * @param event        An Event instance that you've created
         * @param timeout      The amount of time that you'd like this command to wait before failing
         * @param quiesceTime  The amount of "quiet time" you want to occur before the command finishes
         * @param testFunc     A test function that you'd like the command to call when the event is received
         * @inheritDoc
         */
        public function DispatchAndWaitForEvent(manager:TestSequenceManager, target:EventDispatcher, event:Event, timeout:int, testFunc:Function):void
        {
            super(manager, timeout);
            _target = target;
            _event = event;
            _eventType = event.type;
            _testFunc = testFunc;
        }

        /****************************************************************
         *
         *     Public Methods
         *
         ****************************************************************/

        /**
         *
         */
        public function handleDispatchedEvent(e:Event):void
        {
            if (e.type != _eventType) throw new Error("DispatchAndWaitForEvent.handleDispatchedEvent() has received an unexpected event type");
            if (_testFunc is Function)
            {
                _testFunc(e);
            }
            _manager.commandFinished(this);
        }

        /****************************************************************
         *
         *     SuperClass Override Methods
         *
         ****************************************************************/

        /**
         * This method starts the timeout timer and dispatches the event.
         *
         * @inheritDoc
         */
        override public function execute():void
        {
            // For some reason, when I have a test method that creates two of these
            // commands as part of the test sequence, and I put a breakpoint here,
            // it only gets hit once. But a trace statement traces twice. I assume
            // that this is a problem with FlexBuilder's debugger. I'm leaving this
            // comment here because I just spent numerous minutes figuring this out
            // and don't want to do it again in a month or a year.
            startTimeoutTimer();
            _manager.addEventListener(_target, _event.type, handleDispatchedEvent);
            _target.dispatchEvent(_event);
        }

        /**
         *
         *
         * @inheritDoc
         */
        override public function dispose():void
        {
            _target = null;
            _event = null;
            _testFunc = null;
            super.dispose();
        }
    }
}