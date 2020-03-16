import 'package:flutter/material.dart';

class MenuBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Row(
        children: <Widget>[
          Expanded(
            child: FlatButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {},
              child: Text(
                '0',
                style: Theme.of(context).textTheme.body1,
              ),
            ),
          ),
          Expanded(
            child: FlatButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {},
              child: Text(
                '1',
                style: Theme.of(context).textTheme.body1,
              ),
            ),
          ),
          Expanded(
            child: FlatButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {},
              child: Text(
                '2',
                style: Theme.of(context).textTheme.body1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}