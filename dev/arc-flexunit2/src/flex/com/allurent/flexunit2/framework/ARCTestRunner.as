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
package com.allurent.flexunit2.framework
{
    import flexunit.flexui.TestRunner;
    import flexunit.framework.Test;
    
    /**
     * Test runner that uses the ARC Result Printer to capture test
     * information and relay it to Java.
     */
    public class ARCTestRunner
    {
        /**
         * Run a test or suite of tests. This makes a network connection to a result printer
         * and sends output to that result printer.
         *
         * @param test test to run
         * @param host host on which report server is running
         * @param port port on which report server is listening
         */
        public static function run(test:Test, host:String = "127.0.0.1", port:int = 50031):void
        {
            var printer:ARCResultPrinter = new ARCResultPrinter(host, port);
            TestRunner.run(test, printer);
        }    
    }
}
