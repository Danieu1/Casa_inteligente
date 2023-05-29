import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void connectToMqtt() async {
  // Crie uma instância do cliente MQTT
  final client = MqttServerClient('broker.emqx.io', 'meu_aplicativo_flutter');

  // Defina as credenciais (opcional)
  client.logging(on: true);

  // Defina os callbacks para manipular eventos MQTT
  client.onConnected = () {
    print('Conectado ao broker MQTT');
    // Inscreva-se nos tópicos desejados
    client.subscribe('temperatura_ambiente', MqttQos.exactlyOnce);
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
}

void main(){
    connectToMqtt(); 
}