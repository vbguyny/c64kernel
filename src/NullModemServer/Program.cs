using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.IO;
using System.IO.Ports;

using System.Net;
using System.Web;
using System.Net.Sockets;
using System.Net.NetworkInformation;

using System.Diagnostics;

using System.Threading;

namespace NullModemServer
{
    class NetworkInfo
    {
        public string Ssid = string.Empty;
        public string IpAddress = string.Empty;
        public string MacAddress = string.Empty;
        public string Gateway = string.Empty;
        public string Submask = string.Empty;
    }

    class Program
    {
        private static SerialPort mSerialPort = null;

        ////private const int BaudRate = 300;
        ////private const int BaudRate = 600;
        private const int BaudRate = 1200;
        //private const int BaudRate = 2400;
        //private const int BaudRate = 9600;
        ////private const int BaudRate = 4800;
        ////private const int BaudRate = 115200;

        private const Parity Parity = System.IO.Ports.Parity.None;
        //private const Parity Parity = System.IO.Ports.Parity.Even;
        //private const Parity Parity = System.IO.Ports.Parity.Odd;
        //private const Parity Parity = System.IO.Ports.Parity.Space;
        //private const Parity Parity = System.IO.Ports.Parity.Mark;

        private const int DataBits = 8;
        //private const int DataBits = 7;

        //private const StopBits StopBits = System.IO.Ports.StopBits.None;
        private const StopBits StopBits = System.IO.Ports.StopBits.One;
        //private const StopBits StopBits = System.IO.Ports.StopBits.OnePointFive;
        //private const StopBits StopBits = System.IO.Ports.StopBits.Two;

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

        //private static WebClient mWebClient = null;
        //private static TcpClient _TcpClient = null;
        private static TcpClientHandler _TcpClientHandler = null;

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

            //mWebClient = new WebClient();
            //_TcpClient = new TcpClient();
            _TcpClientHandler = new TcpClientHandler(mSerialPort);
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

            //if (mWebClient != null)
            //{
            //    if (mWebClient.IsBusy == true)
            //    {
            //        mWebClient.CancelAsync();
            //    }

            //    mWebClient.Dispose();
            //    mWebClient = null;
            //}

            //if (_TcpClient != null)
            //{
            //    try
            //    {
            //        _TcpClient.Close();
            //    }
            //    catch { }
            //    _TcpClient = null;
            //}


            if (_TcpClientHandler != null)
            {
                try
                {
                    _TcpClientHandler.Close();
                }
                catch { }
                _TcpClientHandler = null;
            }

        }

        private static void WaitForIncomingData()
        {
            while (Console.ReadKey(true).Key != ConsoleKey.Escape)
            {
            }
        }

        private static string _PrevData = string.Empty;

        private static bool _ShowWelcomeMessage = true;
        private static bool _EchoMode = true;
        private static string _CommandString = string.Empty;

        private static void mSerialPort_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            string Data;

            Data = mSerialPort.ReadExisting();

