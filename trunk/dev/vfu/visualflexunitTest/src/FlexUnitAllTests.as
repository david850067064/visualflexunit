package { 

import flexunit.framework.*;
import com.allurent.flexunit2.vfu.utils.BitmapUtilTest;
import com.allurent.flexunit2.vfu.utils.ColorUtilTest;
import com.allurent.flexunit2.vfu.utils.misc.TwoDimensionalDictionaryTest;
import com.allurent.flexunit2.vfu.utils.StringUtilTest;

public class FlexUnitAllTests 
{
   public static function suite() : TestSuite
   {
      var testSuite:TestSuite = new TestSuite();
      testSuite.addTestSuite(com.allurent.flexunit2.vfu.utils.BitmapUtilTest);
      testSuite.addTestSuite(com.allurent.flexunit2.vfu.utils.ColorUtilTest);
      testSuite.addTestSuite(com.allurent.flexunit2.vfu.utils.misc.TwoDimensionalDictionaryTest);
      testSuite.addTestSuite(com.allurent.flexunit2.vfu.utils.StringUtilTest);
      return testSuite;
   }
}
}
