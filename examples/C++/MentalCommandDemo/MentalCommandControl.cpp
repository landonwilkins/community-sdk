#include <map>
#include <cassert>
#include "Iedk.h"
#include "IedkErrorCode.h"
#include "MentalCommandControl.h"

class _MentalCommand_ {
	std::map<IEE_MentalCommandAction_t, std::string> _actionMap;
public:
	_MentalCommand_() {
		_actionMap[MC_NEUTRAL					] = "neutral";
		_actionMap[MC_PUSH						] = "push";
		_actionMap[MC_PULL						] = "pull";
		_actionMap[MC_LIFT						] = "lift";
		_actionMap[MC_DROP						] = "drop"; 
		_actionMap[MC_LEFT						] = "left";
		_actionMap[MC_RIGHT					    ] = "right";
		_actionMap[MC_ROTATE_LEFT				] = "rotate_left";
		_actionMap[MC_ROTATE_RIGHT				] = "rotate_right";
		_actionMap[MC_ROTATE_CLOCKWISE			] = "rotate_clockwise";
		_actionMap[MC_ROTATE_COUNTER_CLOCKWISE  ] = "rotate_counter_clockwise";
		_actionMap[MC_ROTATE_FORWARDS			] = "rotate_forwards";
		_actionMap[MC_ROTATE_REVERSE			] = "rotate_reverse";
		_actionMap[MC_DISAPPEAR				    ] = "disappear";
	}
	const std::map<IEE_MentalCommandAction_t, std::string>& getMap() const {
		return _actionMap;
	}
};

static const _MentalCommand_ _cog_;


void split(const std::string& input, std::vector<std::string>& tokens) {

	tokens.clear();
	std::stringstream ss(input);
	std::string oneToken;
	
	while (ss >> oneToken) {
		try {
			tokens.push_back(oneToken);
		}
		catch (const std::exception&) {}
	}
}

template <typename T>
bool inRange(const T& value, const T& minValue, const T& maxValue) {
	return (value >= minValue && value <= maxValue);
}

template <typename T>
bool convert(const std::string& str, T& value) {
	std::istringstream iss(str);
	return (iss >> value) ? true : false;
}

bool stringToAction(const std::string& actionStr, IEE_MentalCommandAction_t* action) {
	assert(action);
	std::map<IEE_MentalCommandAction_t, std::string>::const_iterator it;
	for (it = _cog_.getMap().begin(); it != _cog_.getMap().end(); it++) {
		if (it->second == actionStr) {
			*action = it->first;
			return true;
		}
	}
	return false;
}

std::string actionToString(IEE_MentalCommandAction_t actionType)
{
    const std::map<IEE_MentalCommandAction_t, std::string>& actionMap =
                                                                _cog_.getMap();
    std::map<IEE_MentalCommandAction_t, std::string>::const_iterator it =
                                                    actionMap.find(actionType);
    if ( it != actionMap.end() ) return it->second;
    else return "<unknown action>";
}

