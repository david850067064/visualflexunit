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

package com.allurent.flexunit2.vfu.utils
{
    import com.allurent.flexunit2.vfu.framework.VfuTestCase;

    public class ColorUtilTest extends VfuTestCase
    {
        public function ColorUtilTest(methodName:String=null)
        {
            super(methodName);
        }

        public function testSeparateColors():void
        {
            var color:uint;
            var result:Object;
            // 24 bit color
            color = 0xAB << 16 | 0xCD << 8 | 0xEF;
            result = ColorUtil.separateColors(color);
            assertNull( result.alpha );
            assertEquals( 0xAB, result.red   );
            assertEquals( 0xCD, result.green );
            assertEquals( 0xEF, result.blue  );
            // 32 bit color
            color = 0x12 << 24 | 0xAB << 16 | 0xCD << 8 | 0xEF;
            result = ColorUtil.separateColors(color);
            assertEquals( 0x12, result.alpha );
            assertEquals( 0xAB, result.red   );
            assertEquals( 0xCD, result.green );
            assertEquals( 0xEF, result.blue  );
        }
    }
}