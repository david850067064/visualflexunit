/*
 * Copyright (c) 2007 Allurent, Inc.
 * http://code.google.com/p/antennae/
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
/**
 * The result printer prints output to an XMLSocket, with the expectation that
 * on the other end of the line is a running instance of the Java class 
 *
 *   com.allurent.arc.unittest.server.UnitTestReportServer
 *
 * The printer prints the results of every test, along with a summary footer.
 * The printer has retry logic that accomodates it being started before a server is running
 * on the other end of the line. The printer tries to connect for 10 seconds and then gives up.
 */
package com.allurent.flexunit2.framework
{
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.net.XMLSocket;
    import flash.system.fscommand;
    import flash.utils.getTimer;
    
    import flexunit.flexui.IFlexWriter;
    import flexunit.framework.AssertionFailedError;
    import flexunit.framework.Test;
    
    public class ARCResultPrinter implements IFlexWriter
    {
        /**
         * Number of ms to spend trying to connect
         */
        private static var CONNECT_TIMEOUT:int = 10000;

        /**
         * The host that the output should be sent to.
         */
        private var _host:String;

        /**
         * The port on the host that the output should be sent to.
         */
        private var _port:int;

        /**
         * Time we started trying to establish a connection.
         */
        private var _connectStartTime:int;
        
        /**
         * Socket used to send output to the Java process.
         */
        private var _theSocket:XMLSocket;
    
        /**
         * The time that the first test started at.
         */
        private var _testsStartTime:int = -1;

        /**
         * Total number of tests run.
         */
        private var _testCount:int;

        /**
         * Information on all of the tests that produced a failure.
         */
        private var _testFailures:Array = new Array();

        /**
         * Information on all of the tests that produced an error.
         */
        private var _testErrors:Array = new Array();
    
        /**
         * Progress string used to summarizes status of each test.
         */
        private var _progress:String = "";
    
        /**
         * Report string that contains all of the test output.
         */
        private var _report:String = "";
    
        /**
         * Create a new result printer.
         * @param host Host to connect to
         * @param port Port on host to connect to
         */
        public function ARCResultPrinter(host:String, port:int) 
        {
            _host = host;
            _port = port;
        }
    
        //---------------------------------------------------------------------
        // IFlexWriter Methods
        //---------------------------------------------------------------------
    
        /**
         * Capture the time that the first test started to report
         * on how long the entire test run took.
         * @param test Test
         */
        public function onTestStart(test:Test):void
        {
            if (_testsStartTime < 0)
            {
                _testsStartTime = getTimer();
            }
        }

        /**
         * Capture that another test ran.
         * @param test Test
         */
        public function onTestEnd(test:Test):void
        {
            _testCount++;
        }
    
        /**
         * Capture the time that the last test finished to report
         * on the how long the entire test run took.
         */
        public function onAllTestsEnd():void
        {
            var endTime:int = getTimer();
            var runTime:int = endTime - _testsStartTime;
            prepareReport(runTime);
            sendReport();
        }
    
        /**
         * Update the progress indicator that the test completed
         * correctly.
         * @param test Test
         */
        public function onSuccess(test:Test):void
        {
            updateProgress(".");
        }
    
        /**
         * Update the progress indicator that the test failed
         * and capture the failure information.
         * @param test Test
         * @param error Error
         */
        public function onFailure(test:Test, error:AssertionFailedError):void
        {
            updateProgress("F");
            _testFailures.push(new Defect(test, error));
        }

        /**
         * Update the progress indicator that the had an error
         * and capture the error information.
         * @param test Test
         * @param error Error
         */
        public function onError(test:Test, error:Error):void
        {
            updateProgress("E");
            _testErrors.push(new Defect(test, error));
        }

        /**
         * Prepare the report for printing.
         * @param runTime Total run time for all tests
         */ 
        private function prepareReport(runTime:int):void
        {
            // flush any remaining progress information.
            if (_progress.length > 0)
            {
                updateReport(_progress);
            }

            // include a header with a time summary    
            updateReport("Time: " + (runTime / 1000) + " seconds");
            printDefects("failure", _testFailures);
            printDefects("error", _testErrors);
            printFooter();
        }
    
        /**
         * Add to the report all of the defects that are of
         * a specific type.
         * @param type Type of defect
         * @param defects Defects to include
         */
        private function printDefects(type:String, defects:Array):void
        {
            var count:int = defects.length;
            if (count == 0)
            {
                return;
            }
    
            if (count == 1)
            {
                updateReport("There was " + count + " " + type + ":");
            }
            else
            {
                updateReport("There were " + count + " " + type + "s:");
            }
    
            var number:int = 1;
            for each (var defect:Defect in defects)
            {
                printDefect(number, defect);
                number++;
            }
        }
    
        /**
         * Add to the report information about the defect.
         * @param counter Defect number
         * @param defect Defect information
         */
        private function printDefect(number:int, defect:Defect):void
        {
            updateReport(number + ") " + defect.test.toString());
        	if (defect.error != null)
        	{
        	    var message:String = defect.error.getStackTrace();
                // when running in the non-debug player no stack trace
                // information is returned, try to get something
        	    if ((message == null) || (message == ""))
        	    {
        	        message = defect.error.toString();
        	    }
            	updateReport("\tmessage: " + message);
        	}
        }

        /**
         * Include summary information in the report.
         * 
         */
        private function printFooter():void
        {
            if (_testFailures.length == 0)
            {
                updateReport("OK (" + _testCount + " test" + (_testCount == 1 ? "" : "s") + ")");
            }
            else
            {
                updateReport("FAILURES!!!");
                updateReport("Tests run: " + _testCount +
                       ",  Failures: " + _testFailures.length +
                       ",  Errors: " + _testErrors.length);
            }
        }

        /**
         * Include summary information about the test in the
         * progress indicator.
         * @param lastResult Result of last test
         */
        private function updateProgress(lastResult:String):void
        {
            _progress += lastResult;
            // break up the data onto multiple lines
            if (_progress.length > 40)
            {
                updateReport(_progress);
                _progress = "";
            }
        }

        /**
         * Include additional information in the report.
         * @param update Update
         */
        private function updateReport(update:String):void
        {
            _report += update + "\r\n";
        }

        /**
         * Send the report to Java.
         */
        private function sendReport():void
        {
            //create XMLSocket object
            _theSocket = new XMLSocket();
            
            //displays text regarding connection
            _theSocket.addEventListener(Event.CONNECT, sendData);
            _theSocket.addEventListener(IOErrorEvent.IO_ERROR, makeConnection);

            _connectStartTime = getTimer();
            makeConnection();
        }
    
        /**
         * Make the connection to the Java server.
         * @param event Event
         */
        private function makeConnection(event:Event = null):void
        {
            // if we've failed to make a connection, try again ... to a point
            if (getTimer() - _connectStartTime < CONNECT_TIMEOUT) {
                _theSocket.connect(_host, _port);
            }
        }

        /**
         * Send the report to Java.
         * @param event Event
         */
        private function sendData(event:Event):void
        {
            _theSocket.send(_report);
            if ((_testFailures.length == 0) && (_testErrors.length == 0))
            {
                _theSocket.send('#PASS');
            }
            else
            {
                _theSocket.send('#FAIL');
            }
    
            _theSocket.close();
            fscommand("quit", "");
        }
    }
}

import flexunit.framework.Test;

/**
 * Utility class to hold information about a test
 * and why it failed.
 */
class Defect
{
    /**
     * Test information.
     */
    public var test:Test;
    
    /**
     * Failure information.
     */
    public var error:Error;
    
    /**
     * Create a new Defect.
     * @param test Test
     * @param error Error
     */
    public function Defect(test:Test, error:Error = null)
    {
        this.test = test;
        this.error = error;
    }
}
