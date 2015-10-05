#include <iostream>
#include <sstream>
#include <vector>
#include <string>

#ifdef __linux__
    #include <unistd.h>
    #include <errno.h>
    #include <netdb.h>
    #include <memory.h>
    #include <sys/ioctl.h>
#endif

#include "Socket.h"

using namespace std;

int Socket::nofSockets_= 0;

#define BUF_SIZE 4096
#ifdef __linux__
    #define INVALID_SOCKET -1
    #define SOCKET_ERROR -1
    #define BUF_SIZE 4096
    #define WSAEWOULDBLOCK 10035
#endif

void Socket::Start() {
	if (!nofSockets_) {
#ifdef _WIN32
		WSADATA info;
		if (WSAStartup(MAKEWORD(2,0), &info)) {
			throw SocketException("Could not start WSA");
		}
#endif
	}
	++nofSockets_;
}


void Socket::End() {
#ifdef _WIN32
	WSACleanup();
#endif
}


Socket::Socket(SocketStream stream) : s_(0) {
	
	Start();

	// UDP: use SOCK_DGRAM instead of SOCK_STREAM
	if (stream == TCP)
		s_ = socket(AF_INET,SOCK_STREAM,0);
	else if (stream == UDP)
		s_ = socket(AF_INET, SOCK_DGRAM, 0);
	else {
		ostringstream oss;
		oss << "unknown socket stream type [" << stream << "]";
		throw SocketException(oss.str());
	}

	if (s_ == INVALID_SOCKET) {
		throw SocketException("INVALID_SOCKET");
	}

	refCounter_ = new int(1);
}


Socket::Socket(SOCKET s) : s_(s) {
	Start();
	refCounter_ = new int(1);
};


Socket::~Socket() {
	if (! --(*refCounter_)) {
		Close();
		delete refCounter_, refCounter_ = 0;
	}

	--nofSockets_;
	if (!nofSockets_)
		End();
}


Socket::Socket(const Socket& o) {
	refCounter_=o.refCounter_;
	(*refCounter_)++;
	s_         =o.s_;

	nofSockets_++;
}


Socket& Socket::operator=(Socket& o) {
	(*o.refCounter_)++;

	refCounter_=o.refCounter_;
	s_         =o.s_;

	nofSockets_++;

	return *this;
}


void Socket::Close() {
#ifdef _WIN32
	closesocket(s_);
#endif
#ifdef __linux__
    close(s_);
#endif
}


string Socket::ReceiveBytes() {
	string ret;
	this->ReceiveBytes(ret);
	return ret;
}



void Socket::ReceiveBytes(string& byteStream) {

	char   buf[BUF_SIZE];
	u_long total = 0;

	while (1) {
		u_long arg = 0;
#ifdef _WIN32
		if (ioctlsocket(s_, FIONREAD, &arg) != 0)
#endif
#ifdef __linux__
            if (ioctl(s_, FIONREAD, &arg) != 0)
#endif
                throw SocketException("error in ReceiveBytes()");

		if (arg == 0 && total > 0)
			break;

		if (arg == 0) {
#ifdef _WIN32
			Sleep(1);
#endif
#ifdef __linux__
            sleep(0.1);
#endif
			// check whether the connection still alive or not
			int alive = recv(s_, buf, 1, 0);
			if (alive < 0)
				throw SocketException("error in ReceiveBytes()");

			if (alive > 0)
				byteStream.push_back(buf[0]);
			continue;
		}

		if (arg > BUF_SIZE) arg = BUF_SIZE;

		int rv = recv(s_, buf, arg, 0);
		if (rv <= 0)
			throw SocketException("error in ReceiveBytes()");

		total += rv;

		string t;

		t.assign(buf, rv);
		byteStream += t;
	}

}



string Socket::ReceiveLine(char delim) {
	string ret;
	while (1) {
		char r;

		switch (recv(s_, &r, 1, 0)) {
        case 0: // not connected anymore;
            return "";
        case -1:
            if (errno == WSAEWOULDBLOCK  ) {
                return ret;
            } else {
                // not connected anymore
                return "";
            }
		}

		if (r == delim)
			return ret;

		ret += r;
	}
}


