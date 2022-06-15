// TODO: Put public facing types in this file.

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:cln_plugin/src/json_rpc/request.dart';
import 'package:cln_plugin/src/rpc_method/builtin/get_manifest.dart';
import 'package:cln_plugin/src/rpc_method/builtin/init.dart';
import 'package:cln_plugin/src/rpc_method/rpc_command.dart';
import 'package:cln_plugin/src/rpc_method/types/option.dart';
import 'package:cln_plugin/src/rpc_method/types/feature.dart';

import 'icln_plugin_base.dart';

class Plugin implements CLNPlugin {
  /// List of methods exposed
  HashMap<String, RPCCommand> rpcMethods = HashMap();

  /// List of Subscriptions
  late List<String> subscriptions;

  /// List of Options
  late List<Option> options;

  /// List of Hooks
  late Set<String> hooks;

  /// FeatureBits for announcements of featurebits in protocol
  late Feature features;

  /// Boolean to mark dynamic management of plugin
  late bool dynamic = false;

  /// Custom notifications map
  HashMap<String, RPCCommand> notifications = HashMap();

  Plugin({bool dynamic = false});

  @override
  void registerFeature(
      {required String node,
      required String channel,
      required String init,
      required String invoice}) {
    features =
        Feature(node: node, channel: channel, init: init, invoice: invoice);
  }

  @override
  void registerOption(
      {required String name,
      required String type,
      required String def,
      required String description,
      required bool deprecated}) {
    options = Option(
        name: name,
        type: type,
        def: def,
        description: description,
        deprecated: deprecated) as List<Option>;
  }

  @override
  void registerRPCMethod(
      {required String name,
      required String usage,
      required String description,
      required Future<Map<String, Object>> Function(Plugin, Map<String, Object>)
          callback}) {
    rpcMethods[name] = RPCCommand(
        name: name, usage: usage, description: description, callback: callback);
  }

  @override
  void registerSubscriptions({required String event}) {
    subscriptions.add(event);
  }

  @override
  void registerHook({required String name}) {
    hooks.add(name);
  }

  @override
  void registerNotification(
      {required String event,
      required Future<Map<String, Object>> Function(Plugin, Map<String, Object>)
          onEvent}) {
    notifications["event"] =
        RPCCommand(name: "", usage: "", description: "", callback: onEvent);
  }

  /// get manifest method used to communicate the plugin configuration
  /// to core lightning.
  Future<Map<String, Object>> getManifest(
      Plugin plugin, Map<String, Object> request) {
    return Future.value({});
  }

  /// init method used to answer to configure the plugin with the core lightning
  /// configuration.
  Future<Map<String, Object>> init(Plugin plugin, Map<String, Object> request) {
    return Future.value({});
  }

  // init plugin used to register the rpc method required by the plugin
  // life cycle
  void _initPlugin() {
    rpcMethods["getmanifest"] =
        GetManifest(callback: (Plugin plugin, Map<String, Object> request) {
      return getManifest(plugin, request);
    });
    rpcMethods["init"] = InitMethod(
        callback: (Plugin plugin, Map<String, Object> request) =>
            init(plugin, request));
  }

  Future<Map<String, Object>> _call(
      String name, Map<String, Object> request) async {
    if (rpcMethods.containsKey(name)) {
      var method = rpcMethods[name]!;
      return await method.call(this, request);
    }
    throw Exception("Method with name $name not found!");
  }

  @override
  void start() async {
    _initPlugin();
    try {
      String? messageSocket;
      while ((messageSocket = stdin.readLineSync()) != null) {
        // Already checked is stdin is not null, why trim and check again??
        if (messageSocket!.trim().isEmpty) {
          continue;
        }
        var jsonRequest = Request.fromJson(jsonDecode(messageSocket));

        /// FIXME: read the json request
        try {
          var response = await _call(jsonRequest.method, jsonRequest.params);
          File('/home/swapnil/clightning4j/p_log.txt')
              .writeAsString(response.toString());
        print(Response(result: response).toJson());

          /// FIXME: fill the response with the result != null
        } catch (ex, stacktrace) {
          /// Fill the Response with the error != null
          print('$ex:$stacktrace');
        }
      }
    } catch (error, stacktrace) {
      print('$error:$stacktrace');
    }
  }
}
