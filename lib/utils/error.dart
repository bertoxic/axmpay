class Errors {
  String? name;
  List<Error> errorList=[];
  Errors(this.name);
  void add(Error err){
    errorList.add(err);
  }
}

class Error{
  String? name;
  String? msg;
  Error({this.name, this.msg});
}
