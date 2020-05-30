using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using System.Net;
using System.Net.Sockets;

namespace TcpBbsServer
{
    class Program
    {
        static void Main(string[] args)
        {
            StartBbsServer();
        }

        #region BBS

        private static void StartBbsServer()
        {
            IPAddress ipAddress = IPAddress.Any; // IPAddress.Parse("127.0.0.1");
            int port = 6400;
            TcpListener tcpListener = new TcpListener(ipAddress, port);

            Console.Write("Starting TCP server on port " + port.ToString() + "... ");
            tcpListener.Start();
            Console.WriteLine(" DONE!");

            int ConnectionCount = 0;

            while (true)
            {
                //using (TcpClient tcpClient = tcpListener.AcceptTcpClient())
                TcpClient tcpClient = tcpListener.AcceptTcpClient();

                Console.WriteLine("New client connection!");

                ConnectionCount++;
                Console.WriteLine("Connection #" + ConnectionCount.ToString() + " is established and awaiting data...");
                //NetworkStreamHandler NSH = new NetworkStreamHandler(tcpClient.GetStream(), ConnectionCount);
                TcpClientHandler TCH = new TcpClientHandler(tcpClient, ConnectionCount);

                //Console.WriteLine("Client connection closed.");

            }

        }

        public class TcpClientHandler

        {

            private byte[] Buffer = null; // new byte[4096];

            private const int BufferSize = 1;

            private AsyncCallback AsyncReceiveCallback = new AsyncCallback(ProcessReceiveResults);

            private int ConnectionId;

            // Let's create a network stream to communicate over the connected Socket.

            //private NetworkStream NetworkStream = null;
            private TcpClient TcpClient = null;

            private DateTime dtStart;

            public bool Connected = false;

            //private bool _ShowWelcomeMessage = true;
            private string _CommandString = string.Empty;


            public TcpClientHandler(TcpClient tcpClient, int connectionId)
            {
                //this.Close();

                try

                {

                    // Setup a network stream on the server Socket

                    this.ConnectionId = connectionId;

                    //NetworkStream = networkStream;
                    TcpClient = tcpClient;

                    this.dtStart = DateTime.Now;
                    this.Connected = true;
                    Console.WriteLine("NetworkStream() is OK...");

                    this.SendData(Environment.NewLine);
                    this.SendData("welcome to the vbguyny bbs server!" + Environment.NewLine);
                    this.SendData(Environment.NewLine);
                    this.SendData("what is your name? ");

                    Buffer = new byte[BufferSize];
                    TcpClient.GetStream().BeginRead(Buffer, 0, Buffer.Length, AsyncReceiveCallback, this);

                    Console.WriteLine("BeginRead() is OK...");

                }

                catch (Exception e)

                {

                    Console.WriteLine(e.Message);

                }

            }

            public void Close()
            {
                Console.WriteLine("Connection " + this.ConnectionId.ToString() + " is closing.");

                try
                {
                    TcpClient.Close();
                }
                catch { }

                this.Connected = false;
            }

            public void SendData(string data)
            {
                //byte[] Buffer = Encoding.ASCII.GetBytes(data);
                byte[] Buffer = System.Text.Encoding.GetEncoding(28591).GetBytes(data);

                try
                {
                    TcpClient.GetStream().Write(Buffer, 0, Buffer.Length);
                }
                catch
                {
                    this.Close();
                }
            }

            static void ProcessReceiveResults(IAsyncResult ar)

            {

                TcpClientHandler TCH = (TcpClientHandler)ar.AsyncState;

                try

                {

                    int BytesRead = 0;

                    BytesRead = TCH.TcpClient.GetStream().EndRead(ar);

                    //Console.WriteLine("Connection " + TCH.ConnectionId.ToString() + " received " + BytesRead.ToString() + " byte(s).");



                    if (BytesRead == 0)

                    {

                        //Console.WriteLine("Connection " + TCH.ConnectionId.ToString() + " is closing.");

                        //NSH.NetworkStream.Close();
                        TCH.Close();

                        DateTime dtEnd = DateTime.Now;

                        return;

                    }

                    else
                    {
                        string Data = System.Text.Encoding.GetEncoding(28591).GetString(TCH.Buffer);
                        //Console.Write(Data);

                        foreach (char DataCharIn in Data)
                        {
                            TCH.ProcessDataReceived(DataCharIn);
                        }


                    }

                    if (TCH.Connected == true)
                    {
                        TCH.Buffer = new byte[BufferSize];
                        TCH.TcpClient.GetStream().BeginRead(TCH.Buffer, 0, TCH.Buffer.Length, TCH.AsyncReceiveCallback, TCH);
                    }
                }

                catch (Exception e)

                {
                    if (TCH.Connected == true)
                    {
                        Console.WriteLine("Failed to read from a network stream with error: " + e.Message);

                        //TCH.NetworkStream.Close();
                        TCH.Close();
                    }
                }

            }

            public void ProcessDataReceived(char DataCharIn)
            {
                string Data;
                bool OkToProcessCommand = false;

                Data = DataCharIn.ToString();

                switch (Data)
                {
                    case "\r":
                        OkToProcessCommand = true;
                        break;

                    case "\u0014": // Backspace
                        if (string.IsNullOrEmpty(_CommandString) == false)
                        {
                            _CommandString = _CommandString.Remove(_CommandString.Length - 1, 1);
                        }
                        break;
                }

                this.SendData(Data);

                if (OkToProcessCommand == true)
                {
                    this.SendData("welcome, " + _CommandString + "!" + Environment.NewLine);
                    this.Close();
                    _CommandString = string.Empty;

                }
                else
                {
                    _CommandString += DataCharIn;
                }

            }
        }


        #endregion

    }
}
