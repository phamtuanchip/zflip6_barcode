import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zflip6_barcode/main.dart';
import 'package:zflip6_barcode/providers/barcode_provider.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BarcodeProvider(),
        child: const ZFlip6BarcodeApp(),
      ),
    );
    await tester.pump();
  });
}
