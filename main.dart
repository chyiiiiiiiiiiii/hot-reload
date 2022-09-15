import 'dart:developer';

import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';
import 'package:watcher/watcher.dart';

void main() {
  final watcher = DirectoryWatcher(".");
  watcher.events.listen((event) async {
    print("Watcher - $event");
    final ReloadReport report = await hotReload();
    if (report.success) {
      print("Watcher - Hot reload - succeed");
      runApp();
    } else {
      print("Watcher - Hot reload - failed");
      print(report.json['notices'][0]['message']);
    }
  });
}

runApp() {
  print("Hello Yii.");
}

Future<ReloadReport> hotReload() async {
  final Uri serviceUri = (await Service.getInfo()).serverUri;
  final Uri webSocketUri = convertToWebSocketUrl(serviceProtocolUrl: serviceUri);
  final VmService vmService = await vmServiceConnectUri(webSocketUri.toString());
  final VM vm = await vmService.getVM();
  final String isolateId = vm.isolates.first.id;
  final ReloadReport report = await vmService.reloadSources(isolateId);
  return report;
}
