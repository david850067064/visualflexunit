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
     * This command waits for either an event to occur or a period of time to pass
     * without that event occurring. It can be used in cases where either option
     * would be acceptable. For example, typically we'd expect an update complete
     * event to come through after we tell Flash Player to validateNow(). But, in
     * fact, this doesn't always happen. Why not? Ask Flash Player; we don't know.
     * In any case, if we simply wait for the event the result will be a timeout
     * error. Instead, we accept either the event or the passage of a certain
     * period of time as an acceptable result. Note that this command is usually
     * also followed by a simple quiesce command, giving us a combination of event
     * plus wait, or a longer wait. See TestSequenceManager.refresh().
     */
    public class WaitForEventOrQuiesce extends TestSequenceCommand
    {
        private var _eventTarget:EventDispatcher;
        private var _eventType:String;

        /**
         * @param manager          The TestSequenceManager that manages TestSequenceCommands such as this one
         * @param target           An EventDispatcher instance from which you are awaiting an event
         * @param eventType        The event type that you are waiting for
         * @param quiesceDuration  The amount of time that needs to pass without the specified event occurring
         */
        public function WaitForEventOrQuiesce(manager:TestSequenceManager, target:EventDispatcher, eventType:String, timeout:int, quiesceDuration:int):void
        {
            super(manager, timeout, quiesceDuration);
            _eventTarget = target;
            _eventType = eventType;
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
            startQuiesceTimer(handleQuiesceEvent);
            startTimeoutTimer();
            _manager.addEventListener(_eventTarget, _eventType, handleAwaitedEvent);
        }

        /**
         * @inheritDoc
         */
        override public function dispose():void
        {
            _eventTarget = null;
            super.dispose();
        }

        /* ***************************************************************
         *
         *     Private Methods
         *
         ****************************************************************/

        private function handleAwaitedEvent(e:Event):void
        {
             _manager.commandFinished(this);
        }

         private function handleQuiesceEvent(e:TimerEvent):void
         {
             _manager.commandFinished(this);
         }
    }
}