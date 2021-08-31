import 'package:flutter/cupertino.dart';
import 'package:flutter_complete_guide/models/http_exceptions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  //provider in main.dart
  String _token; //expires at some point of time (eg. 1 hour)
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    if (tokenData != null) {
      return true;
    }
    return false;
  }

  String get tokenData {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null)
    //_expiryDate.isAfter(DateTime.now())->means expiry date sometime in the future
    {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlAuth) async {
    try {
      final url = Uri.parse(urlAuth);
      //API_KEY ->settings of firebase-> web api key
      //https://firebase.google.com/docs/reference/rest/auth/#section-create-email-password =>visit this
      final response = await http.post(url,
          body: json.encode({
            //email,pass,returnToken needed
            'email': email,
            'password': password,
            'returnSecureToken': true, //in the docs
          }));
      // print(json.decode(response.body));
      //returns a map of
      //Property Name	Type	Description
// idToken	   string	  A Firebase Auth ID token for the newly created user.
// email	     string	  The email for the newly created user.
// refreshToken	string	A Firebase Auth refresh token for the newly created user.
// expiresIn	  string	The number of seconds in which the ID token expires.
// localId	    string	The uid of the newly created user.

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        //sample error returned from firebase
        //{error: {code: 400, message: EMAIL_EXISTS, errors: [{message: EMAIL_EXISTS, domain: global, reason: invalid}]}}
        throw HttpExceptions(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      autoLogout();

      notifyListeners();
      print('sign in / login success');

      //shared pref here
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });
      prefs.setString('userData',
          userData); //Saves a string [value] to persistent storage in the background
      

    } catch (error) {
      print('error in sign up method');
      throw error;
    }
  }
//to retrieve the data set on the in device storage by shared prefs 
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')) {
      return false ;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String,Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if(expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token =extractedUserData['token'];
    _userId=extractedUserData['userId'];
    _expiryDate=expiryDate;
    notifyListeners();
    autoLogout();
    return true;
  } 


  Future<void> signup(String email, String password) async {
    //     https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=[API_KEY]
    return _authenticate(email, password,
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCskLDea1LV3lGR20monGKGz7gUGWlkuT8');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password,
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCskLDea1LV3lGR20monGKGz7gUGWlkuT8');
  }

  Future<void> logout() async{
    _token = null;
    _userId = null;
    _expiryDate = null;
    //whenever all these properties are set to null the bool
    //isAuth builds again and we go back to the login page
    if (_authTimer != null) {
      _authTimer
          .cancel(); //if we logout before the timer ends when we press the logout button
          _authTimer=null;
    }

    notifyListeners();
    final prefs =await SharedPreferences.getInstance();
    prefs.clear();
  }

  void autoLogout() {
    if (_authTimer != null) {
      //cancel the pre esisting timer before setting the new timer
      _authTimer.cancel();
    }
    final timeToExpire = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire), () {
      //when the timer is done
      logout();
    }); //A count-down timer that can be configured to fire once or repeatedly.
  }

  //for the auto login we need to save info on the app
}
