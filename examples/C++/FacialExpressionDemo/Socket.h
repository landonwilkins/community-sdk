#include <string>
#include <vector>
#include <cstdio>
#ifdef _WIN32
    #include <WinSock2.h>
#endif
#ifdef __linux__
    #include <sys/socket.h>
    #include <sys/types.h>
#endif

#ifndef SOCKET_H
#define SOCKET_H

#ifdef __linux__
    typedef uint SOCKET;
#endif

typedef unsigned char byte;
enum TypeSocket		{BlockingSocket, NonBlockingSocket};
enum SocketStream	{TCP, UDP};

using namespace std;


class SocketException : public exception {
private:
	string _what;

public:
	SocketException(const string& what_arg): _what(what_arg) { }
	
	virtual const char* what () const throw() {
		static string err_string;
		err_string = "SocketException -> " + _what;
		return (err_string.c_str());
	}
	
	virtual ~SocketException() throw() {
	}
};



class Socket {
public:

	virtual ~Socket();
	Socket(const Socket&);
	Socket& operator=(Socket&);

	string ReceiveLine(char delim = '\n');
	string ReceiveBytes();
	void   ReceiveBytes(string& byteStream);

	void   Close();
	void   SendLine (const string&, char delim = '\n');
	void   SendBytes(const string&);

protected:

	friend class SocketServer;
	friend class SocketSelect;

	Socket(SOCKET s);
	Socket(SocketStream stream=TCP);


	SOCKET s_;

	int* refCounter_;

	private:
	static void Start();
	static void End();
	static int  nofSockets_;
};


class SocketClient : public Socket {
public:
	SocketClient(const string& host, int port, SocketStream stream=TCP);
};


class SocketServer : public Socket {
public:
    SocketServer(int port, int connections, SocketStream stream=TCP,
                 TypeSocket type=BlockingSocket);

	Socket* Accept();
};


class SocketSelect {
public:
    SocketSelect(Socket const * const s1, Socket const * const s2=NULL,
                 TypeSocket type=BlockingSocket);

	bool Readable(Socket const * const s);

private:
	fd_set fds_;
}; 

#endif
