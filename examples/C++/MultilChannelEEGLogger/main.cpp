/****************************************************************************
**
** Copyright 2015 by Emotiv. All rights reserved
** Example - MultichanelIEEGLogger
** This example is similar with the exaple 5( IEEGLogger ) , except using the
** IEE_DataGetMultiChannels function instead for EE_DataGet().
** It gets all data from all channels in channel list and logs to file
** (ie mydata.csv)
****************************************************************************/

#include <iostream>
#include <fstream>
#include <sstream>
#include <map>
#include <cstdlib>
#include <stdexcept>

#ifdef _WIN32
    #include <conio.h>
    #include <windows.h>
#endif
#ifdef __linux__
    #include <unistd.h>
#endif

#include "IEmoStateDLL.h"
#include "Iedk.h"
#include "IedkErrorCode.h"

IEE_DataChannel_t targetChannelList[] = {
		IED_COUNTER,
        IED_INTERPOLATED,
        IED_RAW_CQ,
        IED_AF3,
        IED_T7,
        IED_Pz,
        IED_T8,
        IED_AF4,
        IED_TIMESTAMP,
        IED_MARKER,
        IED_SYNC_SIGNAL
	};

const char header[] = "COUNTER, INTERPOLATED, RAW_CQ, AF3,"
	"T7, Pz, T8, AF4, TIMESTAMP, MARKER, SYNC_SIGNAL";
#ifdef __linux__
int _kbhit(void);
#endif

int main(int argc, char** argv) {

	EmoEngineEventHandle eEvent			= IEE_EmoEngineEventCreate();
	EmoStateHandle eState				= IEE_EmoStateCreate();
	unsigned int userID					= 0;
	const unsigned short composerPort	= 1726;
	float secs							= 1;
	unsigned int datarate				= 0;
	bool readytocollect					= false;
	int option							= 0;
	int state							= 0;


	std::string input;

	try {

		if (argc != 2) {
            throw std::runtime_error("Please supply the log file name.\n"
                                     "Usage: MultiChannelIEEGLogger [log_file_name].");
		}

        std::cout << "==================================================================="
                  << std::endl;
        std::cout << "Example to show how to log IEEG Data from "
                  << "EmoDriver/EmoComposer."
                  << std::endl;
        std::cout << "==================================================================="
                  << std::endl;
        std::cout << "Press '1' to start and connect to the Emotiv Driver "
                  << std::endl;
        std::cout << "Press '2' to connect to the EmoComposer         "
                  << std::endl;
		std::cout << ">> ";

		std::getline(std::cin, input, '\n');
		option = atoi(input.c_str());

		switch (option) {
			case 1:
			{
				if (IEE_EngineConnect() != EDK_OK) {
                    throw std::runtime_error(
                                "Emotiv Driver start up failed.");
				}
				break;
			}
			case 2:
			{
				std::cout << "Target IP of EmoComposer? [127.0.0.1] ";
				std::getline(std::cin, input, '\n');

				if (input.empty()) {
					input = std::string("127.0.0.1");
				}

				if (IEE_EngineRemoteConnect(input.c_str(), composerPort) != EDK_OK) {
                    std::string errMsg = "Cannot connect to EmoComposer on [" +
                                            input + "]";
                    throw std::runtime_error(errMsg.c_str());
				}
				break;
			}
			default:
                throw std::runtime_error("Invalid option...");
				break;
		}
		
		
        std::cout << "Start receiving IEEG Data! Press any key to stop logging...\n"
                  << std::endl;
    	std::ofstream ofs(argv[1],std::ios::trunc);
		ofs << header << std::endl;
		
		DataHandle hData = IEE_DataCreate();
		IEE_DataSetBufferSizeInSec(secs);

		std::cout << "Buffer size in secs:" << secs << std::endl;

		while (!_kbhit()) {

			state = IEE_EngineGetNextEvent(eEvent);

			if (state == EDK_OK) {

				IEE_Event_t eventType = IEE_EmoEngineEventGetType(eEvent);
				IEE_EmoEngineEventGetUserId(eEvent, &userID);

				// Log the EmoState if it has been updated
				if (eventType == IEE_UserAdded) {
					std::cout << "User added";
					IEE_DataAcquisitionEnable(userID,true);
					readytocollect = true;
				}
			}

			if (readytocollect) {

                IEE_DataUpdateHandle(0, hData);

                unsigned int nSamplesTaken=0;
                IEE_DataGetNumberOfSample(hData,&nSamplesTaken);

                std::cout << "Updated " << nSamplesTaken << std::endl;

                if (nSamplesTaken != 0) {
                    unsigned int channelCount = sizeof(targetChannelList)/
                                                sizeof(IEE_DataChannel_t);
                    double ** buffer = new double*[channelCount];
                    for (int i=0; i<channelCount; i++)
                        buffer[i] = new double[nSamplesTaken];

                    IEE_DataGetMultiChannels(hData, targetChannelList,
                                             channelCount, buffer, nSamplesTaken);

                    for (int sampleIdx=0 ; sampleIdx<(int)nSamplesTaken ;
                         ++ sampleIdx) {
                        for (int i = 0 ; i<sizeof(targetChannelList)/
                                           sizeof(IEE_DataChannel_t) ; i++) {

                            ofs << buffer[i][sampleIdx] << ",";
                        }
                        ofs << std::endl;
                    }
                    for (int i=0; i<channelCount; i++)
                        delete buffer[i];
                    delete buffer;
                }

			}

#ifdef _WIN32
            Sleep(1);
#endif
#ifdef __linux__
            sleep(1);
#endif
		}

		ofs.close();
		IEE_DataFree(hData);

	}
    catch (const std::runtime_error& e) {
		std::cerr << e.what() << std::endl;
		std::cout << "Press any key to exit..." << std::endl;
		getchar();
	}

	IEE_EngineDisconnect();
	IEE_EmoStateFree(eState);
	IEE_EmoEngineEventFree(eEvent);

	return 0;
}

#ifdef __linux__
int _kbhit(void)
{
    struct timeval tv;
    fd_set read_fd;

    tv.tv_sec=0;
    tv.tv_usec=0;

    FD_ZERO(&read_fd);
    FD_SET(0,&read_fd);

    if(select(1, &read_fd,NULL, NULL, &tv) == -1)
    return 0;

    if(FD_ISSET(0,&read_fd))
        return 1;

    return 0;
}
#endif
