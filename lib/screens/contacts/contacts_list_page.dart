import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Chatify/screens/ChatDetail/ChattingPage.dart';
import 'package:Chatify/screens/contacts/invite_friends.dart';
import 'package:url_launcher/url_launcher.dart';




import '../../main.dart';

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact> _contacts;
  bool loading = true;
  DocumentSnapshot userData;
  String currentuserid;
  String currentusername;
  String currentuserphoto;

  getCurrUserId() async {
    setState(() {
      currentuserid = prefs.getString("uid");
      currentusername = prefs.getString("name");
      currentuserphoto = prefs.getString("photo");
    });
  }


  @override
  void initState() {
    super.initState();
    refreshContacts();
    getCurrUserId();

  }

  _launchURL(phoneNumber) async {
    final uri = 'sms:${phoneNumber}?body=Visit\nhttps://bimeta.net';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      // iOS
      const uri = 'sms:?body=Visit\nhttps://bimeta.net';
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    }
  }

  Future<void> refreshContacts() async {
    // Load without thumbnails initially.
    var contacts = (await ContactsService.getContacts(
            withThumbnails: false, iOSLocalizedLabels: iOSLocalizedLabels))
        .toList();
//      var contacts = (await ContactsService.getContactsForPhone("8554964652"))
//          .toList();
    setState(() {
      _contacts = contacts;
    });

    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        setState(() => contact.avatar = avatar);
      });
    }
  }

  void updateContact() async {
    Contact ninja = _contacts
        .toList()
        .firstWhere((contact) => contact.familyName.startsWith("Ninja"));
    ninja.avatar = null;
    await ContactsService.updateContact(ninja);

    refreshContacts();
  }

  _openContactForm() async {
    try {
      var contact = await ContactsService.openContactForm(
          iOSLocalizedLabels: iOSLocalizedLabels);
      refreshContacts();
    } on FormOperationException catch (e) {
      switch (e.errorCode) {
        case FormOperationErrorCode.FORM_OPERATION_CANCELED:
        case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
        case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
        default:
          print(e.errorCode);
      }
    }
  }

  loadData(phoneNo) async {
    final data = await Firestore.instance
        .collection('Users')
        .where('phone', isEqualTo: phoneNo)
        .getDocuments()
        .then((value) {
      setState(() {
        loading = false;

        userData = value.documents[0];

        print(userData.data['uid']);
        print(userData.data['uid']);
      });
    });
  }
  // void _sendSMS(String message, List<String> recipents) async {
  //   String _result = await sendSMS(message: message, recipients: recipents)
  //       .catchError((onError) {
  //     print(onError);
  //   });
  //   print(_result);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contacts',
        ),
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(Icons.create),
          //   onPressed: _openContactForm,
          // )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: () {
      //     Navigator.of(context).pushNamed("/add").then((_) {
      //       refreshContacts();
      //     });
      //   },
      // ),
      body: SafeArea(
        child: _contacts != null
            ? ListView.builder(
                cacheExtent: 1000,
                itemCount: _contacts?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  Contact c = _contacts?.elementAt(index);

                  return Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          onTap: () {
                            // Navigator.of(context).push(MaterialPageRoute(
                            //     builder: (BuildContext context) => ContactDetailsPage(
                            //           c,
                            //           onContactDeviceSave:
                            //               contactOnDeviceHasBeenUpdated,
                            //         )));
                          },
                          leading: (c.avatar != null && c.avatar.length > 0)
                              ? CircleAvatar(backgroundImage: MemoryImage(c.avatar))
                              : CircleAvatar(child: Text(c.initials())),
                          title: Text(
                            c.displayName ?? "" , style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color),
                            // style: TextStyle(
                            //     color: Theme.of(context).textTheme.bodyText2.color),
                          ),
                          // trailing: ,

                          // FlatButton(
                          //
                          //
                          //
                          //   // child: loading
                          //   //     ? Text('loading...', style: TextStyle(color: Theme.of(context).accentColor),)
                          //   // :Text(uid),
                          //   //     : userData.data['uid'] != null ? Text('Message', style: TextStyle(color: Theme.of(context).accentColor),)
                          //   // :Text('Invite', style: TextStyle(color: Theme.of(context).accentColor),),
                          //   onPressed: (){
                          //     print('invitation Sent');
                          //   },
                          // ),
                        ),
                      ),
                      StreamBuilder(
                          stream: Firestore.instance
                              .collection("Users")
                              .where('phone', isEqualTo: c.phones.first.value)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              // final user = snapshot.data.documents;
                              if (snapshot.data.documents.length > 0) {
                                // Text(user[0]['uid'].toString() ?? ' yes');
                                return GestureDetector(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                                        return Chat(
                                          receiverId: snapshot.data.documents[0]["uid"],
                                          receiverAvatar: snapshot.data.documents[0]["photoUrl"],
                                          receiverName: snapshot.data.documents[0]["name"] ?? '',
                                          phone: snapshot.data.documents[0]["phone"],
                                          currUserId: currentuserid,
                                          currUserName: currentusername,
                                          currUserAvatar: currentuserphoto,
                                        );
                                      }));

                                      // ChatUsersList(
                                      //   name: snapshot.data.documents[0]["name"],
                                      //   image: snapshot.data.documents[0]["photoUrl"],
                                      //   time: snapshot.data.documents[0]["createdAt"],
                                      //   email: snapshot.data.documents[0]["email"],
                                      //   phone: snapshot.data.documents[0]["phone"],
                                      //   isMessageRead: true,
                                      //   userId: snapshot.data.documents[0]["uid"],
                                      // );
                                    },
                                    child: Text('Message', style: TextStyle(color: Theme.of(context).accentColor),));
                              } else {
                                return GestureDetector(
                                    onTap: (){

                                      _launchURL(c.phones.first.value);
                                      // Navigator.push(context, MaterialPageRoute(builder: (context) {
                                      //   return Invitefriends();
                                      // }));

                                    },
                                    child: Text('Invite', style: TextStyle(color: Theme.of(context).accentColor),));
                              }
                            } else {
                              return Text('loading', style: TextStyle(color: Theme.of(context).accentColor),);
                            }
                          }),
                      SizedBox(width: 10,),
                    ],
                  );

                  // return StreamBuilder(
                  //   stream: Firestore.instance
                  //       .collection("Users")
                  //       .where('phone', isEqualTo: c.phones.first.value)
                  //       .snapshots(),
                  //   builder: (context, snapshot) {
                  //     print(snapshot.data);
                  //     // print(snapshot.data['uid']);
                  //     // print(snapshot.data['uid']);
                  //
                  //     if (!snapshot.hasData) {
                  //       return Container(
                  //         child: Center(
                  //           child: CircularProgressIndicator(
                  //               valueColor: AlwaysStoppedAnimation(
                  //             Theme.of(context).accentColor,
                  //           )),
                  //         ),
                  //         height: MediaQuery.of(context)
                  //                 .copyWith()
                  //                 .size
                  //                 .height -
                  //             MediaQuery.of(context).copyWith().size.height / 5,
                  //         width: MediaQuery.of(context).copyWith().size.width,
                  //       );
                  //     } else {
                  //       final user = snapshot.data.documents;
                  //       return ListTile(
                  //         onTap: () {
                  //           Navigator.of(context).push(MaterialPageRoute(
                  //               builder: (BuildContext context) =>
                  //                   ContactDetailsPage(
                  //                     c,
                  //                     onContactDeviceSave:
                  //                         contactOnDeviceHasBeenUpdated,
                  //                   )));
                  //         },
                  //         leading: (c.avatar != null && c.avatar.length > 0)
                  //             ? CircleAvatar(
                  //                 backgroundImage: MemoryImage(c.avatar))
                  //             : CircleAvatar(child: Text(c.initials())),
                  //         title: Text(
                  //           c.displayName ?? "",
                  //           style: TextStyle(
                  //               color: Theme.of(context)
                  //                   .textTheme
                  //                   .bodyText2
                  //                   .color),
                  //         ),
                  //         trailing: Text(user[0]?.data['uid'].toString() ?? 'kk'),
                  //         // trailing: FlatButton(
                  //
                  //         // child: snapshot.documernts.data ['phone'] ?? 'a' == c.phones.first.value ? Text('yes'): Text('no'),
                  //
                  //         // child: loading
                  //         //     ? Text('loading...', style: TextStyle(color: Theme.of(context).accentColor),)
                  //         // :Text(uid),
                  //         //     : userData.data['uid'] != null ? Text('Message', style: TextStyle(color: Theme.of(context).accentColor),)
                  //         // :Text('Invite', style: TextStyle(color: Theme.of(context).accentColor),),
                  //         // onPressed: (){
                  //         //   print('invitation Sent');
                  //         // },
                  //         // ),
                  //       );
                  //     }
                  //   },
                  // );
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  void contactOnDeviceHasBeenUpdated(Contact contact) {
    this.setState(() {
      var id = _contacts.indexWhere((c) => c.identifier == contact.identifier);
      _contacts[id] = contact;
    });
  }
}

