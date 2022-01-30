
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_app/utils/form_factor.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../mocks/form_factor_unit_test.mocks.dart';

@GenerateMocks([BuildContext])
BuildContext _createContext(Size size){
  final context = MockBuildContext();
  final mediaQuery = MediaQuery(
    data: MediaQueryData(size: size),
    child: const SizedBox(),
  );
  when(context.widget).thenReturn(const SizedBox());
  when(context.findAncestorWidgetOfExactType()).thenReturn(mediaQuery);
  when(context.dependOnInheritedWidgetOfExactType<MediaQuery>())
      .thenReturn(mediaQuery);
  when(context.getElementForInheritedWidgetOfExactType())
      .thenReturn(InheritedElement(mediaQuery));

  return context;
}


void main() {

  group('Given a context return the device form factor', ()
  {
    test('Watch device', () {
      var result = getFormFactor(_createContext(Size(200, 300)));
      expect(result, ScreenType.Watch);
    });

    test('Handset device', () {
      var result = getFormFactor(_createContext(Size(350, 800)));
      expect(result, ScreenType.Handset);
    });

    test('Tablet device', () {
      var result = getFormFactor(_createContext(Size(650, 900)));
      expect(result, ScreenType.Tablet);
    });

    test('Desktop device', () {
      var result = getFormFactor(_createContext(Size(1000, 950)));
      expect(result, ScreenType.Desktop);
    });
  });

}