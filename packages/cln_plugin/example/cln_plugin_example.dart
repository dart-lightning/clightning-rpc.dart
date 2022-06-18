import 'package:cln_plugin/cln_plugin.dart';

void main() {
  var plugin = Plugin(
      dynamic: true,
      onInit: (plugin) {
        plugin.log(
            level: "info",
            message:
                "RPC path file is ${plugin.configuration['lightning-rpc']}");
        return Future.value({});
      });
  plugin.registerRPCMethod(
      name: "foo",
      usage: "",
      description: "an example of how register a ",
      callback: (plugin, request) => Future.value(<String, Object>{
            "msg": "Hello",
            "language": "dart",
          }));
  plugin.registerOption(
      name: 'greeting',
      type: 'string',
      def: "World",
      description: "What name should I call you?",
      deprecated: false);
  plugin.start();
}
