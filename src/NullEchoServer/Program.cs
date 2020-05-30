using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.IO;
using System.IO.Ports;

using System.Net;
using System.Web;
using System.Net.Sockets;

using System.Threading;

namespace NullEchoServer
{
    class Program
    {
        private static SerialPort mSerialPort = null;

        //private const int BaudRate = 300;
        //private const int BaudRate = 600;
        private const int BaudRate = 1200;
        //private const int BaudRate = 2400;
        //private const int BaudRate = 9600;
        //private const int BaudRate = 4800;
        //private const int BaudRate = 115200;

        private const Parity Parity = System.IO.Ports.Parity.None;
        //private const Parity Parity = System.IO.Ports.Parity.Even;
        //private const Parity Parity = System.IO.Ports.Parity.Odd;
        //private const Parity Parity = System.IO.Ports.Parity.Space;
        //private const Parity Parity = System.IO.Ports.Parity.Mark;

        private const int DataBits = 8;
        //private const int DataBits = 9;

        private const StopBits StopBits = System.IO.Ports.StopBits.One;
        //private const StopBits StopBits = System.IO.Ports.StopBits.None;

        //private const bool DtrEnable = true;
        private const bool DtrEnable = false;

        //private const bool RtsEnable = true;
        private const bool RtsEnable = false;

        private const Handshake Handshake = System.IO.Ports.Handshake.None;
        //private const Handshake Handshake = System.IO.Ports.Handshake.RequestToSendXOnXOff;
        //private const Handshake Handshake = System.IO.Ports.Handshake.XOnXOff;
        //private const Handshake Handshake = System.IO.Ports.Handshake.RequestToSend;

        private const int ReadTimeOut = SerialPort.InfiniteTimeout;
        //private const int ReadTimeOut = 150;
        private const int WriteTimeOut = SerialPort.InfiniteTimeout;
        //private static string PortName = "COM3";
        private static string PortName = "COM4";

        private static WebClient mWebClient = null;

        private static void Main(string[] args)
        {
            ParseCommandArguments(args);

            Initialize();

            OpenSerialPort();
            
            WaitForIncomingData();

            Terminate();
        }

        private static void ParseCommandArguments(string[] args)
        {
            string[] ArgToUpper;

            foreach (string arg in args)
            {
                ArgToUpper = arg.ToUpper().Split('=');

                if (ArgToUpper[0].StartsWith("PORT=") == true)
                {
                    PortName = ArgToUpper[1];
                }
            }
        }

        private static void Initialize()
        {
            mSerialPort = new SerialPort()
            {
                PortName = PortName,
                BaudRate = BaudRate,
                Parity = Parity,
                DataBits = DataBits,
                StopBits = StopBits,
                DtrEnable = DtrEnable,
                RtsEnable = RtsEnable,
                Handshake = Handshake,
                ReadTimeout = ReadTimeOut,
                WriteTimeout = WriteTimeOut,
                ReadBufferSize = 4096,
                WriteBufferSize = 8192,
                //WriteBufferSize = 2,
                //ReceivedBytesThreshold = 1,
                Encoding = System.Text.Encoding.GetEncoding(28591),
            };

            mSerialPort.DataReceived += new SerialDataReceivedEventHandler(mSerialPort_DataReceived);

            mWebClient = new WebClient();

        }

        private static void Terminate()
        {
            if (mSerialPort != null)
            {
                if (mSerialPort.IsOpen == true)
                {
                    mSerialPort.DiscardOutBuffer();
                    mSerialPort.DiscardInBuffer();
                    mSerialPort.Close();
                }

                mSerialPort.Dispose();
                mSerialPort = null;
            }

            if (mWebClient != null)
            {
                if (mWebClient.IsBusy == true)
                {
                    mWebClient.CancelAsync();
                }

                mWebClient.Dispose();
                mWebClient = null;
            }

        }

        private static void WaitForIncomingData()
        {
            while (Console.ReadKey(true).Key != ConsoleKey.Escape)
            {
            }
        }

        private static string _PrevData = string.Empty;

        private static void mSerialPort_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            //string EOT = ((char)13).ToString();
            string EOT = ((char)10).ToString();
            string SKP = ((char)254).ToString();

            int Char;
            string WebAddress;
            string WebContent = string.Empty;

            WebAddress = string.Empty;
            Char = mSerialPort.ReadChar();

            while (true)
            {
                try
                {
                    Char = mSerialPort.ReadChar();

                    // Check for End-of-transmission character
                    if (Char == 13)
                    {
                        break;
                    }

                    WebAddress += (char)Char;
                    //Console.Write((char)Char);
                }
                catch (Exception ex)
                {
                    Console.Write(" failed!");
                    Console.WriteLine();
                    Console.Write(ex.Message);
                    Console.WriteLine();
                    return;
                }
            }

            _PrevData = WebAddress;

            Console.Write("Received Message '" + WebAddress + "'.  Echoing message back...");

            Thread.Sleep(1000);

            WebContent = SKP;
            WebContent += WebAddress;
            WebContent += EOT;

            char[] CharArray;
            int ChunkSize = 255;
            int CharIndex = 0;
            int CharCount = ChunkSize;

            try
            {
                if (CharCount > WebContent.Length)
                {
                    CharCount = WebContent.Length;
                }

                while (true)
                {
                    CharArray = WebContent.ToCharArray(CharIndex, CharCount);
                    mSerialPort.Write(CharArray, 0, CharCount);
                    Thread.Sleep(10);

                    CharIndex += ChunkSize;
                    if (CharIndex >= WebContent.Length)
                    {
                        break;
                    }

                    if (CharIndex + CharCount >= WebContent.Length)
                    {
                        CharCount = WebContent.Length - CharIndex;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.Write(" failed!");
                Console.WriteLine();
                Console.Write(ex.Message);
                Console.WriteLine();
                return;
            }

            Console.Write(" successful!");
            Console.WriteLine();

        }

        private static void OpenSerialPort()
        {
            Console.Write("Opening serial port for '" + PortName + "'...");

            try
            {
                mSerialPort.Open();

                mSerialPort.DiscardInBuffer();
                mSerialPort.DiscardOutBuffer();

            }
            catch (Exception ex)
            {
                Console.Write(" failed!");
                Console.WriteLine();
                Console.Write(ex.Message);
                Console.WriteLine();
                return;
            }

            Console.Write(" successful!");
            Console.WriteLine();
        }

    }
}
