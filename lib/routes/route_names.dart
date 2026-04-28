class RouteNames {
  static const splash       = '/';
  static const login        = '/login';
  static const signup       = '/signup';
  static const phone        = '/phone';
  static const otp          = '/otp';
  static const home         = '/home';
  static const addUsers     = '/add-users';
  static const chat         = '/chat/:chatId/:receiverId/:name';

  // Uses query parameters: ?callId=&callerId=&callerName=
  // This avoids GoRouter path-matching failures on empty/special name strings
  static const incomingCall = '/incoming-call';

  // /call/:callId/:receiverId/:name
  static const call         = '/call/:callId/:receiverId/:name';
  static const settings     = '/settings';
}