// class ContactDetailsPage extends StatelessWidget {
//   ContactDetailsPage(this._contact, {this.onContactDeviceSave});
//
//   final Contact _contact;
//   final Function(Contact) onContactDeviceSave;
//
//   _openExistingContactOnDevice(BuildContext context) async {
//     try {
//       var contact = await ContactsService.openExistingContact(_contact,
//           iOSLocalizedLabels: iOSLocalizedLabels);
//       if (onContactDeviceSave != null) {
//         onContactDeviceSave(contact);
//       }
//       Navigator.of(context).pop();
//     } on FormOperationException catch (e) {
//       switch (e.errorCode) {
//         case FormOperationErrorCode.FORM_OPERATION_CANCELED:
//         case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
//         case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
//         default:
//           print(e.toString());
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_contact.displayName ?? ""),
//         actions: <Widget>[
// //          IconButton(
// //            icon: Icon(Icons.share),
// //            onPressed: () => shareVCFCard(context, contact: _contact),
// //          ),
//           IconButton(
//             icon: Icon(Icons.delete),
//             onPressed: () => ContactsService.deleteContact(_contact),
//           ),
//           IconButton(
//             icon: Icon(Icons.update),
//             onPressed: () => Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) => UpdateContactsPage(
//                   contact: _contact,
//                 ),
//               ),
//             ),
//           ),
//           IconButton(
//               icon: Icon(Icons.edit),
//               onPressed: () => _openExistingContactOnDevice(context)),
//         ],
//       ),
//       body: SafeArea(
//         child: ListView(
//           children: <Widget>[
//             ListTile(
//               title: Text("Name"),
//               trailing: Text(_contact.givenName ?? ""),
//             ),
//             ListTile(
//               title: Text("Middle name"),
//               trailing: Text(_contact.middleName ?? ""),
//             ),
//             ListTile(
//               title: Text("Family name"),
//               trailing: Text(_contact.familyName ?? ""),
//             ),
//             ListTile(
//               title: Text("Prefix"),
//               trailing: Text(_contact.prefix ?? ""),
//             ),
//             ListTile(
//               title: Text("Suffix"),
//               trailing: Text(_contact.suffix ?? ""),
//             ),
//             ListTile(
//               title: Text("Birthday"),
//               trailing: Text(_contact.birthday != null
//                   ? DateFormat('dd-MM-yyyy').format(_contact.birthday)
//                   : ""),
//             ),
//             ListTile(
//               title: Text("Company"),
//               trailing: Text(_contact.company ?? ""),
//             ),
//             ListTile(
//               title: Text("Job"),
//               trailing: Text(_contact.jobTitle ?? ""),
//             ),
//             ListTile(
//               title: Text("Account Type"),
//               trailing: Text((_contact.androidAccountType != null)
//                   ? _contact.androidAccountType.toString()
//                   : ""),
//             ),
//             AddressesTile(_contact.postalAddresses),
//             ItemsTile("Phones", _contact.phones),
//             ItemsTile("Emails", _contact.emails)
//           ],
//         ),
//       ),
//     );
//   }
// }

