using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace CBMprgHeader
{
    class Program
    {
        private static string _HvscRootFolder = string.Empty;
        private static string _DumpFolder = string.Empty;
        private static string _InitAddress = string.Empty;
        private static byte _InitAddressHigh = 0;
        private static byte _InitAddressLow = 0;
        private static string _MaxSize = string.Empty;
        private static int _MaximumSize = 0;

        public static void Main(string[] args)
        {
            //args = new string[] { @"D:\c64\C64Music_All", @"D:\c64\C64Music_Dump\9000", @"$9000", "12288" };
            //args = new string[] { @"D:\c64\C64Music_All", @"D:\c64\C64Music_Dump\a000", @"$a000", "8192" };
            //args = new string[] { @"D:\c64\C64Music_All", @"D:\c64\C64Music_Dump\b000", @"$b000", "4096" };

            if (args.Contains("-?") == true)
            {
                DisplayHelpMessage();
                return;
            }

            if (ParseAndValidateArguments(args) == false)
            {
                return;
            }

            if (ProcessHvscFolder() == false)
            {
                return;
            }

        }

        private static void DisplayHelpMessage()
        {
            Console.WriteLine("HVSC Search Utility - VBGuyNY 2019");
            Console.WriteLine();
            Console.WriteLine("Usage:");
            Console.WriteLine("HvscSearch.exe HvscRootFolder DumpFolder InitAddress MaxFileSize");
            Console.WriteLine();
        }

        private static bool ParseAndValidateArguments(string[] args)
        {
            if (args.Length != 4)
            {
                Console.WriteLine("Invalid number of arguments. Use \"-?\" switch for usage details.");
                return false;
            }

            _HvscRootFolder = args[0];
            _DumpFolder = args[1];
            _InitAddress = args[2];
            _MaxSize = args[3];

            if (Directory.Exists(_HvscRootFolder) == false)
            {
                Console.WriteLine("The Hvsc Root Folder \"" + _HvscRootFolder + "\" does not exist.");
                return false;
            }

            if (_HvscRootFolder.EndsWith("\\") == false)
            {
                _HvscRootFolder += "\\";
            }

            if (Directory.Exists(_DumpFolder) == false)
            {
                try
                {
                    Directory.CreateDirectory(_DumpFolder);
                }
                catch (Exception ex)
                {
                    Console.WriteLine("The dump folder \"" + _DumpFolder + "\" cannot be created. " + ex.Message);
                    return false;
                }
            }

            if (_DumpFolder.EndsWith("\\") == false)
            {
                _DumpFolder += "\\";
            }

            if (string.IsNullOrEmpty(_InitAddress) == true)
            {
                Console.WriteLine("The Init Address is not specified does not exist.");
                return false;
            }

            _InitAddress = _InitAddress.Replace("$", string.Empty);
            int InitAddress = Convert.ToInt32(_InitAddress, 16);
            if (InitAddress < 0 || InitAddress > 0xffff)
            {
                Console.WriteLine("The Init Address \"" + _InitAddress + "\" must be in the range of $0000 to $ffff.");
                return false;
            }

            _InitAddressHigh = Convert.ToByte(_InitAddress.Substring(0, 2), 16);
            _InitAddressLow = Convert.ToByte(_InitAddress.Substring(2, 2), 16);

            if (string.IsNullOrEmpty(_MaxSize) == true)
            {
                Console.WriteLine("The Maximum Size is not specified does not exist.");
                return false;
            }

            _MaximumSize = Convert.ToInt32(_MaxSize);

            return true;
        }

        private static bool ProcessHvscFolder()
        {
            string FolderPath = _HvscRootFolder;

            Console.Write("Getting matching files in folder \"" + FolderPath + "\"...");

            string[] FileNames = Directory.GetFiles(FolderPath, "*.sid", SearchOption.AllDirectories);

            Console.WriteLine(" Done!");

            foreach (string FileName in FileNames)
            {
                ProcessHvscFile(FileName);
            }

            return true;
        }

        private static bool ProcessHvscFile(string FileName)
        {

            Console.Write("Reading file \"" + FileName + "\"...");

            FileInfo fi = new FileInfo(FileName);
            if (fi.Length > _MaximumSize)
            {
                Console.WriteLine(" Done!");
                return false;
            }

            using (FileStream fs = File.OpenRead(FileName))
            {
                byte[] buffer = new byte[16];
                fs.Read(buffer, 0, 16);

                byte InitAddressHigh = buffer[10];
                byte InitAddressLow = buffer[11];

                if (InitAddressHigh != _InitAddressHigh
                    || InitAddressLow != _InitAddressLow)
                {
                    Console.WriteLine(" Done!");
                    return false;
                }
            }

            string SourceFileName = FileName;
            string DestinationFileName = _DumpFolder + FileName.ToLower().Replace(_HvscRootFolder.ToLower(), string.Empty).Replace("\\", "_");

            Console.Write(" Done! Copying file to \"" + DestinationFileName + "\" ...");

            if (File.Exists(DestinationFileName) == false)
            {
                File.Copy(SourceFileName, DestinationFileName);
            }

            Console.WriteLine(" Done!");

            return true;
        }

    }
}
