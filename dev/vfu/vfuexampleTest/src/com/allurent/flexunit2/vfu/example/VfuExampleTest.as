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

package com.allurent.flexunit2.vfu.example
{
    import com.allurent.flexunit2.vfu.framework.VfuTestCase;

    import flash.events.MouseEvent;

    import mx.controls.Button;

    public class VfuExampleTest extends VfuTestCase
    {
        public function VfuExampleTest(methodName:String=null)
        {
            super(methodName);
        }

        public function testThatPasses():void
        {
            assertTrue( (2 + 2) == 4 );
        }

        public function testThatFails():void
        {
            assertTrue( (2 + 2) == 3 );
        }

        public function testAccordion_1():void
        {
            var comp:Accordion_1 = new Accordion_1();
            with (testSequence)
            {
                addSetProperty(comp, "selectedIndex", 1);
                addRefresh();
                addAssertComponentMatchBaseline(comp, 1);
                addSetProperty(comp, "selectedIndex", 2);
                addRefresh();
                addAssertComponentMatchBaseline(comp, 2);
                addSetProperty(comp, "selectedIndex", 0);
                addRefresh();
                addAssertComponentMatchBaseline(comp, 3);
                addSetProperty(comp, "selectedIndex", 2);
                addSetProperty(comp, "selectedIndex", 1);
                addRefresh();
                addAssertComponentMatchBaseline(comp, 4);
                addEventDispatch(comp.getHeaderAt(0), new MouseEvent(MouseEvent.MOUSE_DOWN));
                addRefresh();
                addAssertComponentMatchBaseline(comp, 5);
                start();
            }
        }

        public function testButton():void
        {
            var btn:Button = new Button();
            with (testSequence)
            {
                addSetProperty(btn, "label", "testButton.1");
                addRefresh();
                addEventDispatch(btn, new MouseEvent(MouseEvent.MOUSE_DOWN));
                addRefresh();
                addAssertComponentMatchBaseline(btn, 1);
                addSetProperty(btn, "label", "testButton.2");
                addEventDispatch(btn, new MouseEvent(MouseEvent.MOUSE_UP));
                addRefresh();
                addAssertComponentMatchBaseline(btn, 2);
                start();
            }
        }


        public function testCanvas_1():void
        {
            var comp:Canvas_1 = new Canvas_1();
            with (testSequence)
            {
                addSetStyle(comp, "backgroundAlpha", .6);
                addRefresh();
                addAssertComponentMatchBaseline(comp, 1);
                start();
            }
        }

        public function testCanvas_2():void
        {
            var comp:Canvas_2_DropShadows = new Canvas_2_DropShadows();
            with (testSequence)
            {
                addRefresh();
                addAssertComponentMatchBaseline(comp, 1);
                start();
            }
        }

    }
}