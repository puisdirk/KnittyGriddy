
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_paths.dart';

class KnittingSymbols {

		static const KnittingSymbol purl = KnittingSymbol(name: 'purl', paths: [KnittingSymbolPaths.purl,]);
		static const KnittingSymbol ktbl = KnittingSymbol(name: 'ktbl', paths: [KnittingSymbolPaths.ktbl,]);
		static const KnittingSymbol k2tog = KnittingSymbol(name: 'k2tog', paths: [KnittingSymbolPaths.k2tog,]);
		static const KnittingSymbol ssk = KnittingSymbol(name: 'ssk', paths: [KnittingSymbolPaths.ssk,]);
		static const KnittingSymbol knit = KnittingSymbol(name: 'knit', paths: [KnittingSymbolPaths.knit,]);
		static const KnittingSymbol yarnover = KnittingSymbol(name: 'yarnover', paths: [KnittingSymbolPaths.yarnover,]);
		static const KnittingSymbol k3tog = KnittingSymbol(name: 'k3tog', paths: [KnittingSymbolPaths.k3tog,]);
		static const KnittingSymbol p2tog = KnittingSymbol(name: 'p2tog', paths: [KnittingSymbolPaths.p2tog,]);
		static const KnittingSymbol p3tog = KnittingSymbol(name: 'p3tog', paths: [KnittingSymbolPaths.p3tog,]);
		static const KnittingSymbol ssp = KnittingSymbol(name: 'ssp', paths: [KnittingSymbolPaths.ssp,]);
		static const KnittingSymbol nostitch = KnittingSymbol(name: 'nostitch', paths: [KnittingSymbolPaths.nostitch,]);
		static const KnittingSymbol line = KnittingSymbol(name: 'line', paths: [KnittingSymbolPaths.line,]);
		static const KnittingSymbol circle = KnittingSymbol(name: 'circle', paths: [KnittingSymbolPaths.circle,]);


  static final List<KnittingSymbol> _icons = [
    purl,ktbl,k2tog,ssk,knit,yarnover,k3tog,p2tog,p3tog,ssp,nostitch,line,circle,
  ];

  static const KnittingSymbol blank = KnittingSymbol(name: 'blank', paths: [KnittingSymbolPaths.blankPath]);

  KnittingSymbol getSymbol(String name) => _icons.firstWhere((i) => i.name == name, orElse: () => blank);
}