void Socket::SendLine(const string& s, char delim) {
	string outgoing(s);
	outgoing.push_back(delim);
	SendBytes(outgoing);
}


void Socket::SendBytes(const string& s) {

	u_long totalSent = 0;

	if (s.length()) {

		while (totalSent != s.length()) {
			int sent = 0;
			sent = send(s_, (s.c_str())+totalSent, (int)s.length()-totalSent, 0);
			if (sent <= 0)
				throw SocketException("error in SendBytes()");

			totalSent += sent;
		}
	}
}


SocketServer::SocketServer(int port, int connections, SocketStream stream,
                           TypeSocket type) {
	sockaddr_in sa;

	memset(&sa, 0, sizeof(sa));

	sa.sin_family = PF_INET;           
	sa.sin_port   = htons(port);

  	if (stream == TCP)
		s_ = socket(AF_INET,SOCK_STREAM,0);
	else if (stream == UDP)
		s_ = socket(AF_INET, SOCK_DGRAM, 0);
	else {
		ostringstream oss;
		oss << "unknown socket stream type [" << stream << "]";
		throw SocketException(oss.str());
	}

	if (s_ == INVALID_SOCKET) {
		throw SocketException("INVALID_SOCKET");
	}

	if (type == NonBlockingSocket) {
		u_long arg = 1;
#ifdef _WIN32
		ioctlsocket(s_, FIONBIO, &arg);
#endif
#ifdef __linux__
        ioctl(s_, FIONBIO, &arg);
#endif
	}

	/* bind the socket to the internet address */
	if (bind(s_, (sockaddr *)&sa, sizeof(sockaddr_in)) == SOCKET_ERROR) {
#ifdef _WIN32
        closesocket(s_);
#endif
#ifdef __linux__
        close(s_);
#endif

		throw SocketException("INVALID_SOCKET");
	}

	listen(s_, connections);                               
}


Socket* SocketServer::Accept() {

	SOCKET new_sock = accept(s_, 0, 0);

	if (new_sock == INVALID_SOCKET) {
#ifdef _WIN32
		int rc = WSAGetLastError();
		if (rc == WSAEWOULDBLOCK) {
			return 0; // non-blocking call, no request pending
		}
		else {
			throw SocketException("INVALID_SOCKET");
		}
#endif
#ifdef __linux__
        throw SocketException("INVALID_SOCKET");
#endif
	}

	Socket* r = new Socket(new_sock);
	return r;
}


SocketClient::SocketClient(const string& host, int port, SocketStream stream) :
    Socket(stream) {
	
	ostringstream error;

	hostent *he;
	if ((he = gethostbyname(host.c_str())) == 0) {
		error << "unknown host [" << host << "].";
		throw SocketException(error.str());
	}

	sockaddr_in addr;
	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	addr.sin_addr = *((in_addr *)he->h_addr);
	memset(&(addr.sin_zero), 0, 8); 

	if (::connect(s_, (sockaddr *) &addr, sizeof(sockaddr))) {
        error << "cannot connection to host [" << host << "] on port "
              << port << ".";
		throw SocketException(error.str());
	}
}


SocketSelect::SocketSelect(Socket const * const s1, Socket const * const s2,
                           TypeSocket type) {
	FD_ZERO(&fds_);
	FD_SET(const_cast<Socket*>(s1)->s_,&fds_);

	if (s2) {
		FD_SET(const_cast<Socket*>(s2)->s_,&fds_);
	}     
#ifdef _WIN32
	TIMEVAL tval;
    TIMEVAL *ptval;
#endif
#ifdef __linux__
    timeval tval;
    timeval *ptval;
#endif
	tval.tv_sec  = 0;
	tval.tv_usec = 1;


	if (type==NonBlockingSocket) {
		ptval = &tval;
	}
	else { 
		ptval = 0;
	}

	if (select (0, &fds_, (fd_set*) 0, (fd_set*) 0, ptval) == SOCKET_ERROR)
		throw SocketException("Error in SocketSelect()");
}


bool SocketSelect::Readable(Socket const* const s) {
	if (FD_ISSET(s->s_,&fds_)) {
		return true;
	}
	return false;
}

