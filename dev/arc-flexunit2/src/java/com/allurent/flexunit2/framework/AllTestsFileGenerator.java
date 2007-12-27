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
package com.allurent.flexunit2.framework;

import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

/**
 * Utility class used to generate an arc-flexunit compatible "AllTests" ActionScript class based on
 * test classes that exist in a specified source directory.
 */
public class AllTestsFileGenerator
{
    /**
     * Generates content of an "AllTests" ActionScript class that will execercise all test classes
     * existing in the specified directory and all of its subdirectories.
     * 
     * @param rootDir
     *            Directory to start looking for test classes in
     * @param filtersFile
     *            Optional file that filters what tests to run
     * @return Contents of test class
     * @throws IOException
     */
    private String generateAllTestsClass(File rootDir, File filtersFile) throws IOException
    {
        List classlist = new LinkedList();
        if (rootDir == null || !rootDir.exists() || !rootDir.isDirectory())
        {
            throw new IOException("Specified file \"" + rootDir + "\" is not a directory.");
        }

        ActionScriptTestClassFileFilter fileFilter = new ActionScriptTestClassFileFilter();
        fileFilter.loadFilters(filtersFile);

        addClasses(classlist, rootDir, rootDir, fileFilter);

        Iterator classes = classlist.iterator();

        // generate the class
        StringBuffer result = new StringBuffer();
        result.append("package");
        result.append("\n{");
        result.append("\n    import flexunit.framework.*;");
        while (classes.hasNext())
        {
            result.append("\n    import " + classes.next() + ";");
        }
        result.append("\n\n    public class FlexUnitAllTests ");
        result.append("\n    {");
        result.append("\n        public static function suite() : TestSuite");
        result.append("\n        {");
        result.append("\n            var testSuite:TestSuite = new TestSuite();");
        if (fileFilter.hasFilters())
        {
            classlist.add("AlwaysFail");
        }

        classes = classlist.iterator();
        while (classes.hasNext())
        {
            result.append("\n            testSuite.addTestSuite(" + classes.next() + ");");
        }
        result.append("\n            return testSuite;");
        result.append("\n        }");
        result.append("\n    }");
        result.append("\n}");
        if (fileFilter.hasFilters())
        {
            result.append("\n\nimport flexunit.framework.*;");
            result.append("\n\nclass AlwaysFail extends TestCase");
            result.append("\n{");
            result.append("\n    public function testFail():void");
            result.append("\n    {");
            result
                    .append("\n        fail(\"A filter file is in use, all tests may not have been run.\");");
            result.append("\n    }");
            result.append("\n}");
        }

        return result.toString();
    }

    /**
     * Locates all eligible classes in the specified directory, and its subdirectories, and adds
     * their fully qualified package name to the supplied List.
     * 
     * @param classList
     *            List the list to add eligible classes to
     * @param rootDir
     *            the root directory from which package names should be determined
     * @param file
     *            the file to examine. If this is a File (instead of a directory) it is assumed to
     *            have already been verified against the FileFilter.
     * @param fileFilter
     *            a filter to use for determining which files to include in the class list
     * @throws IOException
     */
    private void addClasses(List classList, File rootDir, File file, FileFilter fileFilter)
            throws IOException
    {
        if (file == null || !file.exists())
        {
            return;
        }
        else if (file.isFile())
        {
            // assume it has already been checked against the FileFilter
            String rootpath = rootDir.getCanonicalPath();
            String filepath = file.getCanonicalPath();
            if (!filepath.startsWith(rootpath))
            {
                throw new IOException("Root path \"" + rootpath + "\" not detected in file path \""
                        + filepath + "\".");
            }
            filepath = filepath.substring(rootpath.length() + 1);
            filepath = filepath.replace('\\', '/');
            filepath = filepath.replace('/', '.');
            if (filepath.endsWith(".as"))
            {
                filepath = filepath.substring(0, filepath.length() - 3);
            }
            classList.add(filepath);
        }
        else if (file.isDirectory())
        {
            File[] files = file.listFiles(fileFilter);
            if (files != null)
            {
                for (int i = 0; i < files.length; i++)
                {
                    addClasses(classList, rootDir, files[i], fileFilter);
                }
            }
        }
    }

    /**
     * Help text on how to use the class.
     */
    private static void usage()
    {
        System.out
                .println("\nAllTestsFileGenerator : Generates an arc-flexunit2 compatible \"AllTests\" ActionScript class based on test classes in a source directory.");
        System.out.println("By default any class named Test*.as or *Test.as will be included.");
        System.out.println("Usage:\n AllTestsFileGenerator <source_dir> [filters_file]\n");
    }

    /**
     * Main entry point for the class.
     * 
     * @param args
     *            <source_dir> [filters_file]
     */
    public static void main(String args[])
    {
        try
        {
            AllTestsFileGenerator generator = new AllTestsFileGenerator();
            if (args == null || args.length < 1)
            {
                System.out.println("\nERROR! No source directory specified.\n");
                usage();
                System.exit(1);
            }
            File dir = new File(args[0]);
            File filtersFile = null;
            if (args.length >= 2)
            {
                filtersFile = new File(args[1]);
            }
            System.out.println(generator.generateAllTestsClass(dir, filtersFile));
        }
        catch (Throwable t)
        {
            t.printStackTrace();
            usage();
            System.exit(1);
        }
        System.exit(0);
    }
}
