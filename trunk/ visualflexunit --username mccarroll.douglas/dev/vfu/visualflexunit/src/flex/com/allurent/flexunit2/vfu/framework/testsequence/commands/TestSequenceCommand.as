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
    import com.allurent.flexunit2.vfu.IDisposable;
    import com.allurent.flexunit2.vfu.framework.testsequence.TestSequenceManager;

    import flexunit.framework.AssertionFailedError;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    /**
     * This class serves as superclass for all commands used by TestSequenceManager
     * and can be subclassed if you'd like to add functionality to Visual FlexUnit.
     * If you decide to go this route, we suggest that you:
     *    - Study both this class and existing subclasses (i.e. the contents of
     *      com.allurent.flexunit2.vfu.framework.testsequence.commands)
     *    - Study the Public Methods Used By Test Writers section of
     *      com.allurent.flexunit2.vfu.framework.testsequence.TestSequenceManager.
     *      You'll want to add one or more methods here.
     *
     * Important: If you want errors to be reported in FlexUnit's results panel,
     * rather than being displayed in Flash Player's uncaught error dialogue,
     * follow this procedure:
     *    - Create an instance of AssertionFailedError or some subclass of same
     *    - End command execution with code like this:
     *             _manager.commandFinished(this, myError);
     */
    public class TestSequenceCommand extends EventDispatcher implements IDisposable
    {
        protected var _manager:TestSequenceManager;

        private var _quiesceDuration:int;
        private var _quiesceTimer:Timer;
        private var _quiesceTimerListener:Function;
        private var _timeout:int;
        private var _timeoutTimer:Timer;
        private var _timeoutTimerListener:Function;

        /**
         * @param manager          The TestSequenceManager that manages TestSequenceCommands.
         * @param timeout          The period in milliseconds after which the command will throw an error,
         *                         if not completed. This only needs to be passed in if your command launches
         *                         asynchronous operations.
         * @param quiesceDuration  Some subclasses of this class wait for a period of quiet. If so, the required milliseconds of quiet are passed in here.
         */
        public function TestSequenceCommand(manager:TestSequenceManager, timeout:int = 0, quiesceDuration:int = 0):void
        {
            _manager = manager;
            _timeout = timeout;
            _quiesceDuration = quiesceDuration;
        }

        /* ***************************************************************
         *
         *     Public Methods
         *
         ****************************************************************/

        /**
         * Subclasses should implement the event. This is where you do what your command does
         * (for synchronous actions) and/or put your command's processes in motion (for
         * asynchronous actions)
         */
        public function execute():void
        {
            throw new Error("All TestSequenceCommand subclasses must extend execute");
        }

        /**
         * Subclasses that extend this method should do any of the following that
         * are applicable:
         *
         *   - If your command class's vars reference any non-primitive objects, the
         *     vars should be set to null.
         *   - If this will remove the last remaining reference to a complex object that
         *     also needs its dispose() (or equivalent) method called, you should do
         *     this before nulling the var.
         *   - One thing that you may or may not need to do is to unregister your event
         *     listeners. You'll note that the code in this method takes care of shutting
         *     down this class's internal timers. Also, any event listeners that you
         *     initialized using TestSequenceManager.addEventListener()
         *     ("_manager.addEventListener(..)") are automatically unregistered by the
         *     manager. That said, if your subclass registers event listeners through
         *     any other means, unregister them here.
         *   - This isn't an exhaustive list. For more details on dispose() methods see
         *     Moock's Essential ActionScript 3.0, chapter 14.
         */
        public function dispose():void
        {
            _manager = null;
            if (_quiesceTimer)
            {
                if (_quiesceTimerListener is Function)
                {
                    _quiesceTimer.removeEventListener(TimerEvent.TIMER, _quiesceTimerListener);
                }
                _quiesceTimer.stop();
                _quiesceTimer = null;
            }
            if (_timeoutTimer)
            {
                if (_timeoutTimerListener is Function)
                {
                    _timeoutTimer.removeEventListener(TimerEvent.TIMER, _timeoutTimerListener);
                }
                _timeoutTimer.stop();
                _timeoutTimer = null;
            }
        }

        /* ***************************************************************
         *
         *     Protected Methods
         *
         ****************************************************************/

        protected function restartQuiesceTimer():void
        {
            _quiesceTimer.stop();
            _quiesceTimer.start();
        }

        protected function restartTimeoutTimer():void
        {
            _timeoutTimer.stop();
            _timeoutTimer.start();
        }

        protected function startQuiesceTimer(listener:Function):void
        {
            if (_quiesceTimer) throw new Error("TestSequenceCommand attempting to start quiesceTimer that is already running");
            _quiesceTimer = new Timer(_quiesceDuration, 1);
            _quiesceTimer.addEventListener(TimerEvent.TIMER, listener);
            _quiesceTimer.start();
        }

        protected function startTimeoutTimer():void
        {
            if (_timeoutTimer) throw new Error("TestSequenceCommand attempting to start timeoutTimer that is already running");
            _timeoutTimer = new Timer(_timeout, 1);
            _timeoutTimer.addEventListener(TimerEvent.TIMER, handleTimeoutEvent);
            _timeoutTimer.start();
        }

        /* ***************************************************************
         *
         *     Private Methods
         *
         ****************************************************************/

         private function handleTimeoutEvent(e:TimerEvent):void
         {
             var err:AssertionFailedError = new AssertionFailedError(_manager.getCurrentCommandClass() + " command has timed out");
             _manager.commandFinished(this, err);
         }
    }
}