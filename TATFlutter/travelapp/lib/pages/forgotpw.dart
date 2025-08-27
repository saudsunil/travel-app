import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';



class Forgotpw extends StatefulWidget{
  const Forgotpw({super.key});

    @override
  State<Forgotpw> createState() => _ForgotpwState();

}

class _ForgotpwState extends State<Forgotpw>{
 
   TextEditingController email=TextEditingController();

   bool isloading=false;

  reset ()async{
       setState((){
        isloading=true;
       });
    try{
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text,);
    }on FirebaseAuthException catch(e){
      Get.snackbar(
      "Error",
      e.code,
      backgroundColor: Colors.white,
      colorText: Colors.red,
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
    );
  } catch (e) {
    Get.snackbar(
      "Error",
      e.toString(),
      backgroundColor: Colors.white,
      colorText: Colors.red,
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
    );
  }
  setState((){
    isloading=false;
  });
  }
   
 
   @override
    Widget build(BuildContext context){
      return isloading?Center(child: CircularProgressIndicator(),):Scaffold(
      appBar:AppBar(title: Text("Forgot Password"),),
      body:Padding(
        padding:const EdgeInsets.all(20.0),
        child:Column(
        children:[
        TextField(
          controller: email,
          decoration: InputDecoration(labelText:'Email'),
 ),
       
        ElevatedButton(
          onPressed: (()=>reset()), child: Text("Receive Link")
        )
      ],
      )
      )
      );
  }
}
  