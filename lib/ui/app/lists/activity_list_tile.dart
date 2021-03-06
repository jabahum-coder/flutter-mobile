import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invoiceninja_flutter/data/models/entities.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/client/client_actions.dart';
import 'package:invoiceninja_flutter/redux/invoice/invoice_actions.dart';
import 'package:invoiceninja_flutter/utils/formatting.dart';
import 'package:invoiceninja_flutter/utils/icons.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';

class ActivityListTile extends StatelessWidget {
  const ActivityListTile({
    Key key,
    this.enableNavigation = true,
    @required this.activity,
  }) : super(key: key);

  final ActivityEntity activity;
  final bool enableNavigation;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final store = StoreProvider.of<AppState>(context);
    final state = store.state;

    String title = localization.lookup('activity_${activity.activityTypeId}');
    title = activity.getDescription(
      title,
      user: state.selectedCompany.user,
      client: state.clientState.map[activity.clientId],
      invoice: state.invoiceState.map[activity.invoiceId],
    );

    return ListTile(
      leading: Icon(getIconData(activity.entityType)),
      title: Text(title),
      onTap: !enableNavigation
          ? null
          : () {
              switch (activity.entityType) {
                case EntityType.client:
                  store.dispatch(ViewClient(
                      clientId: activity.clientId, context: context));
                  break;
                case EntityType.invoice:
                  store.dispatch(ViewInvoice(
                      invoiceId: activity.invoiceId, context: context));
                  break;
              }
            },
      trailing: enableNavigation ? Icon(Icons.navigate_next) : null,
      subtitle: Row(
        children: <Widget>[
          Text(formatDate(
              convertTimestampToSqlDate(activity.updatedAt), context,
              showTime: true)),
          (activity.notes ?? '').isNotEmpty
              ? Text(' • ${localization.lookup(activity.notes)}')
              : Container(),
          (activity.isSystem ?? false)
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Icon(FontAwesomeIcons.server),
                )
              : Container(),
        ],
      ),
    );
  }
}
