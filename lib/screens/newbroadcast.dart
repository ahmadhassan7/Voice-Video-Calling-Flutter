import 'package:flutter/material.dart';

class NewBroadCast extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => Bimeta()),
              // );
            }),
        title: ListTile(
          title: Text(
            "New broadcast",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: null)
        ],
      ),
    );
  }
}
