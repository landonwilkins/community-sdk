using System;
using System.Collections.Generic;
using Emotiv;
using System.IO;
using System.Threading;
using System.Reflection;

namespace MotionDataLogger
{
    class MotionDataLogger
    {
        EmoEngine engine;   // Access to the EDK is via the EmoEngine 
        int userID = -1;    // userID is used to uniquely identify a user's headset
        string filename = "motionDataLogger.csv"; // output filename


        MotionDataLogger()
        {
            // create the engine
            engine = EmoEngine.Instance;
            engine.UserAdded += new EmoEngine.UserAddedEventHandler(engine_UserAdded_Event);

            // connect to Emoengine.            
            engine.Connect();

            // create a header for our output file
            WriteHeader();
        }

        void engine_UserAdded_Event(object sender, EmoEngineEventArgs e)
        {
            Console.WriteLine("User Added Event has occured");

            // record the user 
            userID = (int)e.userId;

            // ask for up to 1 second of buffered data
            engine.MotionDataSetBufferSizeInSec(1);
        }

        void Run()
        {
            // Handle any waiting events
            engine.ProcessEvents();

            // If the user has not yet connected, do not proceed
            if ((int)userID == -1)
                return;

            Dictionary<EdkDll.IEE_MotionDataChannel_t, double[]> data = engine.GetMotionData((UInt32)userID);

            if (data == null)
            {
                return;
            }

            int _bufferSize = data[EdkDll.IEE_MotionDataChannel_t.IMD_COUNTER].Length;

            Console.WriteLine("Writing " + _bufferSize.ToString() + " lines of data ");

            // Write the data to a file
            TextWriter file = new StreamWriter(filename, true);

            for (int i = 0; i < _bufferSize; i++)
            {
                // now write the data
                foreach (EdkDll.IEE_MotionDataChannel_t channel in data.Keys)
                    file.Write(data[channel][i] + ",");
                file.WriteLine("");

            }
            file.Close();

        }

        public void WriteHeader()
        {
            TextWriter file = new StreamWriter(filename, false);

            string header = "COUNTER, GYROX, GYROY, GYROZ, ACCX, " +
                "ACCY, ACCZ, MAGX, MAGY, MAGZ, TIMESTAMP";

            file.WriteLine(header);
            file.Close();
        }

        static void Main(string[] args)
        {
            Console.WriteLine("Motion Data Reader Example");

            MotionDataLogger p = new MotionDataLogger();

            for (int i = 0; i < 100; i++)
            {
                p.Run();
                Thread.Sleep(100);
            }
        }
    }
}
