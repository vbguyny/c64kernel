using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace Wav8To4bit
{
    class Program
    {
        private static string _InputFileName = string.Empty;
        private static string _OutputFileName = string.Empty;
        private static string _StartingHexAddress = string.Empty;
        private static int _StartingOffset = 0;

        public static int Main(string[] args)
        {
            if (args.Contains("-?") == true)
            {
                DisplayHelpMessage();
                return 0;
            }

            if (ParseAndValidateArguments(args) == false)
            {
                return 1;
            }

            if (ProcessFile() == false)
            {
                return 1;
            }

            return 0;
        }

        private static void DisplayHelpMessage()
        {
            Console.WriteLine("WAV 8 to 4 bit Utility - VBGuyNY 2020");
            Console.WriteLine();
            Console.WriteLine("Usage:");
            Console.WriteLine("Wav8To4bit.exe InputFileName OutputFileName [StartingHexAddress]");
            Console.WriteLine();
        }

        private static bool ParseAndValidateArguments(string[] args)
        {
            if (args.Length < 2)
            {
                Console.WriteLine("Invalid number of arguments. Use \"-?\" switch for usage details.");
                return false;
            }

            _InputFileName = args[0];
            _OutputFileName = args[1];
            _StartingHexAddress = args[2];

            if (File.Exists(_InputFileName) == false)
            {
                Console.WriteLine("The input file \"" + _InputFileName + "\" does not exist.");
                return false;
            }

            if (File.Exists(_OutputFileName) == true)
            {
                //Console.WriteLine("The output file \"" + _OutputFileName + "\" already exists.");
                //return false;
                try
                {
                    File.Delete(_OutputFileName);
                }
                catch (Exception ex)
                {
                    Console.WriteLine("The output file \"" + _OutputFileName + "\" cannout be deleted. " + ex.Message);
                    return false;
                }
            }

            if (string.IsNullOrWhiteSpace(_StartingHexAddress) == false)
            {
                try
                {
                    if (_StartingHexAddress.StartsWith("$") == true)
                    {
                        _StartingOffset = Convert.ToInt32(_StartingHexAddress.Replace("$", "0x"), 16);
                    }
                    else
                    {
                        _StartingOffset = Convert.ToInt32(_StartingHexAddress);
                        _StartingHexAddress = "$" + Convert.ToString(_StartingOffset, 16);
                    }
                }
                catch
                {
                    Console.WriteLine("Invalid starting hex address. Use \"-?\" switch for usage details.");
                    return false;
                }
            }

            return true;
        }

        private static bool ProcessFile()
        {

            FileInfo fiInputFile;
            FileStream fsInputFile;

            Console.WriteLine("Opening input file \"" + _InputFileName + "\"...");

            fiInputFile = new FileInfo(_InputFileName);

            try
            {
                fsInputFile = fiInputFile.OpenRead();
            }
            catch (Exception ex)
            {
                Console.WriteLine();
                Console.WriteLine("The input file \"" + _InputFileName + "\" cannot be openned. " + ex.Message);
                return false;
            }

            Console.WriteLine(" Filename: " + fiInputFile.FullName);
            Console.WriteLine(" Size: " + fiInputFile.Length.ToString());
            Console.WriteLine(" Date Modified: " + fiInputFile.LastWriteTime.ToString());
            Console.WriteLine("... Done!");
            Console.WriteLine();

            int BufferSize8 = 0;
            byte[] Buffer8 = null;

            FileInfo fiOutputFile;
            FileStream fsOutputFile;

            Console.WriteLine("Writing output file \"" + _OutputFileName + "\"...");

            fiOutputFile = new FileInfo(_OutputFileName);

            try
            {
                fsOutputFile = fiOutputFile.OpenWrite();
            }
            catch (Exception ex)
            {
                Console.WriteLine();
                Console.WriteLine("The output file \"" + _OutputFileName + "\" cannot be openned. " + ex.Message);
                return false;
            }

            BufferSize8 = (int)fiInputFile.Length;
            Buffer8 = new byte[BufferSize8];
            Console.WriteLine("Reading " + BufferSize8.ToString() + " bytes from the input file...");
            try
            {
                fsInputFile.Read(Buffer8, 0, BufferSize8);
            }
            catch (Exception ex)
            {
                Console.WriteLine();
                Console.WriteLine("Data cannot be read. " + ex.Message);
                return false;
            }
            fsInputFile.Close();
            Console.WriteLine("... Done!");

            int BufferSize4 = BufferSize8 / 2;
            byte[] Buffer4 = new byte[BufferSize4];

            Console.WriteLine("Converting 8 bit data to 4 bit...");

            for (int i = 0, j = 0; i <= BufferSize8 - 2; i+=2, j++)
            {
                Buffer4[j] = (byte)((Buffer8[i] & 0xF0) | ((Buffer8[i + 1] & 0xF0) >> 4));
            }

            Console.WriteLine("... Done!");

            Console.WriteLine("Writing data to the input file...");
            try
            {
                if (string.IsNullOrWhiteSpace(_StartingHexAddress) == false)
                {
                    fsOutputFile.Write(BitConverter.GetBytes((short)_StartingOffset), 0, 2);
                }
                
                fsOutputFile.Write(Buffer4, 0, BufferSize4);
                fsOutputFile.Flush();
            }
            catch (Exception ex)
            {
                Console.WriteLine();
                Console.WriteLine("Data cannot be written. " + ex.Message);
                return false;
            }
            fsOutputFile.Close();
            Console.WriteLine("... Done!");

            return true;
        }

    }
}