class AddressesTile extends StatelessWidget {
  AddressesTile(this._addresses);

  final Iterable<PostalAddress> _addresses;

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(title: Text("Addresses")),
        Column(
          children: _addresses
              .map((a) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text("Street"),
                          trailing: Text(a.street ?? ""),
                        ),
                        ListTile(
                          title: Text("Postcode"),
                          trailing: Text(a.postcode ?? ""),
                        ),
                        ListTile(
                          title: Text("City"),
                          trailing: Text(a.city ?? ""),
                        ),
                        ListTile(
                          title: Text("Region"),
                          trailing: Text(a.region ?? ""),
                        ),
                        ListTile(
                          title: Text("Country"),
                          trailing: Text(a.country ?? ""),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class ItemsTile extends StatelessWidget {
  ItemsTile(this._title, this._items);

  final Iterable<Item> _items;
  final String _title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(title: Text(_title)),
        Column(
          children: _items
              .map(
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListTile(
                    title: Text(i.label ?? ""),
                    trailing: Text(i.value ?? ""),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class AddContactPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  Contact contact = Contact();
  PostalAddress address = PostalAddress(label: "Home");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add a contact"),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              _formKey.currentState.save();
              contact.postalAddresses = [address];
              ContactsService.addContact(contact);
              Navigator.of(context).pop();
            },
            child: Icon(Icons.save, color: Colors.white),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'First name'),
                onSaved: (v) => contact.givenName = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Middle name'),
                onSaved: (v) => contact.middleName = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Last name'),
                onSaved: (v) => contact.familyName = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Prefix'),
                onSaved: (v) => contact.prefix = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Suffix'),
                onSaved: (v) => contact.suffix = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone'),
                onSaved: (v) =>
                    contact.phones = [Item(label: "mobile", value: v)],
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                onSaved: (v) =>
                    contact.emails = [Item(label: "work", value: v)],
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Company'),
                onSaved: (v) => contact.company = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Job'),
                onSaved: (v) => contact.jobTitle = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Street'),
                onSaved: (v) => address.street = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'City'),
                onSaved: (v) => address.city = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Region'),
                onSaved: (v) => address.region = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Postal code'),
                onSaved: (v) => address.postcode = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Country'),
                onSaved: (v) => address.country = v,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateContactsPage extends StatefulWidget {
  UpdateContactsPage({@required this.contact});

  final Contact contact;

  @override
  _UpdateContactsPageState createState() => _UpdateContactsPageState();
}

class _UpdateContactsPageState extends State<UpdateContactsPage> {
  Contact contact;
  PostalAddress address = PostalAddress(label: "Home");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    contact = widget.contact;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Contact"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.white,
            ),
            onPressed: () async {
              _formKey.currentState.save();
              contact.postalAddresses = [address];
              await ContactsService.updateContact(contact);
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => ContactListPage()));
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: contact.givenName ?? "",
                decoration: const InputDecoration(labelText: 'First name'),
                onSaved: (v) => contact.givenName = v,
              ),
              TextFormField(
                initialValue: contact.middleName ?? "",
                decoration: const InputDecoration(labelText: 'Middle name'),
                onSaved: (v) => contact.middleName = v,
              ),
              TextFormField(
                initialValue: contact.familyName ?? "",
                decoration: const InputDecoration(labelText: 'Last name'),
                onSaved: (v) => contact.familyName = v,
              ),
              TextFormField(
                initialValue: contact.prefix ?? "",
                decoration: const InputDecoration(labelText: 'Prefix'),
                onSaved: (v) => contact.prefix = v,
              ),
              TextFormField(
                initialValue: contact.suffix ?? "",
                decoration: const InputDecoration(labelText: 'Suffix'),
                onSaved: (v) => contact.suffix = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone'),
                onSaved: (v) =>
                    contact.phones = [Item(label: "mobile", value: v)],
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                onSaved: (v) =>
                    contact.emails = [Item(label: "work", value: v)],
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                initialValue: contact.company ?? "",
                decoration: const InputDecoration(labelText: 'Company'),
                onSaved: (v) => contact.company = v,
              ),
              TextFormField(
                initialValue: contact.jobTitle ?? "",
                decoration: const InputDecoration(labelText: 'Job'),
                onSaved: (v) => contact.jobTitle = v,
              ),
              TextFormField(
                initialValue: address.street ?? "",
                decoration: const InputDecoration(labelText: 'Street'),
                onSaved: (v) => address.street = v,
              ),
              TextFormField(
                initialValue: address.city ?? "",
                decoration: const InputDecoration(labelText: 'City'),
                onSaved: (v) => address.city = v,
              ),
              TextFormField(
                initialValue: address.region ?? "",
                decoration: const InputDecoration(labelText: 'Region'),
                onSaved: (v) => address.region = v,
              ),
              TextFormField(
                initialValue: address.postcode ?? "",
                decoration: const InputDecoration(labelText: 'Postal code'),
                onSaved: (v) => address.postcode = v,
              ),
              TextFormField(
                initialValue: address.country ?? "",
                decoration: const InputDecoration(labelText: 'Country'),
                onSaved: (v) => address.country = v,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