            foreach (char DataCharIn in Data)
            {
                ProcessDataReceived(DataCharIn);
            }

        }

        private static void ProcessDataReceived(char DataCharIn)
        {
            string Data;
            bool OkToProcessCommand = false;
            string ScreenChar = string.Empty;
            string DataChar = string.Empty;
            string CommandChar = string.Empty;

            //Data = mSerialPort.ReadExisting();
            Data = DataCharIn.ToString();

            //Console.Write(((int)Data[0]).ToString() + " ");
            //return;

            if (_TcpClientHandler.Connected == true)
            {
                try
                {
                    _TcpClientHandler.SendData(Data);
                }
                catch
                {
                    _TcpClientHandler.Close();
                }
                return;
            }

            switch (Data)
            {
                case "\r": // Return
                    OkToProcessCommand = true;
                    ScreenChar = Environment.NewLine;
                    //DataChar = Environment.NewLine;
                    CommandChar = string.Empty;

                    if (_ShowWelcomeMessage == true)
                    {
                        _CommandString = string.Empty;
                        OkToProcessCommand = false;
                        _ShowWelcomeMessage = false;

                        NetworkInfo networkInfo = GetNetworkInfo();

                        mSerialPort.Write(Environment.NewLine);
                        mSerialPort.Write("NULLMODEMSERVER BY VBGUYNY" + Environment.NewLine);
                        mSerialPort.Write(Environment.NewLine);
                        mSerialPort.Write("CONNECTING TO SSID " + networkInfo.Ssid + Environment.NewLine);
                        mSerialPort.Write("CONNECTED TO " + networkInfo.Ssid + Environment.NewLine);
                        mSerialPort.Write("IP ADDRESSS: " + networkInfo.IpAddress + Environment.NewLine);
                        mSerialPort.Write(Environment.NewLine);
                        mSerialPort.Write("OK");
                        mSerialPort.Write(Environment.NewLine);
                    }

                    if (_EchoMode == false)
                    {
                        //mSerialPort.Write(Environment.NewLine);
                    }

                    break;

                case "\u0014": // Backspace
                    ScreenChar = "\b \b";
                    DataChar = Data;
                    CommandChar = string.Empty;

                    if (string.IsNullOrEmpty(_CommandString) == false)
                    {
                        _CommandString = _CommandString.Remove(_CommandString.Length - 1, 1);
                    }
                    break;

                default:
                    ScreenChar = Data;
                    DataChar = Data;
                    CommandChar = Data;
                    break;
            }

            Console.Write(ScreenChar);


            if (string.IsNullOrEmpty(DataChar) == false)
            {
                //if (_EchoMode == true)
                if (_EchoMode == true && _ShowWelcomeMessage == false)
                {
                    mSerialPort.Write(DataChar);
                }
            }

            if (OkToProcessCommand == true)
            {
                if (string.IsNullOrWhiteSpace(_CommandString) == true)
                {
                    return;
                }

                mSerialPort.Write(Environment.NewLine);

                switch (_CommandString)
                {
                    case "AT?":
                        mSerialPort.Write(Environment.NewLine);
                        mSerialPort.Write("NULLMODEMSERVER BY VBGUYNY" + Environment.NewLine);
                        mSerialPort.Write(Environment.NewLine);
                        mSerialPort.Write("AT COMMAND SUMMARY:" + Environment.NewLine);
                        //mSerialPort.Write("LOAD VRAM....:  AT&V" + Environment.NewLine);
                        mSerialPort.Write("DOWNLOAD URL.:  ATGET URL" + Environment.NewLine);
                        mSerialPort.Write("QUERY MOST COMMANDS FOLLOWED BY '?'" + Environment.NewLine);
                        mSerialPort.Write(Environment.NewLine);
                        mSerialPort.Write("OK");
                        break;
                    case "ATI":

                        if (NetworkInterface.GetIsNetworkAvailable() == true)
                        {
                            //NetworkInterface NetworkInterface = null;
                            //foreach (NetworkInterface ni in NetworkInterface.GetAllNetworkInterfaces())
                            //{
                            //    if (ni.NetworkInterfaceType != NetworkInterfaceType.Ethernet
                            //        && ni.NetworkInterfaceType != NetworkInterfaceType.Wireless80211)
                            //    {
                            //        continue;
                            //    }

                            //    if (ni.OperationalStatus != OperationalStatus.Up)
                            //    {
                            //        continue;
                            //    }

                            //    NetworkInterface = ni;
                            //    break;
                            //}

                            //string Ssid = GetWifiSsid();

                            //IPInterfaceProperties IPInterfaceProperties = NetworkInterface.GetIPProperties();

                            //string IPAddress = string.Empty;
                            //string SubnetMask = string.Empty;
                            //foreach (UnicastIPAddressInformation ip in IPInterfaceProperties.UnicastAddresses)
                            //{
                            //    if (ip.Address.AddressFamily == AddressFamily.InterNetwork)
                            //    {
                            //        IPAddress = ip.Address.ToString();
                            //        SubnetMask = ip.IPv4Mask.ToString();
                            //    }
                            //}

                            //string GatewayAddress = string.Empty;
                            //foreach (GatewayIPAddressInformation gateway in IPInterfaceProperties.GatewayAddresses)
                            //{
                            //    if (gateway.Address.AddressFamily == AddressFamily.InterNetwork)
                            //    {
                            //        GatewayAddress = gateway.Address.ToString();
                            //    }
                            //}

                            //string MacAddress = string.Empty;
                            //foreach (byte mac in NetworkInterface.GetPhysicalAddress().GetAddressBytes())
                            //{
                            //    if (string.IsNullOrEmpty(MacAddress) == false)
                            //    {
                            //        MacAddress += ":";
                            //    }
                            //    MacAddress += mac.ToString("X2");
                            //}

                            NetworkInfo ni = GetNetworkInfo();

                            mSerialPort.Write("WIFI STATUS: CONNECTED" + Environment.NewLine);
                            mSerialPort.Write("SSID.......: " + ni.Ssid + Environment.NewLine);
                            mSerialPort.Write("MAC ADDRESS: " + ni.MacAddress + Environment.NewLine);
                            mSerialPort.Write("IP ADDRESS.: " + ni.IpAddress + Environment.NewLine);
                            mSerialPort.Write("GATEWAY....: " + ni.Gateway + Environment.NewLine);
                            mSerialPort.Write("SUBNET MASK: " + ni.Submask + Environment.NewLine);
                            mSerialPort.Write("SERVER PORT: N/A" + Environment.NewLine);
                            mSerialPort.Write("WEB CONFIG.: N/A" + Environment.NewLine);
                            mSerialPort.Write("CALL STATUS: NOT CONNECTED" + Environment.NewLine);
                        }
                        else
                        {
                            mSerialPort.Write("WIFI STATUS: OFFLINE" + Environment.NewLine);
                            mSerialPort.Write("SSID.......: " + Environment.NewLine);
                            mSerialPort.Write("MAC ADDRESS: " + Environment.NewLine);
                            mSerialPort.Write("IP ADDRESS.: " + Environment.NewLine);
                            mSerialPort.Write("GATEWAY....: " + Environment.NewLine);
                            mSerialPort.Write("SUBNET MASK: " + Environment.NewLine);
                            mSerialPort.Write("SERVER PORT: N/A" + Environment.NewLine);
                            mSerialPort.Write("WEB CONFIG.: N/A" + Environment.NewLine);
                            mSerialPort.Write("CALL STATUS: NOT CONNECTED" + Environment.NewLine);
                        }

                        mSerialPort.Write(Environment.NewLine);
                        mSerialPort.Write("OK");
                        break;
                    case "AT":
                        mSerialPort.Write(Environment.NewLine);
                        mSerialPort.Write("OK");
                        break;
                    case "ATE":
                    case "ATE0":
                        _EchoMode = false;
                        mSerialPort.Write(Environment.NewLine);
                        mSerialPort.Write("OK");
                        break;
                    case "ATE1":
                        _EchoMode = true;
                        mSerialPort.Write(Environment.NewLine);
                        mSerialPort.Write("OK");
                        break;
                    case "ATE?":
                        mSerialPort.Write(Environment.NewLine);
                        mSerialPort.Write((_EchoMode == true ? "1" : "0"));
                        break;
                    default:
                        if (_CommandString.StartsWith("ATGET") == true)
                        {
                            mSerialPort.Write(Environment.NewLine);

                            DateTime dtStart = DateTime.Now;

                            string WebAddress = _CommandString.Substring(5).Replace(" ", string.Empty);
                            string WebContent = string.Empty;

                            try
                            {
                                //WebContent = mWebClient.DownloadString(WebAddress);

                                string[] WebAddressParts = WebAddress.Split('/');
                                string HostName = WebAddressParts[2];
                                string RelativeWebAddress = string.Join("/", WebAddressParts, 3, WebAddressParts.Length - 3);

                                TcpClient tcp = new TcpClient();
                                tcp.Connect(HostName, 80);

                                using (NetworkStream ns = tcp.GetStream())
                                {
                                    using (StreamWriter sw = new StreamWriter(tcp.GetStream()))
                                    {
                                        sw.WriteLine("GET /" + RelativeWebAddress + " HTTP/1.1");
                                        sw.WriteLine("Host: " + HostName);
                                        sw.WriteLine("Connection: close");
                                        sw.WriteLine();
                                        sw.Flush();

                                        using (StreamReader sr = new StreamReader(tcp.GetStream()))
                                        {
                                            WebContent = sr.ReadToEnd();
                                        }
                                    }
                                }
                                tcp.Close();

                                Console.WriteLine(WebContent);

                                mSerialPort.Write("CONNECT " + BaudRate.ToString() + Environment.NewLine);
                                mSerialPort.Write(WebContent);
                                mSerialPort.Write(Environment.NewLine);
                            }
                            catch { }

                            DateTime dtEnd = DateTime.Now;

                            mSerialPort.Write("NO CARRIER (" + (dtEnd - dtStart).ToString(@"hh\:mm\:ss") + ")");
                        }
                        else if (_CommandString.StartsWith("ATDT") == true)
                        {
                            string WebAddress = _CommandString.Substring(4).Replace(" ", string.Empty);
                            string WebContent = string.Empty;

                            string[] WebAddressParts;
                            string HostName = string.Empty;
                            int PortNumber = 23;

                            try
                            {
                                WebAddressParts = WebAddress.Split(':');
                                HostName = WebAddressParts[0];
                                PortNumber = Convert.ToInt32(WebAddressParts[1]);
                            }
                            catch { }

                            mSerialPort.Write("DIALING " + HostName + ":" + PortNumber.ToString());
                            mSerialPort.Write(Environment.NewLine);
                            mSerialPort.Write(Environment.NewLine);

                            if (string.IsNullOrEmpty(HostName) == true)
                            {
                                mSerialPort.Write("NO ANSWER");
                            }
                            else
                            {
                                try
                                {

                                    _TcpClientHandler.Connect(HostName, PortNumber);

                                    //NetworkStream ns = _TcpClient.GetStream();
                                    //TcpClientHandler tch = new TcpClientHandler(_TcpClient, mSerialPort);

                                    mSerialPort.Write("CONNECT " + BaudRate.ToString());
                                    //mSerialPort.Write(WebContent);
                                    //mSerialPort.Write(Environment.NewLine);
                                }
                                catch
                                {
                                    mSerialPort.Write("NO ANSWER");
                                }
                            }
                        }
                        else if (_CommandString.StartsWith("AT&") == true)
                        {
                            mSerialPort.Write(Environment.NewLine);
                            mSerialPort.Write("OK");
                        }
                        else
                        {
                            mSerialPort.Write(Environment.NewLine);
                            mSerialPort.Write("ERROR");
                        }
                        break;
                }

                mSerialPort.Write(Environment.NewLine);

                _CommandString = string.Empty;
            }
            else
            {
                if (CommandChar != " ")
                {
                    _CommandString += CommandChar;
                }
            }

            //foreach (char c in WebAddress)
            //{
            //    Console.Write((int)c);
            //}

            return;

        }

        private static string GetWifiSsid()
        {
            string ssid = string.Empty;

            try
            {
                Process process = new Process
                {
                    StartInfo =
                    {
                    FileName = "netsh.exe",
                    Arguments = "wlan show interfaces",
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    CreateNoWindow = true
                    }
                };
                process.Start();

                var output = process.StandardOutput.ReadToEnd();
                var line = output.Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries).FirstOrDefault(l => l.Contains("SSID") && !l.Contains("BSSID"));
                if (line == null)
                {
                    return string.Empty;
                }
                ssid = line.Split(new[] { ":" }, StringSplitOptions.RemoveEmptyEntries)[1].TrimStart();
            }
            catch { }

            return ssid;
        }

        private static NetworkInfo GetNetworkInfo()
        {
            NetworkInfo networkInfo = new NetworkInfo();

            if (NetworkInterface.GetIsNetworkAvailable() == true)
            {
                NetworkInterface NetworkInterface = null;
                foreach (NetworkInterface ni in NetworkInterface.GetAllNetworkInterfaces())
                {
                    if (ni.NetworkInterfaceType != NetworkInterfaceType.Ethernet
                        && ni.NetworkInterfaceType != NetworkInterfaceType.Wireless80211)
                    {
                        continue;
                    }

                    if (ni.OperationalStatus != OperationalStatus.Up)
                    {
                        continue;
                    }

                    NetworkInterface = ni;
                    break;
                }

                string Ssid = GetWifiSsid();

                IPInterfaceProperties IPInterfaceProperties = NetworkInterface.GetIPProperties();

                string IPAddress = string.Empty;
                string SubnetMask = string.Empty;
                foreach (UnicastIPAddressInformation ip in IPInterfaceProperties.UnicastAddresses)
                {
                    if (ip.Address.AddressFamily == AddressFamily.InterNetwork)
                    {
                        IPAddress = ip.Address.ToString();
                        SubnetMask = ip.IPv4Mask.ToString();
                    }
                }

                string GatewayAddress = string.Empty;
                foreach (GatewayIPAddressInformation gateway in IPInterfaceProperties.GatewayAddresses)
                {
                    if (gateway.Address.AddressFamily == AddressFamily.InterNetwork)
                    {
                        GatewayAddress = gateway.Address.ToString();
                    }
                }

                string MacAddress = string.Empty;
                foreach (byte mac in NetworkInterface.GetPhysicalAddress().GetAddressBytes())
                {
                    if (string.IsNullOrEmpty(MacAddress) == false)
                    {
                        MacAddress += ":";
                    }
                    MacAddress += mac.ToString("X2");
                }

                networkInfo.Ssid = Ssid;
                networkInfo.IpAddress = IPAddress;
                networkInfo.MacAddress = MacAddress;
                networkInfo.Gateway = GatewayAddress;
                networkInfo.Submask = SubnetMask;
            }

            return networkInfo;
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

    public class TcpClientHandler

    {

        private byte[] Buffer = null; // new byte[4096];

        private const int BufferSize = 1;

        private AsyncCallback AsyncReceiveCallback = new AsyncCallback(ProcessReceiveResults);

        // Let's create a network stream to communicate over the connected Socket.

        //private NetworkStream NetworkStream = null;
        private TcpClient TcpClient = null;

        private SerialPort SerialPort = null;

        private DateTime dtStart;

        public bool Connected = false;

        public TcpClientHandler(SerialPort serialPort)
        {
            SerialPort = serialPort;
        }

        public TcpClientHandler(string hostName, int portNumber, SerialPort serialPort)
        {
            SerialPort = serialPort;
            Connect(hostName, portNumber);
        }

        public void Connect(string hostName, int portNumber)
        {

            this.Close();

            try

            {

                // Setup a network stream on the server Socket

                //NetworkStream = networkStream;
                TcpClient = new TcpClient();
                TcpClient.Connect(hostName, portNumber);

                this.dtStart = DateTime.Now;
                this.Connected = true;
                Console.WriteLine("NetworkStream() is OK...");

                Buffer = new byte[BufferSize];
                TcpClient.GetStream().BeginRead(Buffer, 0, Buffer.Length, AsyncReceiveCallback, this);

                Console.WriteLine("BeginRead() is OK...");

            }

            catch (Exception e)

            {

                Console.WriteLine(e.Message);
                throw;

            }

        }

        public void Close()
        {
            if (this.Connected == true)
            {
                Console.WriteLine("Connection is closing.");
            }

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

                //Console.WriteLine("Connection received " + BytesRead.ToString() + " byte(s).");



                if (BytesRead == 0)

                {

                    //Console.WriteLine("Connection is closing.");

                    //NSH.NetworkStream.Close();
                    TCH.Close();

                    DateTime dtEnd = DateTime.Now;

                    TCH.SerialPort.Write(Environment.NewLine);
                    TCH.SerialPort.Write("NO CARRIER (" + (dtEnd - TCH.dtStart).ToString(@"hh\:mm\:ss") + ")");
                    TCH.SerialPort.Write(Environment.NewLine);

                    return;

                }

                else
                {
                    //string Data = Encoding.ASCII.GetString(TCH.Buffer);
                    string Data = System.Text.Encoding.GetEncoding(28591).GetString(TCH.Buffer);

                    //switch (Data)
                    //{
                    //    case "ABC":
                    //        byte[] Buffer = Encoding.ASCII.GetBytes("mostly sunny");
                    //        NSH.NetworkStream.Write(Buffer, 0, Buffer.Length);
                    //        break;
                    //}

                    Console.Write(Data);

                    TCH.SerialPort.Write(Data);
                }

                TCH.Buffer = new byte[BufferSize];
                TCH.TcpClient.GetStream().BeginRead(TCH.Buffer, 0, TCH.Buffer.Length, TCH.AsyncReceiveCallback, TCH);

            }

            catch (Exception e)

            {

                Console.WriteLine("Failed to read from a network stream with error: " + e.Message);

                //TCH.NetworkStream.Close();
                TCH.Close();

                DateTime dtEnd = DateTime.Now;

                TCH.SerialPort.Write(Environment.NewLine);
                TCH.SerialPort.Write("NO CARRIER (" + (dtEnd - TCH.dtStart).ToString(@"hh\:mm\:ss") + ")");
                TCH.SerialPort.Write(Environment.NewLine);

            }

        }

    }

}
