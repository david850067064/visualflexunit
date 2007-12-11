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
    public class StringUtil
    {
        public static function getCharsAfterSubstring(s:String, sub:String):String {
            var index:int = s.indexOf(sub);
            if (index == -1)
            {
                throw new Error("StringUtil.getCharsAfterSubstring() can't find substring within string");
            }
            var firstCharIndex:int = index + sub.length;
            var result:String = s.slice(firstCharIndex);
            if ( (result).indexOf(sub) != -1)
            {
                // If you've run into this, it's probably time to revise this function.
                // I'm inclined to think that calling code should have to pass in an arg
                // that says how to handle this situation - perhaps a string - "useFirstSubstring",
                // "useLastSubstring", "throwErrorOnMultipleSubstrings" (default) ?
                throw new Error("StringUtil.getCharsAfterSubstring() has found more than one instance of substring within string. It is currently unequipped to deal with this.");
            }
            return result;
        }

        public static function pad(s:String, desiredLength:int, padChar:String = " "):String
        {
            if (s.length > desiredLength) throw new Error("StringUtil.pad: startString is longer than desiredLength");
            var additionalChars:int = desiredLength - s.length;
            while (additionalChars)
            {
                s = s + padChar;
                additionalChars = additionalChars - 1;
            }
            return s;
        }
    }
}