# Visual FlexUnit (VFU) #

Contributors:
  * [Douglas McCarroll](http://www.brightworks.com/flex_ability)
  * [Joe Berkovitz](http://www.joeberkovitz.com)
  * Marty Frenzel
  * [Daniel Rinehart](http://life.neophi.com/danielr/)
  * [Tim Walling](http://www.timwalling.com)

## Introduction ##

Visual FlexUnit is an [Allurent](http://www.allurent.com) open source project. Its goal is to establish a framework for the testing of components' visual appearance by enhancing [FlexUnit](http://labs.adobe.com/wiki/index.php/ActionScript_3:resources:apis:libraries#FlexUnit) with additional features to support "visual assertions". In a nutshell, a visual assertion asserts that a component's appearance is identical to a stored baseline image file.

For the present VFU should be considered an experiment in progress. While it's now reaching the point where it appears to be on its way to being a practical and useful tool, it's still in a very early stage of development. Simply stated, we don't have enough experience working with it to know where tweaks will be required. So, if your visual tests fail when you think they should be passing, this may simply be an indication that VFU needs to be tweaked. Please [file an issue](http://code.google.com/p/visualflexunit/issues/list) if you think that this may be the case.

If any of the explanations or instructions on this page are less than clear we'd be grateful for your [feedback](http://code.google.com/p/visualflexunit/issues/list).

## Overview ##

Visual FlexUnit allows you to write "visual tests" for your Adobe Flex projects.

In these tests you can:
  * Instantiate and initialize UI components
  * Place them in a series of test states by means of:
    * property settings
    * style settings
    * simulated mouse and keyboard events
  * Write "visual assertions" that compare the components' appearance with saved baseline bitmaps

Tests succeed if components and baselines are close enough to identical to be visually indistinguishable.

Tests can be run either in GUI mode or through Ant.

### GUI Mode ###

The GUI version of VFU can run as AIR app or in Flash Player.

GUI mode will report errors, just like FlexUnit. It also allows you to:
  * Use a visual diff viewer to see how test result images differ from baseline images
  * View statistics on how many pixels differ, by how much, etc.
  * In AIR mode, you can bless the current test image, i.e. the appearance of the component that your test case has just created, and thereby create a new baseline. Cases where you would want to do this include:
    * The unit test is new and you need to create its original baseline image
    * Your test has failed, but you decide that the new test result image is acceptable and can become the new baseline

### Ant Mode ###

  * Simply reports whether tests pass or fail.
  * Runs tests in Flash Player.
  * The build process could be modified to send notification emails, etc.

### Why Is This Useful? ###

#### Regression Testing ####

By adding visual tests to your build process you can be assured that any changes to your codebase, or to the Flex/Flash framework, that effect the appearance of your components will be noticed immediately.

#### Testing For Cross-Platform Rendering Differences ####

While Adobe has done a great job of making Flash & Flex a write-once / deploy-anywhere platform, there may be differences in how images render:
  * Between the Flash Player and the AIR runtime
  * Between Windows, Mac, and Linux
  * And, of course, between the many combinations of these variables

To date our limited testing has only detected a) differences that aren't visually noticeable, and b) differences in very unusual cases that you would never use in the real world. Still, it doesn't hurt to check. By running regression tests on multiple platforms you can be assured that any unseemly differences in component rendering will be brought to your attention quickly.

## How To Use Visual FlexUnit ##

### Section Overview ###

The following subsections give directions on how to use Visual FlexUnit.

**Introduction:** Folder layout, naming conventions, example projects, etc.

**Step 1: Bootstrapping a Visual Test Project:** In this section we show you how to use an included Ant script to create an empty project framework for your visual test project.

**Step 2: Writing Visual Tests:** Writing test classes and methods for VFU.

**Step 3: Running Your Tests with the VFU AIR GUI:** How to run your visual tests in VFU's AIR GUI. This may be all you need to know. We think that VFU may be useful to many users who just use the AIR GUI to run tests, and skip the remaining steps.

**Step 4: Connecting to VFU's Build Process:** How to wire your newly created test project into the Ant build process that we've included with your download. This can be considered a continuation of Step 1 - the second half of bootstrapping a test project. We've placed it in Step 4 because some users won't want to go this far.

**Step 5: Using the Build Process:** Fifth, we explain how to use the build process to run your tests in automated mode in the Flash Player

**Step 6: Using VFU's SWF-Based GUI:** See details below on why, if you've gotten this far, you might want to do this.
###  ###
###  ###
### Introduction ###

#### Folder Layout ####

The downloadable visualflexunit.zip file unzips into this folder hierarchy:
```
  visualflexunit
    asdocs
    dev
      arc-flexunit2             - build process code
      flexunit                  - FlexUnit source code
      tools                     - build process code
      vfu
        vfuexample              - project containing example components
        vfuexampleTest          - example visual test project
        visualflexunit          - Visual FlexUnit source code
        visualflexunitTest      - unit tests for Visual FlexUnit code
```

These instructions assume that you'll be using a folder structure similar to that demonstrated by `/vfu/` and its subfolders, i.e. that you'll have a parent project folder (`/vfu/` in this case) which contains your 'tested project' and 'test project' folders.

For example, if your parent project is named 'foo' and your tested project is name 'bar' you'd have:
```
   visualflexunit
     asdocs
     dev
       arc-flexunit2
       flexunit     
       foo
         bar
         barTest
       tools        
       vfu
         vfuexample 
         vfuexampleTest
         visualflexunit
         visualflexunitTest
```

#### Conventions ####

  * Throughout these instructions we use these conventions:
    * **`[parent_project]`** - The name of your parent project, e.g. `foo` in the example above
    * **`[app_project]`** - The name of a project that you've created containing visual content, which you'd like to test, e.g. `bar` in the example above
    * **`[app_project]Test`** - The name of the test project which will contain tests for `[app_project]`, e.g. `barTest` in the example above
  * All project names (`[parent_project]` and `[app_project]`) must be unique within your build process

#### Example Projects ####

We've included two example projects in `dev/vfu/`:
  * `vfuexample` is an example project that contains several simple custom components.
  * `vfuexampleTest` is a VFU enabled test project that tests the visual components in `vfuexample`. It contains all the functionality described in Steps 1 and 4 for bootstrapped projects, plus:
    * Fully implemented VFU test code for testing `vfuexample`. You can refer to this when implementing Step 2.
    * Fully implemented Ant code that wires the test project into the build process. You'll want to refer to this when implementing Step 4 for your own projects.

#### Test Project Contents ####

Here's an overview of a VFU test project's contents. You can see this implemented in `dev/vfu/vfuexampleTest/`.

```
  dev
    [parent_project]
      [app_project]
      [app_project]Test
        .actionScriptProperties              \
        .flexProperties                       |
        .project                              |-- FlexBuilder project files & folder
        .settings                             |
          org.eclipse.core.resources.prefs   /
        build.xml                               - Ant build file
        build-imports.xml                       - ditto
        libs                                    - Folder included because FlexBuilder requires it - not used
        src
          VfuAirGui.mxml                     \
          VfuAirGui-app.xml                   |-- GUI app files
          VfuSwfGui.mxml                     /
          VfuGuiFlexUnitAllTests.as             - Lists test classes    
          baseline                              - Folder for image baseline files
          com                                   - An example of a source code folder that you might add
          skinning
            styles.css                          - Used by both GUI and automated test apps 
            fonts                               - Folder for font files
```

> VFU will store baseline images in the project's `src/baseline/` folder using a structure based on: a) test class names, b) test method names, and c) assertion IDs:

```
  dev
    [parent_project]
      [app_project]Test
        src
          baseline
            SomeTestClassName
              someTestMethodName
                1.png                      In this case, "1" and "2" are "assertion IDs". These are
                2.png                      passed in when visual assertions are made. Any integer ID 
              anotherTestMethodName        can be used but, obviously, they need to be unique within 
                1.png                      a given test method.
                2.png
            AnotherTestClassName
              etc...
```


### Step 1: Bootstrapping a Visual Test Project ###

The Visual FlexUnit download includes Ant scripts that will allow you to bootstrap a test project for `[app_project]`. Bootstrapping includes:
  * Creation of a folder hierarchy for your project.
  * Creation of FlexBuilder project files, so that the project can be imported into Eclipse.
  * Creation of framework code files including GUI App files, a CSS file, Ant files, etc.

#### Bootstrap How-To ####

Assumptions:

We make the following assumptions. If these are correct you should be able to bootstrap projects by following the directions below. If you have sufficient Flex and Ant knowledge you can work around these, e.g. compiling your AIR GUI test app from the command line, but we don't cover such scenarios here.
  * You have Ant 1.6.5 or newer installed.
  * You have FlexBuilder 3.0 (beta 3 or later) installed and are at least somewhat familiar with it.
  * You have the AIR runtime (beta 3 or later) installed.
  * As you will be creating a `dev/[parent_project]/[app_project]Test/` test project folder by running the Ant bootstrap process specified below, we assume that no such folder currently exists, or that you'll be deleting or renaming it and starting over.

Steps:

  * If a `dev/[parent_project]/[app_project]Test/` test project folder already exists, delete or rename it.
  * Open a command prompt and cd to the `[parent_project]` folder.
  * Execute this command:
> > `ant -Dproject="[app_project]" -f [your_path_to_dev]/dev/vfu/visualflexunit/template/testprojecttemplate/build.xml bootstrap-visual-test-project`
  * Confirm that this has in fact created a new "`[app_project]Test`" folder inside the `[parent_project]` folder.
  * Open Eclipse.
  * Ensure that you have an Eclipse path variable named `DEV_ROOT` that is set to the location of the `dev/` folder. (You set this at Windows | Preferences | General | Workspace | Linked Resources.)
  * Import the "`[app_project]Test`" folder as an Eclipse project into Eclipse.
  * Modify `/[app_project]Test/test/flexunit2/skinning/styles.css` as appropriate. You'll find explanatory comments in the file to guide you.
  * If you embed fonts in styles.css, put the font resource files into `/[app_project]Test/test/flexunit2/skinning/fonts/`
  * You're now ready to start writing your test classes.

### Step 2: Writing Visual Tests ###

Before you start this process you'll need to decide which visual components you'd like to test. Your options include:
  * Use standard Flex components
  * Use your own custom components
  * Copy the `dev/vfu/vfuexample/src/` folder into your own project. This contains three simple custom components, one of which fails in interesting ways.

#### A. Create A New Test Class ####

Instead of subclassing `TestCase` (the standard FlexUnit approach) subclass `com.allurent.flexunit2.vfu.framework.VfuTestCase`.

Note that `VfuTestCase` extends `TestCase` so you can do all the things that you can normally do in FlexUnit test classes. The next section explains how to write visual test methods but you can also write standard [FlexUnit](http://labs.adobe.com/wiki/index.php/ActionScript_3:resources:apis:libraries#FlexUnit) test methods and assertions.

As usual, your test class's name should end with "Test".

#### B. Write Visual Test Methods ####

Let's start with an example:
```
testMyAccordionComponent():void
        {
            var comp:MyAccordionComponent = new MyAccordionComponent();
            with (testSequence)
            {
                addSetProperty(comp, "selectedIndex", 1);
                addRefresh();
                addAssertComponentMatchBaseline(comp, 1);

                addSetProperty(comp, "selectedIndex", 2);
                addEventDispatch(comp.getHeaderAt(0), new MouseEvent(MouseEvent.MOUSE_DOWN));
                addRefresh();
                addAssertComponentMatchBaseline(comp, 2);

                start();
            }
        }
```

As you can see, `testSequence` is central to VFU's test process. Here's a quick overview of what `testSequence` is and does:
  * `VfuTestCase.testSequence` contains an instance of `com.allurent.flexunit2.vfu.framework.testsequence.TestSequenceManager`. Because much of what we do in the test process involves asynchronous operations, we use `TestSequenceManager` to manage a queue of `TestSequenceCommand` instances.
  * Each of your test methods tells this manager instance which commands to add to the queue, then tells it to start the queue by executing the first command.
  * The command instances each perform an operation (and, when the operation is asynchronous, wait for it to finish), then inform `TestSequenceManager` that they are done.
  * `TestSequenceManager` then tells the next command to execute; this process continues until the queue is finished.
  * There isn't a direct one-to-one relationship between the `add...()` calls in your test method and the commands that are added to the queue; for example `addRefresh()` adds three commands.
  * Some of the commands are synchronous (e.g. `SetProperty`) while others (e.g. `addAssertComponentMatchBaseline()`) are asynchronous.

Now that you have an overview, here are the details of how to write your own test methods:

As you can see, the example method:
  * First, instantiates a component
  * Second, tells `VfuTestCase.testSequence` a sequence of actions that it wants to see happen relative to the component
  * Finally, calls `testSequence.start()`

Your visual test methods should follow the same pattern as the example. The action sequence in the second step will generally consist of one or more repetitions (the example has two) of this subsequence:
  * One or more actions that manipulate the component. These can include setting the component's properties, setting its styles, and dispatching mouse and/or keyboard events from it.
  * A refresh. This involves several actions under the hood but essentially allows the component to display fully before its appearance is tested. (Take a look at the code for `TestSequenceManager.addRefresh()` if you're curious about the details.)
  * An assertion that the component's appearance will now match a saved baseline. Note that, in addition to the component instance, we pass in an ID integer to the `addAssertComponentMatchBaseline()` call. This must be unique for each such call within a given method, and is used by VFU to determine the name of the component's baseline file.

See the Visual FlexUnit ASDocs for `com.allurent.flexunit2.vfu.framework.testsequence.TestSequenceManager` for details on its `add[some_command]()` methods, their parameters, etc. ASDocs can be found in the `/visualflexunit/asDocs/` folder in the visualflexunit.zip download file.

As usual, your test method names should start with "test".

#### C. Add your test class to VfuGuiFlexUnitAllTests.as ####

Open `/[app_project]Test/test/flexunit2/VfuGuiFlexUnitAllTests.as` and follow the instructions in the file.

You're now ready to run your tests!

### Step 3: Running Your Tests with the VFU AIR GUI ###

#### Launching the AIR GUI ####

The Eclipse project that we created above is an AIR project. Right click your project in the Navigator view and select Run As | Adobe AIR Application or Debug As | Adobe AIR Application.

#### Viewing Results in the AIR GUI ####

As your tests run you'll see your components appearing and disappearing on the screen. When this stops you'll see a UI that is in some ways similar to FlexUnit's. The left hand panel has the Failures and All Tests tabs that you've come to know and love. If no failures are displayed, you're all set.

Failures for visual tests come in two varieties:

##### 1. Missing Baseline Failures #####

These occur the first time you run a given visual assertion. Confirm that the displayed image meets your expectations, then click the button that says "Yes, Use The Current Bitmap As A New Baseline". If the image displayed doesn't meet your expectations this is probably due to issues unrelated to VFU. On the other hand, if your component's image is different in VFU than it is in other settings this may be something that we need to look at so please [file an issue](http://code.google.com/p/visualflexunit/issues/list).

Note that VFU will only report one failure of this type for a given test method each time you run it. In other words, if you write a test method with four visual assertions, you'll have to run the AIR GUI version of VFU four times in order to create the requisite four baseline files. We suggest that you develop a habit of running the GUI immediately after you write each assertion in order to avoid confusion.

##### 2. Bitmap Doesn't Match Baseline Failures #####

When these occur your best first step is probably to click the Open Diff Viewer button. This will display both images, alternating, so that you can easily see how they differ.
  * If the difference between the two images is visually obvious you will need to think about why this is happening and what to do next. This is a fairly open-ended scenario that we can't fully address here. One option that is available to you is to bless your test result image ("current image") as a new baseline image.
  * If the difference between the two images isn't visually obvious, this is a different sort of problem. It suggests that the algorithms that we are using to ignore such unimportant differences are in need of tweaking, so please [file an issue](http://code.google.com/p/visualflexunit/issues/list).

### Step 4: Connecting to VFU's Build Process ###

#### Visual FlexUnit's Build Process ####

This section outlines a series of steps that you can take to connect your visual test project to the Ant-based build process that we include as part of the VFU download. We don't attempt here to explain how the build process works as that's outside of the scope of this project, but if you're interested in learning more, here are some resources:
  * The Apache Ant project: http://ant.apache.org/  In particular, follow the Manual link on the left side of the page.
  * At risk of stating the obvious, take a look at the build files themselves. We've tried to include comments where they'll be helpful.
  * You can find more details on VFU's build process at [VFU's build process wiki page](http://code.google.com/p/visualflexunit/wiki/VFUBuildProcess).

#### Conventions ####

We'll continue to use our previously defined conventions here, i.e. we use **`[app_project]`** to represent your tested project's name, and **`[parent_project]`** to represent the intermediate folder between `dev/` and your project's folder.

(For the purposes of these instructions **`[app_project]`** simply indicates your tested project's folder's name. If you choose to also implement the build process modeled here for your tested project you'll also use this name for your Ant project's name attribute, but we digress.)

#### 4.1 Setting User-Specific Settings ####

  * Open `dev/build-user.properties` and modify the settings as needed.

#### 4.2 Wiring The Tested Project's SWC Into The Process ####

##### 4.2.1 `[app_project]`'s build-assets.xml #####

This file informs the build process of the location of `[app_project]`'s SWC.

  * Copy `dev/vfu/vfuexample/build-assets.xml` to `dev/[parent_project]/[app_project]/build-assets.xml` and open the copy.
  * Replace all instances of `"vfuexample"` with `"[app_project]"`.
  * Replace one instance of `"/vfu/"` with `"/[parent_project]/"`.
  * These instructions assume that `[app_project]`'s SWC is placed in a `/[app_project]/bin/` subfolder. If your SWC's location is different, modify the path accordingly.

##### 4.2.2 Parent Folders' build-assets.xml Files #####

These files wire `[app_project]`'s build-assets.xml file into the build process.

  * Copy `dev/vfu/build-assets.xml` to `dev/[parent_project]/build-assets.xml` and open the copy.
  * Change the project's name attribute from `"vfu.assets"` to `"[parent_project].assets"`.
    * Delete one of the import lines.
    * Edit the other import line so that it reads `"<import file="[app_project]/build-assets.xml"/>"`.
  * Optional for our current purposes, but good form:
    * In `dev/build-assets.xml` add an import line that says `"<import file="[parent_project]/build-assets.xml"/>"`.

#### 4.3 The Test Project's Build Files ####

The bootstrap process (Step 1) created `build.xml` and `build-imports.xml` files in `dev/[parent_project]/[app_project]Test/`. These are complete and ready to use.

#### 4.4 `[app_project]`'s Build Files ####

Optional. If you'd like to include `[app_project]` in the build process, follow these steps:

  * Copy `build.xml` and `build-imports.xml` from `dev/vfu/vfuexample/` to `dev/[parent_project]/[app_project]/`.
  * Open `build.xml`.
    * Change the project's name attribute from `vfuexample` to `[project_name]`.
    * If your project needs to include any libraries in its build path, you'll need to include them in the projects flex.lib.path path structure. This requires several steps:
      * `vfuexample` doesn't require any libraries so take a look at `dev/vfu/visualflexunit/build.xml` to see how libraries are included in flex.lib.path.
      * You'll notice that we don't include hard-coded paths. Instead we use properties. To see how these are set,  review sub-step 4.2. This process needs to be implemented for all libraries.
  * `build-imports.xml` will usually work without modifications. If you are using folders other than `/project_name/src/` and `/project_name/bin/` as your source and build directories, you can override some default Ant property settings here.
    * The `src.flex.dir` property is set to a default value of `"src"` in `dev/tools/build-common-properties.xml`.
    * The `build.dir` property is set to a default value of `"bin"` in the same file.
    * You can override these by adding lines like this to this file: `"<property name="src.flex.dir" value="src/flex" />"`
    * Another option is to edit the property settings in `dev/tools/build-common-properties.xml`. This will modify the setting for all projects so it would break the build process for the projects in `dev/vfu/` in this case, but if you are setting up a build process for your own projects you'll want these values to reflect your standard folder names etc.

#### 4.5 Pulling The Process Into The Test Project ####

##### 4.5.1 dev/`[parent_project]`/build-imports.xml #####

  * Copy `dev/vfu/build-imports.xml` to `dev/[parent_project]/build-imports.xml` and open the copy.
  * Change the project's name attribute from `"vfu.imports"` to `"[parent_project].imports"`.

##### 4.5.2 dev/`[parent_project]`/build.xml #####

Optional. If desired, you can create a build file for the parent project that will build both `[app_project]` and its test project, then run the test project's tests. To do this:

  * Copy `dev/vfu/build.xml` to `dev/[parent_project]/build.xml` and open the copy.
  * In the first line change the project's name from `vfu` to `[parent_project]`.
  * In the `clean`, `build` and `test` targets:
    * Delete all lines that include `visualflexunit` or `visualflexunitTest`.
    * Replace all instances of `"vfuexample"` with `[app_project]`.

##### 4.5.3 dev/build.xml #####

Optional. The `dev/build.xml` file does the same thing as `dev/[parent_project]/build.xml`, but for the entire build process. If you'd like `[parent_project]` to be included when we tell the build process "build and test everything" follow these steps:
  * Open `dev/build.xml`.
  * Observe the `clean`, `build` and `test` targets.
  * In each target copy the line for the vfu parent project, and create a line under it which is identical, except that it says `"[parent_project]"` rather than `"vfu"`.

### Step 5: Using the Build Process ###

#### Prerequisites ####

We assume that you have done the following:

  * You've followed the steps outlined in Step 4.
  * You've run your test project in AIR GUI mode and created your baselines as explained above.
  * You've compiled `[app_project]` and all libraries upon which it depends.
  * You've set Flash Player's [global security settings](http://www.macromedia.com/support/documentation/en/flashplayer/help/settings_manager04.html) to 'always trust' files in `[app_project]` or one of its parent folders.

#### Automated Mode In Flash Player ####

At the command prompt:
  * cd to the `[app_project]Test` folder.
  * Execute "ant test". This will compile your `[app_project]Test` project, if needed, and run your tests.
  * Ant will output text to the command prompt window which will tell you how many of your tests have passed and failed, and provide stack traces for failures. Also, you should see a `BUILD SUCCESSFUL` message when the build process finishes. A `BUILD-FAILED` message indicates that there's a problem with the build process.

(If you're testing the example test components that we provide in `vfuexample` you'll find that there is one test that reliably fails at this point. The testCanvas\_2() test method tests a component that consists of buttons on a canvas. We've specified drop shadows for the buttons, using bizarre property settings for the shadows. One of these buttons renders differently across the AIR/SWF divide. We suggest that you re-run the tests in the SWF GUI, as explained below, and take a look with the diff viewer.)

#### More Work For Extra Credit :) ####

In an ideal world you'll be running a one click automated build process that builds and tests all of your projects. We've included a working build process for the entire `dev/` folder in the VFU download. The steps needed to wire both `[app_project]` and `[app_project]Test` into this process have been listed in Step 4. Also, the framework for including sub-projects is modeled in the `dev/vfu/` folder.

Your mission, should you choose to accept it, is to wire your projects into the process. To test the process:
  * At the command prompt, cd to the `dev/` folder
  * Execute `ant all`
  * Your goal is to see `BUILD SUCCESSFUL` appear in the command prompt window at the end of the process.

Good luck!

#### If Tests Fail In Automated Mode ####

If any of your tests fail you will probably want to run them in GUI mode in order to see how your test results differ from the saved baseline images.

If you've run your tests on a different platform from that in which their baseline files were created (e.g. you created baselines in AIR, then ran the tests in the Flash Player, and they failed) you should obviously run the same test-platform-type of GUI (e.g. in the example just cited, run the SWF GUI) to view the differences. Running the GUI in the platform in which the baseline files were created will probably simply result in your tests passing, which won't tell you much.

### Step 6: Using VFU's SWF-Based GUI ###

  * Open a command prompt and cd to the `[app_project]Test` folder.
  * Execute this command:
> > `ant swf-gui-all`
  * This will clean your build directory, compile the SWF GUI, and run it. The SWF GUI is essentially the same as the AIR GUI with these exceptions:
    * The app is typically launched using Ant
    * It runs in Flash Player rather than AIR
    * We haven't implemented the ability to save baselines in the SWF GUI version yet