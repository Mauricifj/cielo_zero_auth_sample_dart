import 'package:cielo_zero_auth/cielo_zero_auth.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Zero Auth Sample';

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: ZeroAuthForm(),
      ),
    );
  }
}

class ZeroAuthForm extends StatefulWidget {
  @override
  ZeroAuthFormState createState() {
    return ZeroAuthFormState();
  }
}

class ZeroAuthFormState extends State<ZeroAuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _controllerHolder = TextEditingController();
  final _controllerCardNumber = TextEditingController();
  final _controllerExpirationMonth = TextEditingController();
  final _controllerExpirationYear = TextEditingController();
  final _controllerSecurityCode = TextEditingController();
  String _brand = 'Master';
  String _paymentMethod = 'Credit';
  bool _saveCard = false;
  bool _sending = false;

  final CieloZeroAuth _zeroAuth = CieloZeroAuth(
    merchantId: "YOUR-MERCHANT-ID",
    clientId: "YOUR-CLIENT-ID",
    clientSecret: "YOUR-CLIENT-SECRET",
    environment: Environment.SANDBOX,
  );

  @override
  void dispose() {
    _controllerHolder.dispose();
    _controllerCardNumber.dispose();
    _controllerExpirationMonth.dispose();
    _controllerExpirationYear.dispose();
    _controllerSecurityCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Visibility(
              child: Loading(),
              visible: _sending,
            ),
            Visibility(
              visible: !_sending,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _controllerHolder,
                      readOnly: _sending,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: 'Holder name',
                        suffixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Name can\'t be null';
                        }
                        if (value.length > 22) {
                          return 'Dom Pedro II, is that you?';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButton(
                      isExpanded: true,
                      value: _paymentMethod,
                      onChanged: (String newValue) {
                        setState(() {
                          _paymentMethod = newValue;
                        });
                      },
                      items: <String>['Credit', 'Debit']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _controllerCardNumber,
                      maxLength: 16,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Card Number',
                        suffixIcon: Icon(Icons.credit_card),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Card number can\'t be null';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _controllerExpirationMonth,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Expiration month',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Expiration month can\'t be null';
                        }
                        int month = int.parse(value);
                        if (month < 0 || month > 12) {
                          return 'Are you sure $value is a month?';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _controllerExpirationYear,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Expiration year',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Expiration year can\'t be null';
                        }
                        int year = int.parse(value);
                        if (year < DateTime.now().year) {
                          return 'Are you Marty McFly?';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _controllerSecurityCode,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Security code',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Security code can\'t be null';
                        }
                        if (value.length > 4) {
                          return 'Security code too big, is it correct?';
                        }
                        return null;
                      },
                    ),
                  ),
//            Not available yet
//            CheckboxListTile(
//              title: Text('Save card'),
//              subtitle: Text('Generates a card token that can be used later'),
//              value: _saveCard,
//              onChanged: (bool value) {
//                setState(() {
//                  _saveCard = value;
//                });
//              },
//            ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButton(
                      isExpanded: true,
                      value: _brand,
                      onChanged: (String newValue) {
                        setState(() {
                          _brand = newValue;
                        });
                      },
                      items: <String>['Master', 'Visa']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.maxFinite,
                      child: RaisedButton(
                        textColor: Colors.white,
                        color: Colors.blue,
                        elevation: 8,
                        child: Text('VALIDATE'),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            if (!_sending) {
                              String holder = _controllerHolder.text;
                              String cardNumber = _controllerCardNumber.text;
                              CardType cardType =
                                  (_paymentMethod.toString() == 'Credit')
                                      ? CardType.CreditCard
                                      : CardType.DebitCard;
                              String expirationDate =
                                  "${_controllerExpirationMonth.text}/${_controllerExpirationYear.text}";
                              String securityCode =
                                  _controllerSecurityCode.text;

                              ZeroAuthRequest request = ZeroAuthRequest(
                                holder: holder,
                                cardType: cardType,
                                cardNumber: cardNumber,
                                expirationDate: expirationDate,
                                securityCode: securityCode,
                                saveCard: _saveCard,
                                brand: _brand,
                                cardOnFile: CardOnFile(
                                  usage: Usage.First,
                                  reason: Reason.Unscheduled,
                                ),
                              );

                              _formKey.currentState.reset();
                              validate(request);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void validate(ZeroAuthRequest request) async {
    setState(() {
      _sending = true;
    });

    ZeroAuthResult result = await _zeroAuth.validate(request);

    setState(() {
      _sending = false;
    });

    print("Valid: ${result?.zeroAuthResponse?.valid}");
    print("Return Code: ${result?.zeroAuthResponse?.returnCode}");
    print("Return Message: ${result?.zeroAuthResponse?.returnMessage}");
    print(
        "Issuer Transaction Id: ${result?.zeroAuthResponse?.issuerTransactionId}");

    result?.zeroAuthErrorResponse?.forEach((error) {
      print("Error:");
      print("    Error Code: ${error?.code}");
      print("    Error Message: ${error?.message}");
    });

    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ResultScreen(result: result)));
  }
}

class Loading extends StatelessWidget {
  final String message;

  Loading({this.message = "Loading..."});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.vertical,
      width: MediaQuery.of(context).size.width -
          MediaQuery.of(context).padding.horizontal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(message, style: TextStyle(fontSize: 16.0)),
          ),
        ],
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final ZeroAuthResult result;

  ResultScreen({this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Result")), body: _showResult(result));
  }

  Widget _showResult(ZeroAuthResult result) {
    if (result.zeroAuthResponse != null) {
      return Column(children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "VALID: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(result?.zeroAuthResponse?.valid),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "RETURN CODE: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(result?.zeroAuthResponse?.returnCode),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "RETURN MESSAGE: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(result?.zeroAuthResponse?.returnMessage),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "ISSUER TRANSACITON ID: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(result?.zeroAuthResponse?.issuerTransactionId),
              ],
            ),
          ),
        ),
      ]);
    }

    if (result.zeroAuthErrorResponse != null &&
        result.zeroAuthErrorResponse.length > 0) {
      return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: (result?.zeroAuthErrorResponse?.length != null)
            ? result.zeroAuthErrorResponse.length
            : 0,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          "ERROR CODE: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(result.zeroAuthErrorResponse[index].code),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ERROR MESSAGE: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(result.zeroAuthErrorResponse[index].message),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Text("Unknown error", style: TextStyle(fontSize: 24)))
        ],
      ),
    );
  }
}
