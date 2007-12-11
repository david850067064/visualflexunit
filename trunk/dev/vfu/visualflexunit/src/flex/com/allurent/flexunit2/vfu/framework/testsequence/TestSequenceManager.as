/* ***********************************
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

package com.allurent.flexunit2.vfu.framework.testsequence
{
    import com.allurent.flexunit2.vfu.framework.VfuTestCase;
    import com.allurent.flexunit2.vfu.framework.strategies.DefaultBitmapMatchJudge;
    import com.allurent.flexunit2.vfu.framework.strategies.IBitmapMatchJudge;
    import com.allurent.flexunit2.vfu.framework.testsequence.ErrorEvent
    import com.allurent.flexunit2.vfu.framework.testsequence.commands.AssertComponentMatchBaseline;
    import com.allurent.flexunit2.vfu.framework.testsequence.commands.DispatchEvent;
    import com.allurent.flexunit2.vfu.framework.testsequence.commands.DoAction;
    import com.allurent.flexunit2.vfu.framework.testsequence.commands.SetProperty;
    import com.allurent.flexunit2.vfu.framework.testsequence.commands.SetStyle;
    import com.allurent.flexunit2.vfu.framework.testsequence.commands.TestSequenceCommand;
    import com.allurent.flexunit2.vfu.framework.testsequence.commands.ValidateNow;
    import com.allurent.flexunit2.vfu.framework.testsequence.commands.WaitForEvent;
    import com.allurent.flexunit2.vfu.framework.testsequence.commands.WaitForEventOrQuiesce;
    import com.allurent.flexunit2.vfu.framework.testsequence.commands.WaitForQuiesce;
    import com.allurent.flexunit2.vfu.utils.DisplayObjectUtil;
    import com.allurent.flexunit2.vfu.utils.ObjectUtil;
    import com.allurent.flexunit2.vfu.utils.misc.InputBlocker;

    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.utils.getTimer;
    import mx.containers.Panel;
    import mx.core.Application;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;

    /**
     * This class provides much of VfuTestCase's functionality. It is stored in that class's
     * testSequence property, and implements test sequences by creating and executing a queue of
     * TestSequenceCommand instances. We've tried to comment it fairly thoroughly for two reasons:
     * a) because it is so central to VFU's functionality, and b) because it is fairly complex.
     * These ASDocs only display comments for public members of the class. If you're interested
     * in an in depth look at how the class works we suggest that you look at the source code
     * where you'll find not only the code but comments explaining private members, etc.
     */
    public class TestSequenceManager
    {
        private static const DEFAULT_QUIESCE:int = 300
        private static const DEFAULT_TIMEOUT:int = 10000;

        /*
         * Notes on _addAsyncFunc:
         *
         * This property stores a Function instance that is created by TestCase.addAsync() in this code below:
         *    "_addAsyncFunc = _testCase.addAsync(addAsyncHandler, timeout, null, addAsyncFailHandler)"
         *
         * As an understanding of addAsync() is central to getting asynchronous tests to work
         * in FlexUnit, it's probably worth explaining in some detail.
         *
         * Essentially, when you call addAsync() you're telling FlexUnit "please don't consider
         * this test to be finished when the test method has finished executing. Instead, give me
         * a function to call when -I- think that I'm finished.
         *
         * addAsync() cooperatively passes back a function, specifically an instance of
         * AsyncTestHelper.handleEvent(), which is what we store in this property.
         * When we call this function FlexUnit calls the callback function that we passed
         * in - addAsyncHandler() in the code sample above. Once that callback function
         * has finished executing, FlexUnit assumes that your test method is finished
         * and that it can start to execute another.
         *
         * Given all this, we obviously don't want to have more that one addAsync() process
         * running at a time. So, in this class, we initiate the process at the start of our
         * test sequence, save the function that we are given in _addAsyncFunc, and call it
         * when we're done, in endSequence().
         */
        private var _addAsyncFunc:Function;

        /*
         *   _activeEventListenerData: Holds the data we need in order to make sure that all
         *                             event listeners are removed at the end of our test sequence.
         */
        private var _activeEventListenerData:Array;

        /*
         *   _currDisplayedUIComps: We keep track of currently displayed DisplayObjects here so that
         *                          we can automatically call removeChild() for all displayed
         *                          components once a test sequence is finished.
         */
        private var _currDisplayedDisplayObjects:Array;

        /*
         *   _currTestClass: This property stores the name of the currently executing test class. We
         *                   use this to determine the file path for baseline files. For a given
         *                   testClass/testMethod/visualAssertion the path will be
         *                   /yourTestProjectFolder/test/flexunit2/baseline/testClassName/testMethodName/assertionID.png
         */
        private var _currTestClass:String;

        /*
         *   _currTestMethod: See comment for _currTestClass.
         */
        private var _currTestMethod:String;

        /*
         *   _displayPanel: When we display components as part of the testing process we attach them to the Panel component
         *                  referenced by this property.
         */
        private var _displayPanel:Panel;

        /*
         *   _logInfo: Stores lots of tasty log info which is output to the console at the end of each test sequence.
         */
        private var _logInfo:String;

        /*
         *   _mostRecentLogTime: Used by this class's logging, so that we can include information on how long each step takes.
         */
        private var _mostRecentLogTime:int = -1;

        /*
         *   _testCase: The VfuTestCase instance that uses this manager.
         */
        private var _testCase:VfuTestCase;

        /*
         *   _testSequence: This array holds the queue of TestSequenceCommands that is central to its being.
         */
        private var _testSequence:Array;

        /*
         *   _testSequenceActive: A boolean value that gets checked when we want to make sure that the sequence is, or isn't, active.
         */
        private var _testSequenceActive:Boolean = false;

        /**
         * @param testCase An instance of VfuTestCase, and this class's client, passed in by itself when it instanciates this class.
         */
        public function TestSequenceManager(testCase:VfuTestCase):void
        {
            _testCase = testCase;
            _testSequence = new Array();
            _activeEventListenerData = new Array();
            _currDisplayedDisplayObjects = new Array();
        }

        /* ***************************************************************
         *
         *     Public Methods Used By Test Writers
         *
         ****************************************************************/

        /**
         * This method adds an DoAction command instance to the test sequence queue.
         * If you have some functionality that you'd like executed during the test
         * sequence you can simply create a function and pass it in here, and it will
         * be executed when the sequence is run.
         *
         * @param func The function that you'd like executed.
         */
        public function addAction(func:Function):void
        {
            testMethodInit();
            _testSequence.push(new DoAction(this, func));
        }

        /**
         * This method adds an AssertComponentMatchBaseline command instance to the test sequence queue. You should add
         * it after you've manipulated your component as desired and called addRefresh(). You can repeat this sequence
         * - manipulate-refresh-assert - multiple times in your test method.
         *
         * @param comp               The DisplayObject instance whose appearance you are comparing to a saved baseline.
         * @param testID             Every call to addAssertComponentMatchBaseline() must pass in an integer testID that
         *                           is unique within the testmethod. This is used to name the baseline file that is
         *                           used by the assert.
         * @param timeout            Optional - Pass in an integer specifying milliseconds if you wish this command to
         *                           allow more or less time to pass before throwing an error. The default is 10 seconds.
         * @param judgmentStrategy   Optional - If you'd like VFU to use some logic other than its default logic to
         *                           decide whether a test result is close enough to its saved baseline you can write a
         *                           class that implements IBitmapMatchJudge, instanciate it, and pass it in here.
         */
        public function addAssertComponentMatchBaseline(comp:DisplayObject, testID:int, timeout:int = DEFAULT_TIMEOUT, judgmentStrategy:IBitmapMatchJudge = null):void
        {
            if (judgmentStrategy == null)
            {
                judgmentStrategy = new DefaultBitmapMatchJudge();
            }
            testMethodInit(comp);
            var testIDString:String = _currTestClass + "/" + _currTestMethod + "/" + String( testID );
            _testSequence.push(new AssertComponentMatchBaseline(this, comp, testIDString, timeout, judgmentStrategy));
        }

        /**
         * This method adds a DispatchEvent command object to the test sequence queue which, when executed
         * calls dispatch() event on the target you specify. We use this to simulate mouse and keyboard actions
         * using MouseEvents and KeyboardEvents and a DisplayObject target, but this method could be used for other
         * events with other types of EventDispatcher targets. Let us know what creative uses you come up with!
         *
         * @param target   The EventDispatcher instance that you'd like to dispatch the event from.
         * @param event    The Event you'd like to dispatch.
         */
        public function addEventDispatch(target:EventDispatcher, event:Event):void
        {
            testMethodInit(target);
            _testSequence.push(new DispatchEvent(this, target, event));
        }

        /**
         * This method adds a WaitForEventOrQuiesce command object to the test sequence queue. As its name implies
         * this command waits for either of:
         * <p>    a) The arrival of an event, in either its capture or target phase, or</p>
         * <p>    b) The passage of a period of time without that event happening.</p>
         *
         * <p>This method is used as one of several steps set up by addRefresh() to create an opportunity for a
         * DisplayObject to render fully before its appearance is tested. See the comments in WaitForEventOrQuiesce
         * for details on why its behavior is useful. It's not clear to us whether it will also be useful to the
         * writers of visual tests. If it is, let us know. :)</p>
         *
         * @param target             The EventDispatcher instance that you'd like to listen to for the specified event dispatch.
         * @param eventType          A string specifying the type of event you'd like to listen for.
         * @param timeout            Optional - Pass in an integer specifying milliseconds if you wish this command to
         *                           allow more or less time to pass before throwing an error. The default is 10 seconds.
         * @param quiesceDuration    Optional - The amount of "quiet time" you'd like your test sequence to wait for, in
         *                           milliseconds. The default is 300.
         *
         * @see com.allurent.flexunit2.vfu.framework.testsequence.commands.WaitForEventOrQuiesce
         */
        public function addEventOrQuiesceWait(target:EventDispatcher, eventType:String, timeout:int = DEFAULT_TIMEOUT, quiesceDuration:int = DEFAULT_QUIESCE):void
        {
            testMethodInit(target);
            _testSequence.push(new WaitForEventOrQuiesce(this, target, eventType, timeout, quiesceDuration));
        }

        /**
         * This method adds a WaitForEvent command object to the test sequence queue. As its name implies
         * this command waits for the arrival of an event, in either its capture or target phase.
         *
         * <p>Note that in the (very limited) test methods that we've written so far, this method hasn't
         * yet been found to actually be useful. Please let us know if you find uses for it.</p>
         *
         * @param target             The EventDispatcher instance that you'd like to listen to for the specified event dispatch.
         * @param eventType          A string specifying the type of event you'd like to listen for.
         * @param timeout            Optional - Pass in an integer specifying milliseconds if you wish this command to
         *                           allow more or less time to pass before throwing an error. The default is 10 seconds.
         * @param testFunc
         */
        public function addEventWait(target:EventDispatcher, eventType:String, timeout:int = DEFAULT_TIMEOUT, testFunc:Function = null):void
        {
            testMethodInit(target);
            _testSequence.push(new WaitForEvent(this, target, eventType, timeout, testFunc));
        }

        /**
         * This method adds a WaitForQuiesce command object to the test sequence queue. As its name implies
         * this command waits for the passage of a period of time without an UPDATE_COMPLETE event being
         * received by the component display panel.
         *
         * <p>This method is used as one of several steps set up by addRefresh() to create an opportunity for a
         * DisplayObject to render fully before its appearance is tested.</p>
         *
         * @param timeout            Optional - Pass in an integer specifying milliseconds if you wish this command to
         *                           allow more or less time than the default to pass before throwing an error.
         *                           The default is 10 seconds.
         * @param quiesceDuration    Optional - The amount of "quiet time" you'd like your test sequence to wait for, in
         *                           milliseconds. The default is 300.
         */
        public function addQuiesceWait(timeout:int = DEFAULT_TIMEOUT, quiesceDuration:int = DEFAULT_QUIESCE):void
        {
            testMethodInit();
            _testSequence.push(new WaitForQuiesce(this, timeout, quiesceDuration));
        }

        /**
         * This method adds several different command objects to the test sequence queue which, working together, will hopefully
         * give a displayed UI component an adequate opportunity to render fully. Put another way, what we're trying to
         * accomplish here is reliable full rendering. As this project is currently in its 'experimental alpha' stage,
         * it is possible that the approach currently used will need to be tweaked. It appears to work fine, but we invite
         * your feedback.
         *
         * @param timeout            Optional - Pass in an integer specifying milliseconds if you wish this command to
         *                           allow more or less time to pass before throwing an error. The default is 10 seconds.
         * @param quiesceDuration    Optional - The amount of "quiet time" you'd like your test sequence to wait for, in
         *                           milliseconds, as part of the refresh process. The default is 300.
         */
        public function addRefresh(timeout:int = DEFAULT_TIMEOUT, quiesceDuration:int = DEFAULT_QUIESCE):void
        {
            testMethodInit();
            _testSequence.push(new ValidateNow(this));
            addEventOrQuiesceWait(_displayPanel, FlexEvent.UPDATE_COMPLETE, timeout, quiesceDuration);
            addQuiesceWait(timeout, quiesceDuration);
        }

        /**
         * This method adds a SetProperty command object to the test sequence queue which (surprise!)
         * sets the property you specify to the value that you provide on the instance that you provide.
         *
         * @param instance      The instance that you'd like to set a property on.
         * @param prop          The name of the property.
         * @param val           The value that you'd like the property set to.
         */
        public function addSetProperty(instance:Object, prop:String, val:Object):void
        {
            testMethodInit(instance);
            _testSequence.push(new SetProperty(this, instance, prop, val));
        }

        /**
         * Just like addSetProperty() except that we're setting a style on a UIComponent, rather than a
         * property on an Object.
         *
         * @param comp          The UIComponent for which you'd like to set a style.
         * @param styleName     The name of the style that you'd like to set.
         * @param val           The value that you'd like the style set to.
         */
        public function addSetStyle(comp:UIComponent, styleName:String, val:Object):void
        {
            testMethodInit(comp);
            _testSequence.push(new SetStyle(this, comp, styleName, val));
        }

        /**
         * This method starts the test sequence that you've created using the methods above.
         *
         * @param timeout  Optional - The number of milliseconds you'd like to allow for the entire test sequence,
         *                 before an error gets thrown. If you don't pass in a value VFU computes a generous but
         *                 reasonable period of time to use for this value.
         */
        public function start(timeout:int = 0):void
        {
            logInfo("start()");
            if (timeout == 0)
            {
                timeout = _testSequence.length * DEFAULT_TIMEOUT * 2;
            }
            if (_testSequenceActive) throw new Error("TestSequenceManager.start() called while a previous test sequence still active");
            _addAsyncFunc = _testCase.addAsync(addAsyncHandler, timeout, null, addAsyncFailHandler)
            executeNextCommand();
        }

        /* ***************************************************************
         *
         *     Public Methods
         *
         ****************************************************************/

        /**
         * This method should only be used by the TestSequenceCommands that this class manages. If you're
         * writing your own TestSequenceCommands use this any time you want to add an event listener to an
         * object, and this manager will take care of calling removeEventListener() when the test sequence
         * has finished.
         *
         * @param target      The EventDispatcher that you are adding a listener to
         * @param eventType   A string identifying the event type that you want to listen for
         * @param listener    The listener Function instance
         */
        public function addEventListener(target:EventDispatcher, eventType:String, listener:Function):void
        {
            var o:Object = {target:target, eventType:eventType, listener:listener};
            _activeEventListenerData.push(o);
            target.addEventListener(eventType, listener);
        }

        /**
         * This method should only be used by the TestSequenceCommands that this class manages. If you're
         * writing your own TestSequenceCommands use this any time you want to add a component to the
         * display panel, and this manager will take care of calling removeChild() for the component when
         * the test sequence has finished.
         *
         * @param comp The DisplayObject that you like added to the display panel.
         */
        public function addDisplayObject(comp:DisplayObject):void
        {
            // TODO?: center() isn't working for SWFLoaders because their width & height
            //        equal zero when they get to this point
            //        This is because we've just created the loader and
            //        it hasn't loaded the bitmap yet. If we want to center these images
            //        we need to do it at some later point.
            DisplayObjectUtil.center(comp, _displayPanel);
            _displayPanel.addChild(comp);
            _currDisplayedDisplayObjects.push(comp);
        }

        /**
         * This method is called by the current active command when it's finished.
         * It passes in an instance of itself and, optionally, an Error instance.
         * The Error instance, if any, does two things: a) it signals an end
         * of the test sequence, even if some unexecuted commands remain in the
         * queue, and b) it ends up in addAsyncHandler() where it is thrown. See the
         * note in addAsyncHandler()'s comments for an explanation of why it
         * is important for errors to be thrown there.
         *
         * @param command The currently running TestSequenceCommand which called this method.
         * @param failureError See explanation above
         */
        public function commandFinished(command:TestSequenceCommand, failureError:Error = null):void
        {
            logInfo("commandFinished()", command, failureError);
            command.dispose();
            if (!_testSequence.length) throw new Error("TestSequenceManager.commandFinished() called while unexecuted commands are still in command queue");
            if (_testSequence[0] != command) throw new Error("TestSequenceManager.commandFinished() passed command that is not most recent command. How can this be?");
            if (failureError)
            {
                endSequence(failureError);
            }
            else
            {
                if (_testSequence.length > 1)
                {
                    removeAllActiveEventListeners();
                    _testSequence.shift();
                    executeNextCommand();
                }
                else
                {
                    endSequence();
                }
            }
        }

        /**
         * Returns the class name of the current command
         */
        public function getCurrentCommandClass():String
        {
            if (!_testSequence.length) throw new Error("TestSequenceManager.getCurrentCommandClass() called when no command is active");
            return ObjectUtil.getInstanceType(_testSequence[0]);
        }

        /**
         * Simply calls validateNow() on the display panel
         */
        public function validateNow():void
        {
            if (_displayPanel == null) throw new Error("TestSequenceManager.validateNow() called before display panel is displayed");
            _displayPanel.validateNow();
        }

        /* ***************************************************************
         *
         *     Accessor Methods
         *
         ****************************************************************/

        public function get currentTestDescription():String
        {
            return _currTestClass + "." + _currTestMethod + "()";
        }

        public function get displayPanel():Panel
        {
            return _displayPanel;
        }

        /* ***************************************************************
         *
         *     Private Methods
         *
         ****************************************************************/

        private function addAsyncFailHandler(o:Object):void
        {
            logInfo("addAsync() timed out");
            throw new Error("Test sequence for " + currentTestDescription + " has exceeded timeout" );
        }

        /*
         * All errors created by TestSequenceCommands are sent here for throwing. Here's
         * why:
         *
         * This function is called by FlexUnit's asynchronous testing functionality.
         * You can look to the comments for this class's _addAsyncFunc property for
         * an explanation of how FlexUnit would know that it should call this method
         * but for practical purposes the main thing that you need to know is that
         * it -is- called by FlexUnit code. Specifically, it's called when the code in
         * endSequence() calls the Function instance stored in _addAsyncFunc.
         *
         * Why, you ask, should I care that this method is called from deep within the
         * bowels of FlexUnit?
         *
         * For this reason: Any error thrown here will traverse through FlexUnit's code
         * and will be handled by FlexUnit's error handling. Which, as it happens,
         * is precisely what we want to have happen. This means that errors will be
         * reported in FlexUnits results panel, as opposed to being rudely displayed in
         * a Flash Player error dialogue.
         */
        private function addAsyncHandler(e:ErrorEvent):void
        {
            if (e.error)
            {
                throw e.error;
            }
        }

        private function createDisplayPanel():void
        {
            InputBlocker.block();
            _displayPanel = new Panel();
            with (_displayPanel)
            {
                layout = "absolute";
                width = Math.floor(Application.application.width  * .94);
                height = Math.floor(Application.application.height * .96);
                x = Math.floor(Application.application.width  * .03);
                y = Math.floor(Application.application.height * .01);
                title = "Visual Testing In Progress...";
                setStyle("titleStyleName", "displayPanelTitle");

            }
            Application.application.addChild(_displayPanel);
        }

        private function endSequence(failureError:Error = null):void
        {
            logInfo("endSequence()");
            trace(_logInfo);
            removeAllActiveEventListeners();
            removeAllDisplayedDisplayObjects();
            _currTestClass = null;
            _currTestMethod = null;
            _testSequence = new Array();
            _testSequenceActive = false;
            // _addAsyncFunc holds an instance of AsyncTestHelper.handleEvent(), which
            // expects to be passed an Event. So we wrap our error (if any) in an event, then
            // extract it in addAsyncHandler().  failureError may be null but addAsyncHandler()
            // will handle this case.
            var failureEvent:ErrorEvent = new ErrorEvent(failureError);
            _addAsyncFunc(failureEvent);
        }

        private function ensureDisplayPanel():void
        {
            if (_displayPanel == null)
            {
                createDisplayPanel();
            }
        }

        private function executeNextCommand():void
        {
            _testSequenceActive = true;
            TestSequenceCommand(_testSequence[0]).execute();
        }

        private function getDurationSinceLastLogTimeAndReset():int
        {
            var result:int;
            if (_mostRecentLogTime == -1)
            {
                result = -1;
            }
            else if (_mostRecentLogTime is int)
            {
                result = getTimer() - _mostRecentLogTime;
            }
            else
            {
                throw new Error("TestSequenceManager.getDurationSinceLastLogTimeAndReset() can't find a most recent log time");
            }
            _mostRecentLogTime = getTimer();
            return result;
        }

        private function logInfo(description:String, command:TestSequenceCommand = null, failureError:Error = null):void
        {
            var passedInfo:String = description;
            passedInfo = (command is TestSequenceCommand) ? passedInfo + "." + ObjectUtil.getInstanceType(command) : passedInfo;
            passedInfo = (failureError is Error) ? passedInfo = passedInfo + ".Error:" + failureError.message : passedInfo;
            var duration:int = getDurationSinceLastLogTimeAndReset();
            var newInfo:String = _currTestClass + "." + _currTestMethod + "." + passedInfo;
            newInfo = (duration == -1) ? newInfo + "\n" : newInfo + "." + String(duration) + "\n";
            _logInfo = (_logInfo == null) ? newInfo : _logInfo + newInfo
        }

        private function removeAllActiveEventListeners():void
        {
            var target:EventDispatcher;
            var eventType:String;
            var listener:Function;
            for each(var listenerData:Object in _activeEventListenerData)
            {
                target = EventDispatcher(listenerData.target);
                eventType = String(listenerData.eventType);
                listener = listenerData.listener;
                // Docs: "If there is no matching listener registered with the
                //        EventDispatcher object, a call to this method has no effect."
                // ...so we don't have to worry about the possibility that we have
                // two entries in listenerData for the same target-event-listener set.

                if (target == null)
                {
                    var x:int = 0;
                }


                target.removeEventListener(eventType, listener);
            }
            _activeEventListenerData = new Array();
        }

        private function removeAllDisplayedDisplayObjects():void
        {
            for each(var comp:DisplayObject in _currDisplayedDisplayObjects)
            {
                _displayPanel.removeChild(comp);
            }
            _currDisplayedDisplayObjects = new Array();
            removeDisplayPanel()
        }

        private function removeDisplayPanel():void
        {
            Application.application.removeChild(_displayPanel);
            _displayPanel = null;
            InputBlocker.unblock();
        }

        private function testMethodInit(possibleComp:Object = null):void
        {
            if (_testCase.methodName != _currTestMethod)
            {
                ensureDisplayPanel();
                // A new test method is executing
                if (_testSequenceActive)
                {
                    // And the previous test method hasn't finished yet
                    throw new Error(_currTestClass + "." + _testCase.methodName + "() started before " + currentTestDescription + " finished executing");
                }
                else
                {
                    // No previous test method running. This is good.
                    _currTestClass = ObjectUtil.getInstanceType(_testCase);
                    _currTestMethod = _testCase.methodName;
                }
            }
            if (possibleComp is DisplayObject)
            {
                if (!DisplayObjectUtil.isAttachedToDisplayList(DisplayObject(possibleComp)))
                {
                    addDisplayObject(DisplayObject(DisplayObjectUtil.getOutermostDisplayContainer(DisplayObject(possibleComp))));
                }
            }
        }
    }
}













