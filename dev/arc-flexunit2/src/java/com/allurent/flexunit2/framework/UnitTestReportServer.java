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
import java.net.ServerSocket;
import java.net.Socket;

/**
 * A lightweight Java server that listens for input from a client program. This server is designed
 * to work exclusively with the ActionScript client test program, and is therefore very lax about
 * protocol and error issues. When the ActionScript tests have completed, the server dumps the
 * output of the tests to standard out. The server listens on port 50031 by default. In order to
 * change the port number, pass the port number as the first argument to the program. If the server
 * notes that all tests passed it exits with code 0. Exit code -1 means that there was an unhandled
 * exception and exit code 1 means that the tests failed.
 */
public class UnitTestReportServer
{
    /**
     * Status string to indicate that all tests passed.
     */
    public static final String PASS = "PASS";

    /**
     * Status string to indicate that the tests failed.
     */
    public static final String FAIL = "FAIL";

    /**
     * Status string to indicate that Flex requested a policy file.
     */
    public static final String POLICY = "POLICY";

    /**
     * Default port the server listens on.
     */
    private static int DEFAULT_PORT = 50031;

    /**
     * Port the server is listening on.
     */
    private int port;

    /**
     * Create a new Unit Test Report Server which listens on the given port.
     * 
     * @param port
     *            Port
     */
    public UnitTestReportServer(int port)
    {
        this.port = port;
    }

    /**
     * Handle a single report. The report server can also handle a policy file request if needed.
     * 
     * @param serverSocket
     *            Server socket to read report from
     * @return Status code of report server; PASS, POLICY, FAIL, or null (same as FAIL)
     * @throws IOException
     * @throws InterruptedException
     */
    private String handleReport(ServerSocket serverSocket) throws IOException, InterruptedException
    {
        Socket socket = serverSocket.accept();
        UnitTestReportHandler handler = new UnitTestReportHandler(socket.getInputStream(), socket
                .getOutputStream());
        handler.start();
        handler.join();
        return handler.getStatus();
    }

    /**
     * Record all of the information supplied to us from the Flex testing service.
     * 
     * @return Exit code; 0 for PASS; anything else for FAIL
     * @throws IOException
     * @throws InterruptedException
     */
    public int recordTests() throws IOException, InterruptedException
    {
        ServerSocket serverSocket = new ServerSocket(port);
        String status = handleReport(serverSocket);
        // If a policy file was requested, need to accept another
        // connection to actually read the test report
        if (POLICY.equals(status))
        {
            status = handleReport(serverSocket);
        }
        serverSocket.close();
        if (PASS.equals(status))
        {
            return 0;
        }
        return 1;
    }

    /**
     * This server is executed from the command line, or by Ant.
     * 
     * @param args
     *            [port]
     */
    public static void main(String args[])
    {
        int port = DEFAULT_PORT;
        if (args.length > 1)
        {
            port = Integer.parseInt(args[0], 10);
        }

        UnitTestReportServer unitTestReportServer = new UnitTestReportServer(port);
        int exitCode = 0;
        try
        {
            exitCode = unitTestReportServer.recordTests();
        }
        catch (Exception error)
        {
            error.printStackTrace();
            exitCode = -1;
        }
        System.exit(exitCode);
    }
}
