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

import java.io.BufferedReader;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Pattern;

/**
 * Utility class that filters directories and files to create a list of classes that should be run
 * by FlexUnit.
 */
public class ActionScriptTestClassFileFilter implements FileFilter
{
    // filters read from the external file
    private List filters = new ArrayList();

    /**
     * Were any additional filters loaded which may have excluded tests.
     * 
     * @return True if other tests were loaded.
     */
    public boolean hasFilters()
    {
        return filters.size() > 0;
    }

    /**
     * Load an external filter file which specifies a subset of tests to include.
     * 
     * @param filtersFile
     *            Filters file
     * @throws IOException
     */
    public void loadFilters(File filtersFile) throws IOException
    {
        if ((filtersFile == null) || !filtersFile.exists())
        {
            return;
        }
        BufferedReader input = new BufferedReader(new InputStreamReader(new FileInputStream(
                filtersFile)));
        String filter;
        while ((filter = input.readLine()) != null)
        {
            filter = filter.trim();
            if (filter.length() > 0)
            {
                filters.add(Pattern.compile(filter));
            }
        }
        input.close();
    }

    /**
     * @see java.io.FileFilter#accept(java.io.File)
     */
    public boolean accept(File pFile)
    {
        if (!pFile.exists())
        {
            return false;
        }
        else if (pFile.isFile())
        {
            // if filters are being used they are the only thing that is checked
            if (filters.size() > 0)
            {
                try
                {
                    String name = pFile.getCanonicalPath();
                    for (Iterator filter = filters.iterator(); filter.hasNext();)
                    {
                        if (((Pattern) filter.next()).matcher(name).find())
                        {
                            return true;
                        }
                    }
                }
                catch (IOException error)
                {
                    throw new RuntimeException(error);
                }
                return false;
            }
            // Look for *Test.as or Test*.as
            String name = pFile.getName();
            if (name.endsWith("Test.as"))
            {
                return true;
            }
            if (!(name.startsWith("Test") && name.endsWith(".as")))
            {
                return false;
            }
        }
        else
        {
            // Ignore subversion directories
            if (pFile.getName().equals(".svn"))
            {
                return false;
            }
        }
        return true;
    }
}
