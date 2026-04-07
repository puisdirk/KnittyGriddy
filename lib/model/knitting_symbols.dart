
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_parts.dart';

class KnittingSymbols {

		static const KnittingSymbol purl = KnittingSymbol(name: 'purl', parts: [KnittingSymbolParts.purl,]);
		static const KnittingSymbol ktbl = KnittingSymbol(name: 'ktbl', parts: [KnittingSymbolParts.ktbl,]);
		static const KnittingSymbol k2tog = KnittingSymbol(name: 'k2tog', parts: [KnittingSymbolParts.k2tog,]);
		static const KnittingSymbol ssk = KnittingSymbol(name: 'ssk', parts: [KnittingSymbolParts.ssk,]);
		static const KnittingSymbol knit = KnittingSymbol(name: 'knit', parts: [KnittingSymbolParts.knit,]);
		static const KnittingSymbol yarnover = KnittingSymbol(name: 'yarnover', parts: [KnittingSymbolParts.yarnover,]);
		static const KnittingSymbol k3tog = KnittingSymbol(name: 'k3tog', parts: [KnittingSymbolParts.k3tog,]);
		static const KnittingSymbol p2tog = KnittingSymbol(name: 'p2tog', parts: [KnittingSymbolParts.p2tog,]);
		static const KnittingSymbol p3tog = KnittingSymbol(name: 'p3tog', parts: [KnittingSymbolParts.p3tog,]);
		static const KnittingSymbol ssp = KnittingSymbol(name: 'ssp', parts: [KnittingSymbolParts.ssp,]);
		static const KnittingSymbol nostitch = KnittingSymbol(name: 'nostitch', parts: [KnittingSymbolParts.nostitch,]);
		static const KnittingSymbol line = KnittingSymbol(name: 'line', parts: [KnittingSymbolParts.line,]);
		static const KnittingSymbol circle = KnittingSymbol(name: 'circle', parts: [KnittingSymbolParts.circle,]);


  static final List<KnittingSymbol> _icons = [
    purl,ktbl,k2tog,ssk,knit,yarnover,k3tog,p2tog,p3tog,ssp,nostitch,line,circle,
  ];

  static const KnittingSymbol blank = KnittingSymbol(name: 'blank', parts: [/*KnittingSymbolParts.blankPath*/]);

  KnittingSymbol getSymbol(String name) => _icons.firstWhere((i) => i.name == name, orElse: () => blank);
}