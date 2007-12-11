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

package com.allurent.flexunit2.vfu.utils.misc
{
    import com.allurent.flexunit2.vfu.framework.VfuTestCase;
    import com.allurent.flexunit2.vfu.utils.misc.TwoDimensionalDictionary;

    public class TwoDimensionalDictionaryTest extends VfuTestCase
    {
        public function TwoDimensionalDictionaryTest(methodName:String=null)
        {
            super(methodName);
        }

        public function testTwoDimensionalDictionary():void
        {
            var dict:TwoDimensionalDictionary = new TwoDimensionalDictionary(100, 100);
            assertTrue(dict.areCoordinatesValid(0,  0 ));
            assertTrue(dict.areCoordinatesValid(99, 0 ));
            assertTrue(dict.areCoordinatesValid(0,  99));
            assertTrue(dict.areCoordinatesValid(99, 99));
            assertFalse(dict.areCoordinatesValid(-1,  99 ));
            assertFalse(dict.areCoordinatesValid(99,  -1 ));
            assertFalse(dict.areCoordinatesValid(100, 99 ));
            assertFalse(dict.areCoordinatesValid(99,  100));
            try {
                dict.setValue(100,1,1);
                fail("TwoDimensionalDictionary.setValue() doesn't return error when x position exceeds dictionary's dimension");
            } catch (error:Error) {
                assertError(error);
            }
            try {
                dict.setValue(-1,1,1);
                fail("TwoDimensionalDictionary.setValue() doesn't return error when x position is negative number");
            } catch (error:Error) {
                assertError(error);
            }
            try {
                dict.setValue(1,100,1);
                fail("TwoDimensionalDictionary.setValue() doesn't return error when y position exceeds dictionary's dimension");
            } catch (error:Error) {
                assertError(error);
            }
            assertNull(dict.getValue(1, 1));
            dict.setValue(5, 5, 5);
            assertEquals(dict.getValue(5, 5), 5);
            dict.setValue(99, 99, "foo");
            assertEquals(dict.getValue(99, 99), "foo");
            dict.setValue(10, 10, dict);
            assertEquals(dict.getValue(10, 10), dict);
            dict.setValue(3, 30, 3);
            assertEquals(dict.getValue(3, 30), 3);
            dict.setValue(30, 3, 3);
            assertEquals(dict.getValue(30, 3), 3);
        }
    }
}