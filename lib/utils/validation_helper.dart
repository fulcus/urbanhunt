
class ValidationHelper {

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    } else {
      var re = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
      if (!re.hasMatch(value)) {
        return 'Invalid email';
      }
      return null;
    }
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'The password is too weak, please insert another one';
    }
    if(_isBlank(value)) {
      return 'Invalid password';
    }
    return null;
  }

  String? validatePlaceName(String? value) {
    if (value == null || value.isEmpty || _isBlank(value)) {
      return 'Name is required';
    }
    /*final nameExp = RegExp(r'^[A-Za-z ]+$');
    if (!nameExp.hasMatch(value)) {
      return 'Please enter only alphabetical characters';
    }*/
    if (value.length < 3) {
      return 'Name is too short, use at least 3 characters';
    }
    if (value.length > 50) {
      return 'Name is too long, use at most 50 characters';
    }
    return null;
  }

  String? validateLockedDescr(String? value) {
    if (value == null || value.isEmpty || _isBlank(value)) {
      return 'Locked description is required';
    }
    if (value.length > 150) {
      return 'Locked description is too long, use at most 150 characters';
    }
    return null;
  }

  String? validateUnlockedDescr(String? value) {
    if (value == null || value.isEmpty || _isBlank(value)) {
      return 'Unlocked description is required';
    }
    if (value.length > 500) {
      return 'Unlocked description is too long, use at most 500 characters';
    }
    return null;
  }

  bool _isBlank(String value) {
    var res = value.replaceAll(' ', '');
    return res.isEmpty ? true : false;
  }

}