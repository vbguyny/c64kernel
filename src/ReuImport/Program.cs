using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace ReuImport
{
    class Program
    {
        private static string _ReuFile = string.Empty;
        private static string _ImportFile = string.Empty;
        private static string _StartingHexAddress = string.Empty;
        private static int _StartingOffset = 0;
        private static int _SkipBytes = 0;
        private static bool _ClearMode = false;
        private static int _LengthBytes = 0;

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

            if (ProcessImportFile() == false)
            {
                return 1;
            }

            return 0;
        }

        private static void DisplayHelpMessage()
        {
            Console.WriteLine("REU Import Utility - VBGuyNY 2020");
            Console.WriteLine();
            Console.WriteLine("Usage:");
            Console.WriteLine("ReuImport.exe ReuFile ImportFile StartingHexAddress [SkipBytes]");
            Console.WriteLine("ReuImport.exe ReuFile -clear StartingHexAddress LengthBytes");
            Console.WriteLine();
        }

        private static bool ParseAndValidateArguments(string[] args)
        {
            if (args.Length < 3)
            {
                Console.WriteLine("Invalid number of arguments. Use \"-?\" switch for usage details.");
                return false;
            }

            _ReuFile = args[0];
            _ImportFile = args[1];
            _StartingHexAddress = args[2];

            if (File.Exists(_ReuFile) == false)
            {
                Console.WriteLine("The REU file \"" + _ReuFile + "\" does not exist.");
                return false;
            }

            if (_ImportFile.ToLower() == "-clear")
            {
                _ClearMode = true;
            }
            else
            {
                if (File.Exists(_ImportFile) == false)
                {
                    Console.WriteLine("The import file \"" + _ImportFile + "\" does not exist.");
                    return false;
                }
            }

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

            if (_ClearMode == true)
            {
                try
                {
                    _LengthBytes = int.Parse(args[3]);
                }
                catch
                {
                    Console.WriteLine("Invalid length bytes. Use \"-?\" switch for usage details.");
                    return false;
                }
            }
            else
            {
                try
                {
                    _SkipBytes = int.Parse(args[3]);
                }
                catch { }
            }

            return true;
        }

        private static bool ProcessImportFile()
        {

            FileInfo fiReuFile;
            FileStream fsReuFile;

            Console.WriteLine("Opening REU file \"" + _ReuFile + "\"...");
            
            fiReuFile = new FileInfo(_ReuFile);

            try
            {
                fsReuFile = fiReuFile.OpenWrite();
            }
            catch (Exception ex)
            {
                Console.WriteLine();
                Console.WriteLine("The REU file \"" + _ReuFile + "\" cannot be openned. " + ex.Message);
                return false;
            }

            Console.WriteLine(" Filename: " + fiReuFile.FullName);
            Console.WriteLine(" Size: " + fiReuFile.Length.ToString());
            Console.WriteLine(" Date Modified: " + fiReuFile.LastWriteTime.ToString());
            Console.WriteLine("... Done!");
            Console.WriteLine();

            if (_StartingOffset > fiReuFile.Length)
            {
                Console.WriteLine();
                Console.WriteLine("The starting address  exceeds the size of the REU file.");
                return false;
            }

            int BufferSize = 0;
            byte[] Buffer = null;

            if (_ClearMode == true)
            {
                BufferSize = _LengthBytes;
                Buffer = new byte[BufferSize];
            }
            else
            {
                FileInfo fiImportFile;
                FileStream fsImportFile;

                Console.WriteLine("Opening Import file \"" + _ImportFile + "\"...");

                fiImportFile = new FileInfo(_ImportFile);

                try
                {
                    fsImportFile = fiImportFile.OpenRead();
                }
                catch (Exception ex)
                {
                    Console.WriteLine();
                    Console.WriteLine("The Import file \"" + _ImportFile + "\" cannot be openned. " + ex.Message);
                    return false;
                }

                Console.WriteLine(" Filename: " + fiImportFile.FullName);
                Console.WriteLine(" Size: " + fiImportFile.Length.ToString());
                Console.WriteLine(" Date Modified: " + fiImportFile.LastWriteTime.ToString());
                Console.WriteLine("... Done!");
                Console.WriteLine();

                if (_SkipBytes > fiImportFile.Length)
                {
                    Console.WriteLine();
                    Console.WriteLine("The number of skip bytes exceeds the size of the import file.");
                    return false;
                }

                BufferSize = (int)fiImportFile.Length - _SkipBytes;
                Buffer = new byte[BufferSize];
                Console.WriteLine("Reading " + BufferSize.ToString() + " bytes from the import file (skipping " + _SkipBytes.ToString() + " bytes) ...");
                try
                {
                    fsImportFile.Position = _SkipBytes;
                    fsImportFile.Read(Buffer, 0, BufferSize);
                }
                catch (Exception ex)
                {
                    Console.WriteLine();
                    Console.WriteLine("Data cannot be read. " + ex.Message);
                    return false;
                }
                fsImportFile.Close();
                Console.WriteLine("... Done!");
            }

            Console.WriteLine("Writing " + BufferSize.ToString() + " bytes to the REU file at " + _StartingHexAddress + " ...");
            try
            {
                fsReuFile.Position = _StartingOffset;
                fsReuFile.Write(Buffer, 0, BufferSize);
                fsReuFile.Flush();
            }
            catch (Exception ex)
            {
                Console.WriteLine();
                Console.WriteLine("Data cannot be written. " + ex.Message);
                return false;
            }
            fsReuFile.Close();
            Console.WriteLine("... Done!");

            return true;
        }

    }
}
