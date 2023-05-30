import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();


}

class _MyHomePageState extends State<MyHomePage> {
  
  final client = MqttServerClient('18.231.186.76', 'meu_aplicativo_flutter');
  bool light= false;
  double luminosidade = 0;
  double temperatura = 0;
  late MqttClientConnectionStatus? connectionStatus;
   StreamSubscription? subscription;
  
  @override
   void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => connectToMqtt());
  }

void connectToMqtt() async {
  // Crie uma instância do cliente MQTT
  
  // Defina as credenciais (opcional)
  client.logging(on: true);

  // Defina os callbacks para manipular eventos MQTT
  client.onConnected = () {
    print('Conectado ao broker MQTT');
    // Inscreva-se nos tópicos desejados
    client.subscribe('tads/temperatura', MqttQos.exactlyOnce);
     client.subscribe('tads/luz', MqttQos.exactlyOnce);
  };
 

  client.onDisconnected = () {
    print('Desconectado do broker MQTT');
  };

  client.onSubscribed = (String topic) {
    print('Inscrito no tópico: $topic');
  };

  client.onSubscribeFail = (String topic) {
    print('Falha ao se inscrever no tópico: $topic');
  };

  try {
    // Conecte-se ao broker MQTT
    await client.connect();
  } catch (e) {
    print('Erro ao conectar ao broker MQTT: $e');
  }

  client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      messages.forEach((MqttReceivedMessage<MqttMessage> message) {
        final MqttPublishMessage payload = message.payload as MqttPublishMessage;
        final String topic = message.topic;
        final String messageText = MqttPublishPayload.bytesToStringAsString(payload.payload.message);

        if(topic == 'tads/luz' ){
          setState(()=>{luminosidade = double.parse(messageText)});
        }if(topic == 'tads/temperatura'){
           setState(()=>{temperatura = double.parse(messageText)});
        }
       
      });
    });

}
   void _subscribeToTopic(String topic) {
    if ( connectionStatus == MqttConnectionState.connected) {
        print('[MQTT client] Subscribing to ${topic.trim()}');
        client.subscribe(topic, MqttQos.exactlyOnce);
    }
  }
   void _disconnect() {
    print('[MQTT client] _disconnect()');
    client.disconnect();
    _onDisconnected();
  }
  void _onDisconnected() {
    print('[MQTT client] _onDisconnected');
    setState(() {
      //topics.clear();
      connectionStatus = client.connectionStatus;
      subscription!.cancel();
      subscription = null;
    });
    print('[MQTT client] MQTT client disconnected');
  }

  void _onMessage(List<MqttReceivedMessage> event) {
    print(event.length);
    final MqttPublishMessage recMess =
    event[0].payload as MqttPublishMessage;
    final String message =
    MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    print('[MQTT client] MQTT message: topic is <${event[0].topic}>, ''payload is <-- ${message} -->');
    print(client.connectionStatus);
    print("[MQTT client] message with topic: ${event[0].topic}");
    print("[MQTT client] message with message: ${message}");
    setState(() {
      
    });
  }


  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(
      
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
     
        title: Text("Casa inteligente"),
      ),
      body: Center(
       
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             Text(
              'Luminosidade: $luminosidade',
            ),
             Text(
              'Temperatura: $temperatura',
            ),
          
          Switch(
            value: light,
            activeColor: Colors.green,
            onChanged: (bool value) {
              
              setState(() {
                light = value;
                int l = value?1:0;
              final builder = MqttClientPayloadBuilder();
              builder.addString(l.toString());
              client.publishMessage('tads/botao', MqttQos.exactlyOnce, builder.payload!);
              print(light);
  });
              
            },
            
          )
           
          ],
    

        ),
      ),
      
    );
  }
}
