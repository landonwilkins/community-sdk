/****************************************************************************
**
** Copyright 2015 by Emotiv. All rights reserved
** Example - Multi Dongle Connection
** this example demonstrates how to connect to two headsets at the same time
** It captures event when you plug or unplug dongle .
** Every time you plug or unplug dongle, there is a notice that dongle ID
** is added or removed
****************************************************************************/

#include <iostream>
#include <list>

#include "Iedk.h"
#include "IedkErrorCode.h"
#include "IEmoStateDLL.h"

using namespace std;

#ifdef _WIN32
#include <conio.h>
#endif

#ifdef __linux__
int _kbhit(void);
#endif

int main(int argc,char** argv[])
{
	EmoEngineEventHandle hEvent = IEE_EmoEngineEventCreate();
	EmoStateHandle eState = IEE_EmoStateCreate();
	unsigned int userID = -1;
	list<int> listUser;

	if( IEE_EngineConnect() == EDK_OK )
	{
		while(!_kbhit()) 
		{
			int state = IEE_EngineGetNextEvent(hEvent);
			if( state == EDK_OK )
			{
				IEE_Event_t eventType = IEE_EmoEngineEventGetType(hEvent);				
				IEE_EmoEngineEventGetUserId(hEvent, &userID);
				if(userID==-1)
					continue;			

				if(eventType == IEE_EmoStateUpdated  )
				{								
                    // Copies an EmoState returned with a IEE_EmoStateUpdate event
                    // to memory referenced by an EmoStateHandle.
					if(IEE_EmoEngineEventGetEmoState(hEvent,eState)==EDK_OK)
					{
						if(IEE_GetUserProfile(userID,hEvent)==EDK_OK)
						{
							//PerformanceMetrice score, short term excitement						
							cout <<"userID: " << userID  <<endl;
                            cout <<"    Performance Metrics excitement score: "
                                 << IS_PerformanceMetricGetInstantaneousExcitementScore(eState)
                                 << endl;
                            cout <<"    Facial Expression smile extent : "
                                 << IS_FacialExpressionGetSmileExtent(eState)
                                 <<endl;
						}						
					}										
				}
				// userremoved event
				else if( eventType == IEE_UserRemoved )
				{
					cout <<"user ID: "<<userID<<" have removed" << endl;	
					listUser.remove(userID);
				}
				// useradded event 
				else if(eventType == IEE_UserAdded)
				{
					listUser.push_back(userID);
					cout <<"user ID: "<<userID<<" have added" << endl;
				}		
				userID=-1;
			}			
		}
	}

	IEE_EngineDisconnect();
	IEE_EmoStateFree(eState);
	IEE_EmoEngineEventFree(hEvent);	

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