bool parseCommand(const std::string& input, std::ostream& output) {

	bool result = true;
	std::ostringstream os;

	if (input.length()) {

		bool wrongArgument = true;
		std::vector<std::string> commands;
		split(input, commands);

		os << "==> ";

		// Quit command
		if (commands.at(0) == "exit") {
			os << "Bye!";
			result = false;
			wrongArgument = false;
		}

		// Print available commands
		else if (commands.at(0) == "help") {

            const std::string activeActionList = "\"push\",\"pull\",\"lift\""
                    ",\"drop\",\"left\",\"right\",\"rotate_left\",\""
                    "rotate_right\",\"rotate_clockwise\",\""
                    "rotate_counter_clockwise\",\"rotate_forwards\",\""
                    "rotate_reverse\",\"disappear\"";
			
			os << "Available commands:" << std::endl;
			
			os << "set_actions [userID] [action list]" << std::endl;
			os << "\t\t\t\t\t set the MentalCommand active actions" << std::endl;
            os << "\t\t\t\t\t [action list: " << activeActionList  << "]"
               << std::endl;

            os << "training_action [userID] [action] \t set MentalCommand"
                  " training action"
               << std::endl;
            os << "\t\t\t\t\t [action: \"neutral\"," << activeActionList  << "]"
               << std::endl;
			
            os << "training_start [userID] \t\t start MentalCommand training"
               << std::endl;
            os << "training_accept [userID] \t\t accept previous"
                  " MentalCommand training"
               << std::endl;
            os << "training_reject [userID] \t\t reject previous"
                  " MentalCommand training";
            os << "training_erase [userID] \t\t erase MentalCommand training "
                  "data for the current action"
               << std::endl;
			os << "exit \t\t\t\t\t exit this program";

			wrongArgument = false;
		}

		// Set MentalCommand Active actions
		else if (commands.at(0) == "set_actions") {

            //@@ set_actions userID a1 a2 a3 a4
            if (commands.size() <= 6) {
				
				unsigned int  userID;
				unsigned long activeActions = 0;
				IEE_MentalCommandAction_t actionType;
				bool actionCheckOK = true;

				if (convert(commands.at(1), userID)) {

					for (size_t i=2; i < commands.size(); i++) {

						const std::string& actionStr = commands.at(i);
						
						if (stringToAction(actionStr, &actionType)) {
							activeActions |= actionType;
						}
						else {
                            os << "Action [" << actionStr
                               << "] cannot be set to active.";
							actionCheckOK = false;
							break;
						}
					}

					if (actionCheckOK) {
                        os << "Setting MentalCommand active actions for user "
                           << userID << "...";
						
                        wrongArgument = (
                                    IEE_MentalCommandSetActiveActions(
                                        userID, activeActions) != EDK_OK);
					}
				}
			}
		}

		// Change MentalCommand training action
		else if (commands.at(0) == "training_action") {

			if (commands.size() == 3) {
				unsigned int userID;
				IEE_MentalCommandAction_t actionType;

				if (convert(commands.at(1), userID)) {
					const std::string& actionStr = commands.at(2);

					if (stringToAction(actionStr, &actionType)) {
                        os << "Setting MentalCommand training action for user "
                           << userID;
						os << " to " << actionStr << "...";
						
                        wrongArgument = (
                                    IEE_MentalCommandSetTrainingAction(
                                        userID, actionType) != EDK_OK);
					}
					else {
                        os << "Action [" << actionStr
                           << "] cannot be trained.";
					}
				}
			}
		}

		// Start MentalCommand training
		else if (commands.at(0) == "training_start") {

			if (commands.size() == 2) {
				unsigned int userID;
				if (convert(commands.at(1), userID)) {

                    os << "Start MentalCommand training for user "
                       << userID << "...";
					
                    wrongArgument = (
                                IEE_MentalCommandSetTrainingControl(
                                    userID, MC_START) != EDK_OK);
				}
			}
		}

		// Accept MentalCommand training
		else if (commands.at(0) == "training_accept") {

			if (commands.size() == 2) {
				unsigned int userID;
				if (convert(commands.at(1), userID)) {

                    os << "Accepting MentalCommand training for user "
                       << userID << "...";
					
                    wrongArgument = (
                                IEE_MentalCommandSetTrainingControl(
                                    userID, MC_ACCEPT) != EDK_OK);
				}
			}
		}

		// Reject MentalCommand training
		else if (commands.at(0) == "training_reject") {

			if (commands.size() == 2) {
				unsigned int userID;
				if (convert(commands.at(1), userID)) {

                    os << "Rejecting MentalCommand training for user "
                       << userID << "...";
					
                    wrongArgument = (
                                IEE_MentalCommandSetTrainingControl(
                                    userID, MC_REJECT) != EDK_OK);
				}
			}
		}

		// Erase MentalCommand training data
		else if (commands.at(0) == "training_erase") {

			if (commands.size() == 2) {
				unsigned int userID;
				if (convert(commands.at(1), userID)) {
                    IEE_MentalCommandAction_t actionType;
                    if (IEE_MentalCommandGetTrainingAction(userID,
                                                           &actionType) == EDK_OK) {
                        os << "Erasing MentalCommand training for action \""
                           << actionToString(actionType) << "\" for user "
                           << userID << "...";
                        
                        wrongArgument = (
                                    IEE_MentalCommandSetTrainingControl(
                                        userID, MC_ERASE) != EDK_OK);
                    }
				}
			}
		}
		
		// Unknown command
		else {
            os << "Unknown command [" << commands.at(0)
               << "]. Type \"help\" to list available commands.";
			wrongArgument = false;
		}

		if (wrongArgument) {
			os << "Wrong argument(s) for command [" << commands.at(0) << "]";
		}
	}

	const std::string& outString = os.str();
	if (outString.length()) {
		output << outString << std::endl << std::endl;
	}

	return result;
}
