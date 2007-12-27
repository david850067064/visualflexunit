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

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * A UnitTestResportServer thread This thread reads all input from its socket connection, and dumps
 * the output to standard out. It does this until it reads a command from the connection, one of:
 * #PASS #FAIL technically, the server will exit on any four-character #command, but it only
 * recognizes the above two. when the thread reads a command, it will execute the server's shutdown
 * method, passing it the shutdown status.
 */
public class UnitTestReportHandler extends Thread
{
    private static final String POLICY_FILE_REQUEST = "<policy-file-request/>";

    private static final String POLICY_FILE = "<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\"/></cross-domain-policy>";

    private InputStream inputStream;

    private OutputStream outputStream;

    private String status;

    /**
     * Create a new report handle, reading data from the given input stream.
     * 
     * @param inputStream
     *            Input stream to read from
     * @param outputStream
     *            Output stream to send data to
     */
    public UnitTestReportHandler(InputStream inputStream, OutputStream outputStream)
    {
        this.inputStream = inputStream;
        this.outputStream = outputStream;
    }

    /**
     * Read data from the input stream, dumping the data straight to standard out, until we're told
     * to stop by the "#" character.
     * 
     * We dump each message to standard out when we detect the message's end, marked by a "zero
     * byte"
     * 
     * When the run() method has finished the status field will indicate either PASS or FAIL
     */
    public void run()
    {
        StringBuffer data = new StringBuffer();
        byte buffer[] = new byte[1024];
        int read;

        try
        {
            while ((read = inputStream.read(buffer)) > 0)
            {
                // accumulate what we've got.
                for (int i = 0; i < read; i++)
                {
                    if (buffer[i] == (byte) 0)
                    {
                        String message = data.toString();

                        // scan for the special shutdown command
                        if (message.startsWith("#"))
                        {
                            status = message.substring(1);
                            return;
                        }
                        if (message.equals(POLICY_FILE_REQUEST))
                        {
                            outputStream.write(POLICY_FILE.getBytes());
                            outputStream.write(0);
                            outputStream.flush();
                            status = UnitTestReportServer.POLICY;
                            return;
                        }
                        handleMessage(message);
                        data = new StringBuffer();
                    }
                    else
                    {
                        data.append((char) buffer[i]);
                    }
                }
            }
        }
        catch (IOException error)
        {
            handleMessage(error.toString());
            status = UnitTestReportServer.FAIL;
        }
    }

    /**
     * Dump what we've got to standard out.
     * 
     * @param message
     *            Message to handle.
     */
    public void handleMessage(String message)
    {
        System.out.println(message);
    }

    /**
     * Final status of the input stream this handler was looking at.
     * 
     * @return null if not done; otherwise PASS or FAIL
     */
    public String getStatus()
    {
        return status;
    }
}
