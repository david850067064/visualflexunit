# Visual FlexUnit's Build Process #

## "Modified Antennae" ##

Visual FlexUnit's build process is derived from [Antennae](http://code.google.com/p/antennae/), another of [Allurent](http://www.allurent.com)'s open source contributions to the Flex community.

### Simplifications and Clarifications ###

We've made a few changes to the Antennae's approach for the sake of simplicity and to make it easier for those new to Ant and Antennae to absorb VFU's build process. These include:
  * Rather than using a `/flex2/` folder for source code, we use `/src/`.
  * Rather than using a `/test/flexunit2/` folder for test projects' source code, we use `/src/`.
  * Rather than using a `/build/` folder, we use `/bin/`.
  * We've replaced the string "flex2" in our Ant target names with "flex".
  * We've named our dev root folder `/dev/` rather than `/Antennae/`.

While this will hopefully make VFU's build process easier to absorb, we realize that it will also make it harder for you to combine VFU with an Antennae based build system. Hopefully these notes will make that process a bit easier, should you choose to embark upon it.

### Additions ###

We've also added some VFU specific targets to `/dev/tools/build-common-targets.xml`. Hopefully these will find their way into Antennae at some point.

## arc-flexunit2 ##

We've received some inquiries on what 'arc-flexunit2' is and what it does. Hopefully this section will shed some light and point you in the right direction if you'd like to look into this code further.

First of all, a few quick notes:
  * The `dev/arc-flexunit2` code is part of [Antennae](http://code.google.com/p/antennae/).
  * Starting with version 0.1.1 our download file includes all source code for arc-flexunit2 (both AS and Java). Obviously, if you **really** want to know what this code does, you can dig into the source code.
  * We’ll be mentioning various Ant targets in these notes. You may want to open `/dev/tools/build-common-targets.xml` ([here](http://visualflexunit.googlecode.com/svn/trunk/dev/tools/build-common-targets.xml)) so that you can refer to them.

When running in automated mode the build process first builds a test SWF by running the `create-test-suite` target. This target:
  * Auto-generates a `FlexUnitAllTest.as` file. The code in this file adds all tests in your source code to a test suite.
  * Makes a copy of `/dev/vfu/visualflexunit/template/RunTests.mxml` and renames it with your project's name. This file uses `FlexUnitAllTests.as`.
  * Compiles the .mxml file into a SWF.
  * This is a simplified explanation - see the target's code for details.

The `test-flexunit2` target runs the tests. Here's how that works:
  * The target first starts a Java server (`com.allurent.flexunit2.framework.UnitTestReportServer`), waits 2 seconds, then starts Flash Player, passing in the path to the SWF that the `create-test-suite` target created.
  * The SWF runs all the tests and reports to the server. You can look at `ARCTestRunner.as` and `ARCTestPrinter.as` in `dev/arc-flexunit2/src/flex/com/allurent/flexunit2/framework/` if you'd like to see the details of this process. `ARCTestPrinter.onAllTestsEnd()` would be a good starting point.
  * The Java server outputs results into the `server.output` Ant property before it closes, and Ant prints the info to the console using `echo`.