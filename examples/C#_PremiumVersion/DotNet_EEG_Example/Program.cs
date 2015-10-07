using System;
using System.Collections.Generic;
using Emotiv;
using System.IO;
using System.Threading;
using System.Reflection;

namespace EEG_Example_1
{
    class EEG_Logger
    {
        EmoEngine engine; // Access to the EDK is via the EmoEngine 
        int userID = -1; // userID is used to uniquely identify a user's headset
        string filename = "outfile.csv"; // output filename

        
        EEG_Logger()
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

            // enable data aquisition for this user.
            engine.DataAcquisitionEnable((uint)userID, true);
            
            // ask for up to 1 second of buffered data
            engine.DataSetBufferSizeInSec(1); 

        }
        void Run()
        {
            // Handle any waiting events
            engine.ProcessEvents();

            // If the user has not yet connected, do not proceed
            if ((int)userID == -1)
                return;

            Dictionary<EdkDll.IEE_DataChannel_t, double[]> data = engine.GetData((uint)userID);


            if (data == null)
            {
                return;
            }

            int _bufferSize = data[EdkDll.IEE_DataChannel_t.IED_TIMESTAMP].Length;

            Console.WriteLine("Writing " + _bufferSize.ToString() + " lines of data ");

            // Write the data to a file
            TextWriter file = new StreamWriter(filename,true);

            for (int i = 0; i < _bufferSize; i++)
            {
                // now write the data
                foreach (EdkDll.IEE_DataChannel_t channel in data.Keys)
                    file.Write(data[channel][i] + ",");
                file.WriteLine("");

            }
            file.Close();

        }

        public void WriteHeader()
        {
            TextWriter file = new StreamWriter(filename, false);

            string header = "	IED_COUNTER = 0, IED_INTERPOLATED,  IED_RAW_CQ, IED_AF3," + 
                "IED_T7, IED_Pz, IED_T8, IED_AF4, IED_GYROX, IED_GYROY, IED_TIMESTAMP, IED_ES_TIMESTAMP, IED_FUNC_ID, IED_FUNC_VALUE," +
                "IED_MARKER, IED_SYNC_SIGNAL";

            file.WriteLine(header);
            file.Close();
        }

        static void Main(string[] args)
        {
            Console.WriteLine("EEG Data Reader Example");

            EEG_Logger p = new EEG_Logger();

            for (int i = 0; i < 100; i++)
            {
                p.Run();
                Thread.Sleep(100);
            }
        }
    }
}
