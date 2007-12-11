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

package com.allurent.flexunit2.vfu.framework
{
    import flexunit.framework.AssertionFailedError;
    import flexunit.framework.TestCase;

    import com.allurent.flexunit2.vfu.framework.testsequence.TestSequenceManager;

    /**
     * Subclass this class instead of TestCase when you write visual tests.
     * Detailed instructions on writing visual tests can be found at Visual
     * FlexUnit's website at TODO:###############################
     */
    public class VfuTestCase extends TestCase
    {
        public var testSequence:TestSequenceManager;

        public function VfuTestCase(methodName:String=null)
        {
            super(methodName);
            testSequence = new TestSequenceManager(this);
        }

        /* ***************************************************************
         *
         *     Public Methods
         *
         ****************************************************************/

        /**
         * This is a convenience method designed to simplify your code when
         * you want to "assert" that code in your test method will throw
         * an error. Unfortunately, it can't be done in a single line like
         * most asserts but use of this method will make your code a bit more
         * succinct. Use by inserting code like this in a TestCase:
         *
         *  try {
         *      // some code that -should- throw an error here
         *
         *      // next line won't execute unless your code didn't throw an error
         *      fail("someErrorMessage");
         *  } catch (error:Error) {
         *      assertError(error);
         *  }
         */
        public static function assertError(error:Error):void {
            if (error is AssertionFailedError) {
                throw error;
            }
        }

        /**
         * Use this method when comparing values of the number data type.
         * Flash Player's computation of floating numbers is inherantly
         * imprecise. This assert allows a comparison to pass if there
         * is an extremely small difference between two numbers.
         */
        public function assertNumberEquals(... rest):void
        {
            if ( rest.length == 3 )
                failNumberNotEquals( rest[0], rest[1], rest[2] );
            else
                failNumberNotEquals( "", rest[0], rest[1] );
        }

        /**
         * Use this method when comparing values of the number data type.
         * Flash Player's computation of floating numbers is inherantly
         * imprecise. This assert causes a "doesn't equal" comparison to
         * fail if there is an extremely small difference between two
         * numbers. In other words, its action is "assert that these two
         * numbers aren't equal, or even very close to equal".
         */
        public function assertNumberNotEquals(... rest):void
        {
            if ( rest.length == 3 )
                failNumberEquals( rest[0], rest[1], rest[2] );
            else
                failNumberEquals( "", rest[0], rest[1] );
        }

        /* ***************************************************************
         *
         *     Private Methods
         *
         ****************************************************************/

        private function failNumberEquals( userMessage:String, notExpected:Number, actual:Number ):void
        {
            var delta:Number = 10^-6;
            if ( ( actual < notExpected + delta ) && ( actual > notExpected - delta ) )
                failWithUserMessage( userMessage, "notExpected:<" + notExpected + "> but was:<" + actual + ">" );
        }

        private function failNumberNotEquals(userMessage:String, expected:Number, actual:Number):void
        {
            var delta:Number = Math.pow(10, -6);
            if ( ( actual > expected + delta ) || ( actual < expected - delta ) )
                failWithUserMessage( userMessage, "expected:<" + expected + "> but was:<" + actual + ">" );
        }

        public function failWithUserMessage( userMessage:String, failMessage:String ):void
        {
            if ( userMessage.length > 0 )
                userMessage = userMessage + " - ";
            throw new AssertionFailedError( userMessage + failMessage );
        }
    }
}



