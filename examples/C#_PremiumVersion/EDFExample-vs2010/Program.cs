using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using Emotiv;

namespace EDFExample_vs2010
{
    class Program
    {
        static int option;
        static string fileName;
        static string eegFileName;
        static string motionFileName;
        static string patientID = "edfTest";
        static string recordID = "0";
        static string date = "25.12.14";
        static string time = "00:00:00";
        static UInt32 userId;
        static void engine_EmoEngineConnected(object sender, EmoEngineEventArgs e)
        {
            switch (option)
            {
                case 1:
                    Console.WriteLine("\nEnter full path of the edf file: (for example: C:\\edf\\testdata)\n");
                    fileName = Console.ReadLine();
                    break;
                case 2:
                    EmoEngine.Instance.StartLoadDatafromEDF();
                    break;
                default:
                    break;
            }
        }

        static void Main(string[] args)
        {
            EmoEngine engine = EmoEngine.Instance;

            engine.EmoEngineConnected +=
                new EmoEngine.EmoEngineConnectedEventHandler(engine_EmoEngineConnected);
            engine.UserAdded +=
                new EmoEngine.UserAddedEventHandler(engine_UserAdded);
            engine.EmoEngineDisconnected +=
                new EmoEngine.EmoEngineDisconnectedEventHandler(engine_EmoEngineDisconnected);

            while (true)
            {
                Console.Clear();
                Console.WriteLine("===================================================================");
                Console.WriteLine("Example to show how to save eeg data to edf file");
                Console.WriteLine("and how to load eeg data from edf file,");
                Console.WriteLine("then get emostates from this file without using the headset");
                Console.WriteLine("===================================================================");
                Console.WriteLine("Press '1' to record EEG data into EDF file		                  ");
                Console.WriteLine("Press '2' to load data from EDF file		                          ");
                Console.WriteLine("Press '3' to exit												  ");
                Console.Write(">>");

                eegFileName = "";
                motionFileName = "";
                string input = Console.ReadLine();
                while (input == "")
                {
                    input = Console.ReadLine();
                }

                option = int.Parse(input);

                
                switch (option)
                {
                    case 1:
                        {
                            engine.Connect();
                            break;
                        }
                    case 2:
                        {
                            Console.WriteLine("\nEnter full path of the EEG edf file: (for example: C:\\edf\\testdata.edf)\n");
                            eegFileName = Console.ReadLine();
                            Console.WriteLine("\nEnter full path of the EEG edf file: (for example: C:\\edf\\testdata.md.edf) or enter for non file\n");
                            motionFileName = Console.ReadLine();
                            engine.LocalConnect(eegFileName, motionFileName);
                            break;
                        }
                    default:
                        break;
                }

                if ((option != 1) && (option != 2)) break;
                Console.WriteLine("Start receiving data! Press any key to stop...\n");
                //Console.WriteLine("EmoState updating from {0}", userId);

                while (!Console.KeyAvailable)
                {
                    engine.ProcessEvents(100);
                }
                if (option == 1)
                    EmoEngine.Instance.StopSavingEEGData();

            }
            engine.Disconnect();
        }

        static void engine_EmoEngineDisconnected(object sender, EmoEngineEventArgs e)
        {

        }

        static void engine_UserAdded(object sender, EmoEngineEventArgs e)
        {
            if (option == 1)
                EmoEngine.Instance.StartSavingEEGData(userId, fileName, patientID, recordID, date, time);
        }
    }
}
