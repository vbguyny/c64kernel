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
        private static string _InputFileName = string.Empty;
        private static string _OutputFileName = string.Empty;

        public static void Main(string[] args)
        {
            if (args.Contains("-?") == true)
            {
                DisplayHelpMessage();
                return;
            }

            if (ParseAndValidateArguments(args) == false)
            {
                return;
            }

            if (ProcessDumpFile() == false)
            {
                return;
            }

        }

        private static void DisplayHelpMessage()
        {
            Console.WriteLine("CBM prg Header Utility - VBGuyNY 2019");
            Console.WriteLine();
            Console.WriteLine("Usage:");
            Console.WriteLine("CBMprgHeader.exe InputDumpFile OutputHeaderFile");
            Console.WriteLine();
        }

        private static bool ParseAndValidateArguments(string[] args)
        {
            if (args.Length != 2)
            {
                Console.WriteLine("Invalid number of arguments. Use \"-?\" switch for usage details.");
                return false;
            }

            _InputFileName = args[0];
            _OutputFileName = args[1];

            if (File.Exists(_InputFileName) == false)
            {
                Console.WriteLine("The input file \"" + _InputFileName + "\" does not exist.");
                return false;
            }

            if (File.Exists(_OutputFileName) == true)
            {
                try
                {
                    File.Delete(_OutputFileName);
                }
                catch (Exception ex)
                {
                    Console.WriteLine("The output file \"" + _OutputFileName + "\" cannot be overwritten. " + ex.Message);
                    return false;
                }
            }

            return true;
        }

        private static bool ProcessDumpFile()
        {
            string[] InputLines;
            List<string> OutputList;

            Console.Write("Reading file \"" + _InputFileName + "\"...");
            try
            {
                InputLines = File.ReadAllLines(_InputFileName);
            }
            catch (Exception ex)
            {
                Console.WriteLine();
                Console.WriteLine("The input file \"" + _InputFileName + "\" cannot be read. " + ex.Message);
                return false;
            }
            Console.WriteLine(" Done!");

            OutputList = new List<string>();
            bool OkToProcessLine = false;

            Console.Write("Processing dump file...");
            foreach (string InputLine in InputLines)
            {
                if (InputLine.StartsWith("******* ") == true)
                {
                    OkToProcessLine = true;
                }
                else if (OkToProcessLine == true)
                {
                    if (InputLine.Contains("$ =") == true
                        || InputLine.Contains("$  =") == true)
                    {
                        OutputList.Add(InputLine);
                    }
                }

            }
            Console.WriteLine(" Done!");

            OutputList.Sort(); // Sort the list

            // Custom code to add to the end
            OutputList.Add("charset 2");
            OutputList.Add("*=$c000");

            Console.Write("Writing file \"" + _OutputFileName + "\"...");
            try
            {
                File.WriteAllLines(_OutputFileName, OutputList);
            }
            catch (Exception ex)
            {
                Console.WriteLine();
                Console.WriteLine("The output file \"" + _OutputFileName + "\" cannot be written. " + ex.Message);
                return false;
            }
            Console.WriteLine(" Done!");

            return true;
        }

    }
}
