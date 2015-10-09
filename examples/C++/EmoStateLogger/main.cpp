/****************************************************************************
**
** Copyright 2015 by Emotiv. All rights reserved
** Example - EmoStateLogger
** This example demonstrates the use of the core Emotiv API functions.
** It logs all Emotiv detection results for the attached users after
** successfully establishing a connection to Emotiv EmoEngineTM or
** EmoComposerTM
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

void logEmoState(std::ostream& os, unsigned int userID,
                 EmoStateHandle eState, bool withHeader = false);

#ifdef __linux__
int _kbhit(void);
#endif

int main(int argc, char** argv) {

	EmoEngineEventHandle eEvent			= IEE_EmoEngineEventCreate();
	EmoStateHandle eState				= IEE_EmoStateCreate();
	unsigned int userID					= 0;
	const unsigned short composerPort	= 1726;
	int option = 0;
	int state  = 0;
	std::string input;

	try {

		if (argc != 2) {
            throw std::runtime_error("Please supply the log file name.\n"
                                     "Usage: EmoStateLogger [log_file_name].");
		}

        std::cout << "==================================================================="
                  << std::endl;
        std::cout << "Example to show how to log the EmoState from EmoEngine/EmoComposer."
                  << std::endl;
        std::cout << "==================================================================="
                  << std::endl;
        std::cout << "Press '1' to start and connect to the EmoEngine                    "
                  << std::endl;
        std::cout << "Press '2' to connect to the EmoComposer                            "
                  << std::endl;
		std::cout << ">> ";

		std::getline(std::cin, input, '\n');
		option = atoi(input.c_str());

		switch (option) {
        case 1:
        {
            if (IEE_EngineConnect() != EDK_OK) {
                throw std::runtime_error("Emotiv Driver start up failed.");
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
		
		
        std::cout << "Start receiving EmoState! Press any key to stop logging...\n"
                  << std::endl;

		std::ofstream ofs(argv[1]);
		bool writeHeader = true;
		
		while (!_kbhit()) {

			state = IEE_EngineGetNextEvent(eEvent);

			// New event needs to be handled
			if (state == EDK_OK) {

				IEE_Event_t eventType = IEE_EmoEngineEventGetType(eEvent);
				IEE_EmoEngineEventGetUserId(eEvent, &userID);

				// Log the EmoState if it has been updated
				if (eventType == IEE_EmoStateUpdated) {

					IEE_EmoEngineEventGetEmoState(eEvent, eState);
					const float timestamp = IS_GetTimeFromStart(eState);

                    printf("%10.3fs : New EmoState from user %d ...\r",
                           timestamp, userID);
					
					logEmoState(ofs, userID, eState, writeHeader);
					writeHeader = false;
				}
			}
			else if (state != EDK_NO_EVENT) {
				std::cout << "Internal error in Emotiv Engine!" << std::endl;
				break;
			}

#ifdef _WIN32
            Sleep(1);
#endif
#ifdef __linux__
            sleep(1);
#endif
		}

		ofs.close();
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


void logEmoState(std::ostream& os, unsigned int userID,
                 EmoStateHandle eState, bool withHeader) {

	// Create the top header
	if (withHeader) {
		os << "Time,";
		os << "UserID,";
		os << "Wireless Signal Status,";
		os << "Blink,";
		os << "Wink Left,";
		os << "Wink Right,";
		os << "Surprise,";
		os << "Frown,";
		os << "Smile,";
		os << "Clench,";
		os << "Instantaneous Excitement,";
		os << "Long Term Excitement,";
		os << "Engagement/Boredom,";
		os << "MentalCommand Action,";
		os << "MentalCommand Power,";
		os << std::endl;
	}

	// Log the time stamp and user ID
	os << IS_GetTimeFromStart(eState) << ",";
	os << userID << ",";
	os << static_cast<int>(IS_GetWirelessSignalStatus(eState)) << ",";

	// FacialExpression Suite results
	os << IS_FacialExpressionIsBlink(eState) << ",";
	os << IS_FacialExpressionIsLeftWink(eState) << ",";
	os << IS_FacialExpressionIsRightWink(eState) << ",";



	std::map<IEE_FacialExpressionAlgo_t, float> expressivStates;

    IEE_FacialExpressionAlgo_t upperFaceAction =
            IS_FacialExpressionGetUpperFaceAction(eState);
    float upperFacePower  = IS_FacialExpressionGetUpperFaceActionPower(eState);

    IEE_FacialExpressionAlgo_t lowerFaceAction =
            IS_FacialExpressionGetLowerFaceAction(eState);
    float	lowerFacePower  = IS_FacialExpressionGetLowerFaceActionPower(eState);

	expressivStates[ upperFaceAction ] = upperFacePower;
	expressivStates[ lowerFaceAction ] = lowerFacePower;
	
	os << expressivStates[ FE_SURPRISE     ] << ","; // eyebrow
	os << expressivStates[ FE_FROWN      ] << ","; // furrow
	os << expressivStates[ FE_SMILE       ] << ","; // smile
	os << expressivStates[ FE_CLENCH      ] << ","; // clench

	// MentalCommand Suite results
	os << static_cast<int>(IS_MentalCommandGetCurrentAction(eState)) << ",";
	os << IS_MentalCommandGetCurrentActionPower(eState);

	os << std::endl;
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
